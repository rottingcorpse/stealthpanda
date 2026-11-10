// Copyright (C) 2023-2026  Lightpanda (Selecy SAS)
//
// Francis Bouvier <francis@lightpanda.io>
// Pierre Tachoire <pierre@lightpanda.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");
const lp = @import("lightpanda");

const js = @import("../js/js.zig");

const URL = @import("../URL.zig");
const Frame = @import("../Frame.zig");
const Transfer = @import("../../network/HttpClient.zig").Transfer;

const EventTarget = @import("EventTarget.zig");
const MessagePort = @import("MessagePort.zig");
const MessageEvent = @import("event/MessageEvent.zig");
const ErrorEvent = @import("event/ErrorEvent.zig");
const DedicatedWorkerGlobalScope = @import("DedicatedWorkerGlobalScope.zig");

const log = lp.log;

const Worker = @This();

pub const Proto = EventTarget;

pub const WorkerType = enum {
    classic,
    module,
    pub const js_enum_from_string = true;
};

// used by HttpClient when generating notification
// Ultimately used by CDP to generate request/loader ids.
_frame_id: u32,
_loader_id: u32,

_proto: *EventTarget,
_frame: *Frame,
_arena: *lp.Arena,
_worker_scope: *DedicatedWorkerGlobalScope,

_url: [:0]const u8,
_type: WorkerType = .classic,
_script_loaded: bool = false,
_script_arena: ?*lp.Arena = null,
// STEALTHPANDA: script bytes pending the deferred blob/data load.
_deferred_script: ?[]const u8 = null,
// STEALTHPANDA: set by terminate(); the deferred blob/data load and any
// late transfer completion must not evaluate or fire events after it (a
// same-tick terminate() on a blob worker must stay silent — upstream
// worker.html worker_terminate_during_fetch_fires_no_error).
_terminated: bool = false,
_http_transfer: ?*Transfer = null,

// Event handlers

const WorkerOptions = struct {
    type: WorkerType = .classic,
};

pub fn init(url: []const u8, options: ?WorkerOptions, frame: *Frame) !*Worker {
    const session = frame._session;

    const arena = try session.getArena(.small, "Worker");
    errdefer arena.release();

    const resolved_url = try URL.resolve(arena.allocator(), frame.base(), url, .{ .encoding = frame.charset });
    const self = try frame.page.factory.eventTargetWithAllocator(arena.allocator(), Worker{
        ._arena = arena,
        ._proto = undefined,
        ._frame = frame,
        ._url = resolved_url,
        ._type = if (options) |o| o.type else .classic,
        ._worker_scope = undefined,
        ._frame_id = session.nextFrameId(),
        ._loader_id = session.nextLoaderId(),
    });
    const dedicated_worker = try DedicatedWorkerGlobalScope.init(self, resolved_url);
    errdefer dedicated_worker.deinit();

    self._worker_scope = dedicated_worker;
    try frame.trackWorker(self);

    if (session.load_resources.worker == false) {
        frame.page.status.noteSkipped(.worker);
        return self;
    }

    self._script_arena = try session.getArena(.small, "Worker.script");
    errdefer self.releaseScriptArena();

    // STEALTHPANDA: blob:/data: worker scripts. The HTTP fetch below never
    // completes for these schemes (no transport) — every blob-worker probe
    // timed out (vectors worker-ua/workerGl). Resolve the content directly
    // from the page's blob store / inline data, DEFERRED to the next task
    // turn: the page must get a chance to register onmessage/onerror after
    // the constructor returns, exactly like the async fetch path (loading
    // synchronously fired the events into the void — measured).
    if (workerScriptContent(frame, resolved_url)) |content| {
        const buf = try self._script_arena.?.allocator().dupe(u8, content);
        // The task must run on the PAGE's scheduler: the worker's own
        // context is never pumped until its first message arrives, so a
        // task queued there would deadlock (measured: 6b binary still
        // timed out). The page loop pumps on its next turn — after the
        // constructor returns and handlers register.
        frame.js.scheduler.add(self, deferredBlobLoad, 0, .{
            .name = "Worker.blobScriptLoad",
        }) catch {
            self.loadInitialScript(buf) catch {};
            return self;
        };
        self._deferred_script = buf;
        return self;
    }

    const transfer = frame.newRequest(.{
        .ctx = self,
        .method = .GET,
        .url = resolved_url,
        .frame_id = self._frame_id,
        .loader_id = self._loader_id,
        .resource_type = if (self._type == .module) .script else .worker,
        .origin = frame.origin,
        .request_mode = .same_origin,
        .credentials_mode = .same_origin,
        .header_callback = httpHeaderCallback,
        .done_callback = httpDoneCallback,
        .error_callback = httpErrorCallback,
        .shutdown_callback = httpShutdownCallback,
    }) catch |err| {
        log.debug(.browser, "Worker request", .{ .url = resolved_url, .err = err });
        frame.removeWorker(self);
        return err;
    };

    // Held for deinit's abort; the done, error and shutdown callbacks clear
    // it. The shutdown one matters: Frame.deinit's abortOwner kills the
    // transfer before it deinits this worker, and deinit must not abort a
    // freed transfer.
    self._http_transfer = transfer;

    transfer.submit() catch |err| {
        log.debug(.browser, "Worker request", .{ .url = resolved_url, .err = err });
        frame.removeWorker(self);
        return err;
    };
    return self;
}

// Called from Frame.deinit when the frame is destroyed, so we don't need to
// remove from the frame's worker list.
pub fn deinit(self: *Worker) void {
    // No pending frame for workers, so we can abort all frames.
    if (self._http_transfer) |res| {
        res.cancel();
        self._http_transfer = null;
    }
    self.releaseScriptArena();
    self._worker_scope.deinit();
    self._frame.page.event_listeners.removeTarget(self.asEventTarget());
    self._arena.release();
}

pub fn asEventTarget(self: *Worker) *EventTarget {
    return self._proto;
}

fn httpHeaderCallback(transfer: *Transfer) !Transfer.HeaderResult {
    const self: *Worker = @ptrCast(@alignCast(transfer.req.ctx));

    const status = transfer.responseStatus() orelse return .abort;
    if (status < 200 or status >= 300) {
        log.debug(.browser, "Worker status", .{
            .url = self._url,
            .status = status,
        });
        return .abort;
    }

    return .proceed;
}

fn httpDoneCallback(transfer: *Transfer) !void {
    const self: *Worker = @ptrCast(@alignCast(transfer.req.ctx));
    self._http_transfer = null;
    defer self.releaseScriptArena();

    const url = self._url;
    // Evaluated synchronously, so borrowing the transfer's body is fine.
    const script = transfer.responseBody();

    if (comptime lp.IS_DEBUG) {
        log.info(.browser, "worker fetch done", .{
            .url = url,
            .len = script.len,
        });
    }

    try self.loadInitialScript(script);
}

// STEALTHPANDA: resolve blob:/data: worker script content without the
// HTTP machinery. blob: comes from the page's blob store (origin-checked);
// data: is parsed inline (percent-decoded payload).
fn workerScriptContent(frame: *Frame, url: []const u8) ?[]const u8 {
    const Blob = @import("Blob.zig");
    const data_url = @import("../data_url.zig");

    if (std.mem.startsWith(u8, url, "blob:")) {
        if (!Blob.urlBelongsToOrigin(url, frame.origin)) return null;
        const entry = frame.page.blob_urls.get(url) orelse return null;
        return entry.blob._slice;
    }
    if (std.mem.startsWith(u8, url, "data:")) {
        const parsed = data_url.parse(frame.call_arena, url) catch {
            return null;
        };
        return parsed.body;
    }
    return null;
}

// STEALTHPANDA: scheduler callback for the deferred blob/data load.
fn deferredBlobLoad(ctx: *anyopaque) anyerror!?u32 {
    const self: *Worker = @ptrCast(@alignCast(ctx));
    const script = self._deferred_script orelse return null;
    self._deferred_script = null;
    // STEALTHPANDA: a same-tick terminate() cancels the pending script
    // load exactly like it cancels an inflight HTTP fetch — silently.
    if (self._terminated) return null;
    self.loadInitialScript(script) catch {};
    return null; // one-shot
}

fn loadInitialScript(self: *Worker, script: []const u8) !void {
    const js_context = self._worker_scope._proto.js;

    if (js_context.env.terminatePending()) {
        return;
    }

    // Keep buffering throughout the entire outer eval (including any
    // runMacrotasks pumped by importScripts via the synchronous CDP path,
    // see WorkerGlobalScope.importScripts). The flip-and-drain happens
    // via defer so it runs after eval AND after the trailing
    // runMacrotasks below — by which point the outer script has had its
    // only chance to register onmessage. drainPendingMessages enqueues
    // messages in receive order, so pre-eval and during-eval messages
    // are delivered FIFO on the next runner tick, matching the spec.
    //
    // On eval-throw the defer still fires; the messages get scheduled
    // and then drop at the "no listener" check, mirroring the
    // httpErrorCallback path.
    defer {
        self._script_loaded = true;
        self._worker_scope.drainPendingMessages();
    }

    var ls: js.Local.Scope = undefined;
    js_context.localScope(&ls);
    defer ls.deinit();

    var try_catch: js.TryCatch = undefined;
    try_catch.init(&ls.local);
    defer try_catch.deinit();

    // Classic workers evaluate the entry script as a classic script; module
    // workers (`new Worker(url, { type: "module" })`) instantiate it as a
    // module so top-level `import`/`export` work. Static imports load
    // synchronously through ScriptManagerBase (client.tick sync_wait).
    switch (self._type) {
        .classic => _ = ls.local.eval(script, self._url) catch |err| {
            if (js_context.env.terminatePending()) {
                return;
            }

            js_context.page.recordJsError(err);
            const caught = try_catch.caughtOrError(self._script_arena.?.allocator(), err);
            log.warn(.page_error, "uncaught exception", .{ .url = self._url, .caught = caught });
            self.fireErrorEvent(caught.exception orelse @errorName(err), null);
            return;
        },
        .module => js_context.module(false, &ls.local, script, self._url, .{}, true, null) catch |err| {
            if (js_context.env.terminatePending()) {
                return;
            }

            js_context.page.recordJsError(err);
            const caught = try_catch.caughtOrError(self._script_arena.?.allocator(), err);
            log.warn(.page_error, "uncaught exception", .{ .url = self._url, .caught = caught });
            self.fireErrorEvent(caught.exception orelse @errorName(err), null);
            return;
        },
    }

    ls.local.runMacrotasks();
}

fn httpShutdownCallback(ctx: *anyopaque) void {
    const self: *Worker = @ptrCast(@alignCast(ctx));
    self._http_transfer = null;
    self.releaseScriptArena();
}

fn httpErrorCallback(ctx: *anyopaque, err: anyerror) void {
    const self: *Worker = @ptrCast(@alignCast(ctx));
    self._http_transfer = null;
    self.releaseScriptArena();

    // TransferCanceled is not a load failure: terminate() (or worker teardown)
    // cancelled a still-inflight script fetch. We shouldn't fireErrorEvent
    // (or bother logging)
    const canceled = err == error.TransferCanceled;
    if (!canceled) {
        log.debug(.browser, "worker fetch error", .{
            .url = self._url,
            .err = err,
        });
    }

    // The worker will never load and onmessage will never be registered.
    // Drain any buffered messages so they get dispatched (and silently
    // dropped at the "no listener" check) rather than accumulating until
    // worker teardown. Future postMessages then schedule normally.
    self._script_loaded = true;
    self._worker_scope.drainPendingMessages();

    if (!canceled) {
        self.fireErrorEvent(@errorName(err), null);
    }
}

fn releaseScriptArena(self: *Worker) void {
    const arena = self._script_arena orelse return;
    self._script_arena = null;
    arena.release();
}

// Fire an error event on the Worker object (parent context)
fn fireErrorEvent(self: *Worker, message: []const u8, error_value: ?js.Value.Global) void {
    self._fireErrorEvent(message, error_value) catch |err| {
        log.debug(.browser, "worker fire error", .{ .err = err, .message = message });
    };
}

fn _fireErrorEvent(self: *Worker, message: []const u8, error_value: ?js.Value.Global) !void {
    const frame = self._frame;
    const target = self.asEventTarget();
    // Check if there are any listeners
    if (!frame._event_manager.hasDirectListeners(target, "error")) {
        if (error_value) |ev| ev.release();
        return;
    }

    const error_event = try ErrorEvent.initTrusted(comptime .wrap("error"), .{
        .@"error" = error_value,
        .message = message,
        .filename = self._url,
        .bubbles = false,
        .cancelable = true,
    }, frame.page);

    try frame._event_manager.dispatchDirect(target, error_event.asEvent(), .{
        .context = "Worker.onerror",
    });
}

pub fn terminate(self: *Worker) void {
    // STEALTHPANDA: mark terminated — the deferred blob/data load checks
    // this and must stay silent (see deferredBlobLoad).
    self._terminated = true;

    // Abort any pending script fetch
    if (self._http_transfer) |resp| {
        resp.cancel();
        self._http_transfer = null;
    }
}

// Posts a message from the frame to the worker.
pub fn postMessage(self: *Worker, data: js.Value, transfer: ?js.Value) !void {
    try self._worker_scope.receiveMessage(data, try MessagePort.transferList(transfer));
}

// Called internally by DedicatedWorkerGlobalScope when it wants to post a message to us
pub fn receiveMessage(self: *Worker, data: js.Value, transfer: []const *MessagePort) !void {
    const frame = self._frame;

    // clones from where it currently is (the Worker context) to our Page's context
    const message = try MessagePort.cloneMessage(data, transfer, &frame.js.execution);
    errdefer message.release();

    const message_arena = try frame.getArena(.tiny, "Worker.receiveMessage");
    errdefer message_arena.release();

    const callback = try message_arena.create(ReceiveMessageCallback);
    callback.* = .{
        .worker = self,
        .message = message,
        .arena = message_arena,
    };

    try frame.js.scheduler.add(callback, ReceiveMessageCallback.run, 0, .{
        .name = "Worker.receiveMessage",
        .kind = .message,
        .parent = message.task,
        .finalizer = ReceiveMessageCallback.cancelled,
    });
}

const ReceiveMessageCallback = struct {
    message: MessagePort.Message,
    arena: *lp.Arena,
    worker: *Worker,

    fn cancelled(ctx: *anyopaque) void {
        const self: *ReceiveMessageCallback = @ptrCast(@alignCast(ctx));
        self.message.release();
        self.deinit();
    }

    fn deinit(self: *ReceiveMessageCallback) void {
        self.arena.release();
    }

    fn run(ctx: *anyopaque) !?u32 {
        const self: *ReceiveMessageCallback = @ptrCast(@alignCast(ctx));
        defer self.deinit();
        defer self.message.releasePorts();

        const worker = self.worker;
        const frame = worker._frame;
        const target = worker.asEventTarget();

        // If data is null, deserialization failed - fire messageerror
        const data = self.message.data orelse {
            if (!frame._event_manager.hasDirectListeners(target, "messageerror")) {
                return null;
            }
            const event = (try MessageEvent.initTrusted(comptime .wrap("messageerror"), .{
                .ports = self.message.ports,
                .bubbles = false,
                .cancelable = false,
            }, frame.page)).asEvent();
            try frame._event_manager.dispatchDirect(target, event, .{ .context = "Worker.messageerror" });
            return null;
        };

        // Check if there are any listeners before creating the event
        if (!frame._event_manager.hasDirectListeners(target, "message")) {
            data.release();
            return null;
        }

        const event = (try MessageEvent.initTrusted(comptime .wrap("message"), .{
            .data = .{ .value = data },
            .ports = self.message.ports,
            .bubbles = false,
            .cancelable = false,
        }, frame.page)).asEvent();

        try frame._event_manager.dispatchDirect(target, event, .{ .context = "Worker.receiveMessage" });

        return null;
    }
};

pub const JsApi = struct {
    pub const bridge = js.Bridge(Worker);

    pub const Meta = struct {
        pub const name = "Worker";
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const constructor = bridge.constructor(Worker.init, .{});

    pub const terminate = bridge.function(Worker.terminate, .{});
    pub const postMessage = bridge.function(Worker.postMessage, .{});

    pub const onmessage = EventTarget.handlerAccessor(Worker, "message");
    pub const onmessageerror = EventTarget.handlerAccessor(Worker, "messageerror");
    pub const onerror = EventTarget.handlerAccessor(Worker, "error");
};

const testing = @import("../../testing.zig");
test "WebApi: Worker" {
    testing.silenceLog(&.{ .http, .browser, .browser });
    // report-error-worker.js throws five uncaught exceptions on purpose.
    testing.expectLog(&.{ .page_error, .page_error, .page_error, .page_error, .page_error });

    // Worker tests chain a worker-script fetch with a dynamic-import fetch
    // and a cross-context postMessage. The default 2 s assertion budget can
    // blow up on TSAN CI; give it more room.
    try testing.htmlRunner("worker", .{ .timeout_ms = 8000 });
}
