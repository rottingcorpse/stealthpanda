// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
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

const Frame = @import("../../../Frame.zig");
const Factory = @import("../../../Factory.zig");

const Blob = @import("../../Blob.zig");
const Node = @import("../../Node.zig");
const Element = @import("../../Element.zig");

const OffscreenCanvas = @import("../../canvas/OffscreenCanvas.zig");
const WebGLRenderingContext = @import("../../canvas/WebGLRenderingContext.zig");
const CanvasRenderingContext2D = @import("../../canvas/CanvasRenderingContext2D.zig");
// STEALTHPANDA: fingerprint-grade webgl2 context (src/stealth/webapi/).
const stealth_webgl = @import("../../../../stealth/webapi/WebGL.zig");
const stealth_identity = @import("../../../../stealth/identity.zig");

const HtmlElement = @import("../Html.zig");

const js = lp.js;
const log = lp.log;
const Execution = js.Execution;
const BlankPNG = OffscreenCanvas.BlankPNG;

const Canvas = @This();

pub const Proto = HtmlElement;
_proto_canary: if (lp.IS_DEBUG) *HtmlElement else void = undefined,
_cached: ?DrawingContext = null,

pub fn asElement(self: *Canvas) *Element {
    return Factory.protoOf(self).asElement();
}
pub fn asConstElement(self: *const Canvas) *const Element {
    return Factory.protoOf(self).asElement();
}
pub fn asNode(self: *Canvas) *Node {
    return self.asElement().asNode();
}

pub fn getWidth(self: *const Canvas) u32 {
    const attr = self.asConstElement().getAttributeInterned("width") orelse return 300;
    return std.fmt.parseUnsigned(u32, attr, 10) catch 300;
}

pub fn getHeight(self: *const Canvas) u32 {
    const attr = self.asConstElement().getAttributeInterned("height") orelse return 150;
    return std.fmt.parseUnsigned(u32, attr, 10) catch 150;
}

/// Since there's no base class rendering contexts inherit from,
/// we're using tagged union.
const DrawingContext = union(enum) {
    @"2d": *CanvasRenderingContext2D,
    webgl: *WebGLRenderingContext,
    // STEALTHPANDA: webgl2 context (stealth module).
    webgl2: *stealth_webgl.WebGL2RenderingContext,
};

fn getContext(self: *Canvas, context_type: []const u8, frame: *Frame) !?DrawingContext {
    if (self._cached) |cached| {
        const matches = switch (cached) {
            .@"2d" => std.mem.eql(u8, context_type, "2d"),
            .webgl => std.mem.eql(u8, context_type, "webgl") or std.mem.eql(u8, context_type, "experimental-webgl"),
            .webgl2 => std.mem.eql(u8, context_type, "webgl2"),
        };
        return if (matches) cached else null;
    }

    const drawing_context: DrawingContext = blk: {
        if (std.mem.eql(u8, context_type, "2d")) {
            const ctx = try frame._factory.create(CanvasRenderingContext2D{ ._canvas = self });
            break :blk .{ .@"2d" = ctx };
        }

        // STEALTHPANDA: fingerprint-grade WebGL contexts (see
        // src/stealth/webapi/WebGL.zig). Stock lightpanda returned null
        // (deliberate half-API avoidance); the stealth surface answers
        // every parameter/extension/precision probe coherently, so the
        // "worst of both worlds" concern above does not apply. Stood-down
        // (internal test) builds keep the stock null — upstream's own
        // status notes/tests describe WebGL as not provided.
        if (stealth_identity.enabled) {
            if (std.mem.eql(u8, context_type, "webgl") or std.mem.eql(u8, context_type, "experimental-webgl")) {
                const ctx = try frame._factory.create(WebGLRenderingContext{});
                break :blk .{ .webgl = ctx };
            }
            if (std.mem.eql(u8, context_type, "webgl2")) {
                const ctx = try frame._factory.create(stealth_webgl.WebGL2RenderingContext{});
                break :blk .{ .webgl2 = ctx };
            }
        }

        // STEALTHPANDA: stock note for refused GL contexts — stood-down
        // (internal test) builds land here, and upstream's goto note text
        // ("The page asked for WebGL...") derives from it.
        if (isWebGL(context_type)) {
            frame.page.status.noteUnsupported(.webgl);
        }
        return null;
    };
    self._cached = drawing_context;
    return drawing_context;
}

pub fn isWebGL(context_type: []const u8) bool {
    inline for (&.{ "webgl", "webgl2", "experimental-webgl" }) |needle| {
        if (std.mem.eql(u8, context_type, needle)) {
            return true;
        }
    }
    return false;
}

fn hasBitmap(self: *const Canvas) bool {
    return BlankPNG.hasBitmap(self.getWidth(), self.getHeight());
}

/// Serializes the canvas, always as the blank PNG. Per spec an unsupported
/// `type` falls back to image/png, and with nothing drawn there is no lossy
/// encoding for `quality` to control, so both arguments are ignored.
fn toDataURL(self: *const Canvas, _: ?[]const u8, _: ?f64, exec: *const Execution) []const u8 {
    // Per spec, a canvas with no pixels serializes to this exact string.
    if (!self.hasBitmap()) return "data:,";

    // STEALTHPANDA: read from the 2D context's raster buffer and encode
    // as a real PNG. Different drawings → different data URLs (canvas
    // fingerprinting signal); same drawings → stable output. Stock
    // lightpanda always returned the same 114-byte blank PNG regardless
    // of what was drawn — an instant bot tell.
    if (self._cached) |cached| {
        switch (cached) {
            .@"2d" => |ctx| {
                if (ctx._raster) |raster| {
                    const canvas_png = @import("../../../../stealth/canvas_png.zig");
                    const url = canvas_png.encodeAsDataUrl(
                        exec.session.browser.allocator,
                        raster.width,
                        raster.height,
                        raster.pixels,
                    ) catch return BlankPNG.data_url;
                    return url;
                }
            },
            else => {},
        }
    }
    return BlankPNG.data_url;
}

/// Same image as `toDataURL`, handed to `callback` as a Blob from a task.
/// A canvas with no pixels calls back with null, per spec.
pub fn toBlob(self: *const Canvas, callback: js.Function.Global, _: ?[]const u8, _: ?f64, exec: *Execution) !void {
    const task = try exec._factory.create(ToBlobCallback{
        .exec = exec,
        // The spec checks the bitmap now, not when the task runs.
        .has_bitmap = self.hasBitmap(),
        .callback = callback,
    });
    errdefer exec._factory.destroy(task);

    try exec._scheduler.add(task, ToBlobCallback.run, 0, .{
        .name = "canvas.toBlob",
        .finalizer = ToBlobCallback.cancelled,
    });
}

const ToBlobCallback = struct {
    exec: *Execution,
    has_bitmap: bool,
    callback: js.Function.Global,

    fn cancelled(ctx: *anyopaque) void {
        const self: *ToBlobCallback = @ptrCast(@alignCast(ctx));
        self.deinit();
    }

    fn deinit(self: *ToBlobCallback) void {
        self.callback.release();
        self.exec._factory.destroy(self);
    }

    fn run(ctx: *anyopaque) !?u32 {
        const self: *ToBlobCallback = @ptrCast(@alignCast(ctx));
        defer self.deinit();
        const exec = self.exec;

        var blob: ?*Blob = null;
        if (self.has_bitmap) {
            const b = try BlankPNG.blob(exec);
            // The page can hold on to the Blob, in which case the JS wrapper
            // takes its own ref; ours only has to cover the call.
            b.acquireRef();
            blob = b;
        }
        defer if (blob) |b| {
            b.releaseRef(exec.page);
        };

        var ls: js.Local.Scope = undefined;
        exec.js.localScope(&ls);
        defer ls.deinit();

        ls.toLocal(self.callback).call(void, .{blob}) catch |err| {
            exec.page.recordJsError(err);
            log.debug(.js, "canvas.toBlob", .{ .err = err });
        };
        ls.local.runMicrotasks();
        return null;
    }
};

/// Transfers control of the canvas to an OffscreenCanvas.
/// Returns an OffscreenCanvas with the same dimensions.
fn transferControlToOffscreen(self: *Canvas, exec: *Execution) !*OffscreenCanvas {
    const width = self.getWidth();
    const height = self.getHeight();
    return OffscreenCanvas.constructor(width, height, exec);
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(Canvas);

    pub const Meta = struct {
        pub const name = "HTMLCanvasElement";
        pub var class_id: bridge.ClassId = undefined;
    };

    const reflect = Element.Reflect(Canvas);

    pub const width = reflect.unsignedLong("width", .{ .default = 300 });
    pub const height = reflect.unsignedLong("height", .{ .default = 150 });
    pub const getContext = bridge.function(Canvas.getContext, .{});
    pub const toDataURL = bridge.function(Canvas.toDataURL, .{});
    pub const toBlob = bridge.function(Canvas.toBlob, .{});
    pub const transferControlToOffscreen = bridge.function(Canvas.transferControlToOffscreen, .{});
};

const testing = @import("../../../../testing.zig");
test "WebApi: HTMLCanvasElement serialization" {
    try testing.htmlRunner("canvas/canvas_serialization.html", .{});
}
