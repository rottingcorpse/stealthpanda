// STEALTHPANDA: src/stealth/webapi/DeferredQuery.zig
// Chrome's exact Permissions.query microtask semantics:
//   1. Dictionary read: SYNCHRONOUS during query() (JS getters fire
//      during the call; throws propagate as synchronous rejection)
//   2. Rejection: SYNCHRONOUS — the promise is already rejected when
//      .then runs → "rejected,microtask" (oracle getterThrows/query.empty)
//   3. Resolution: DEFERRED to a microtask queued after the call —
//      the promise is still pending when .then runs → "microtask,fulfilled"
//      (oracle getter./proxy.)
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const std = @import("std");

const js = @import("../../browser/js/js.zig");
const Execution = js.Execution;
const Local = js.Local;

/// State for the deferred (successful) resolution.
const DeferredResolve = struct {
    _resolver: js.PromiseResolver.Global,
    _name: []const u8, // arena-owned; the read already happened
};

var pending: [8]?DeferredResolve = .{ null, null, null, null, null, null, null, null };
var pending_len: usize = 0;

/// The microtask callback that fulfills a successfully-read query.
fn resolveCallback(self: *DeferredResolve, exec: *const Execution) void {
    const local = exec.js.local.?;
    const resolver = self._resolver.local(local);
    const Permissions = @import("../../browser/webapi/Permissions.zig");
    const status = Permissions.buildStatusFor(self._name, exec) catch {
        resolver.rejectError("Permissions.query", .{ .type_error = "query failed" });
        return;
    };
    resolver.resolve("DeferredQuery", status);
}

/// Entry point: the Chrome-exact query() body after arity/object validation.
pub fn deferQuery(raw: js.Value, exec: *const Execution) !js.Promise {
    const local = exec.js.local.?;

    // --- 1. SYNCHRONOUS dictionary read (getter fires during the call) ---
    var try_catch: js.TryCatch = undefined;
    try_catch.init(local);
    defer try_catch.deinit();

    const QueryDescriptor = struct { name: []const u8 };
    const parsed = raw.toZig(QueryDescriptor) catch {
        // --- 2. SYNCHRONOUS rejection ---
        if (try_catch.hasCaught()) {
            // The descriptor getter THREW: reject with the thrown value.
            if (try_catch.exceptionValue()) |exception| {
                const resolver = local.createPromiseResolver();
                resolver.rejectValue(exception) catch {};
                return resolver.promise();
            }
        }
        // Missing required member: Chrome's dictionary-read TypeError.
        const resolver = local.createPromiseResolver();
        resolver.rejectError(
            "Permissions.query",
            .{ .type_error = "Failed to execute 'query' on 'Permissions': Failed to read the 'name' property from 'PermissionDescriptor': Required member is undefined." },
        );
        return resolver.promise();
    };

    // --- 3. DEFERRED resolution (promise still pending when .then runs) ---
    const resolver = local.createPromiseResolver();
    const promise = resolver.promise();

    const arena = try exec.getArena(.small, "DeferredQuery");
    errdefer arena.release();

    if (pending_len < pending.len) {
        pending[pending_len] = .{
            ._resolver = try resolver.persist(),
            ._name = try arena.dupe(u8, parsed.name),
        };
        const slot = &pending[pending_len].?;
        pending_len += 1;
        const cb = local.newCallback(resolveCallback, @as(*anyopaque, @ptrCast(slot)));
        local.ctx.queueMicrotaskFunc(cb);
    } else {
        // overflow (8+ concurrent queries before a pump): resolve now
        const Permissions = @import("../../browser/webapi/Permissions.zig");
        const status = try Permissions.buildStatusFor(parsed.name, exec);
        resolver.resolve("DeferredQuery.overflow", status);
    }

    return promise;
}
