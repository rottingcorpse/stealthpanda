// STEALTHPANDA: src/stealth/webapi/MediaDevices.zig
// navigator.mediaDevices with Chromium-exact rejection semantics.
//
// Reference (Chrome 157, oracle captures/after1-oracle.json stock side):
//   getUserMedia() / {} / null / undefined ->
//     TypeError "Failed to execute 'getUserMedia' on 'MediaDevices':
//                At least one of audio and video must be requested"
//   5 / "x" (non-object) ->
//     TypeError "...: The provided value is not of type
//                 'UserMediaStreamConstraints'."
//   wrong receiver -> TypeError "...: Illegal invocation" (Caller hook)
//   getDisplayMedia: same shape (permission-denied path when valid)
//   getSupportedConstraints: sync, returns the constraint dictionary
//   enumerateDevices() -> [{kind:"audioinput"},{kind:"audiooutput"}]
//     with empty deviceId/groupId pre-permission
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const js = @import("../../browser/js/js.zig");
const Execution = js.Execution;

pub fn registerTypes() []const type {
    return &.{MediaDevices};
}

pub const MediaDevices = struct {
    _pad: bool = false,

    const DeviceInfo = struct {
        kind: []const u8,
        deviceId: []const u8 = "",
        groupId: []const u8 = "",
        label: []const u8 = "",
    };

    // The pre-permission inventory of a desktop without cameras/mics
    // attached: one input + one output. deviceId/groupId are empty until
    // permission is granted — exactly what the reference Chrome reports.
    const devices = [_]DeviceInfo{
        .{ .kind = "audioinput" },
        .{ .kind = "audiooutput" },
    };

    fn enumerateDevices(_: *const MediaDevices, exec: *const Execution) !js.Promise {
        return exec.js.local.?.resolvePromise(devices);
    }

    fn rejectTypeErr(exec: *const Execution, comptime msg: []const u8) !js.Promise {
        const local = exec.js.local.?;
        const resolver = local.createPromiseResolver();
        // WebIDL: promise-returning methods never throw — they reject.
        resolver.rejectError(
            "getUserMedia",
            .{ .type_error = "Failed to execute 'getUserMedia' on 'MediaDevices': " ++ msg },
        );
        return resolver.promise();
    }

    const Constraints = struct { audio: ?bool = null, video: ?bool = null };

    fn getUserMedia(_: *const MediaDevices, constraints: ?js.Value, exec: *const Execution) !js.Promise {
        const local = exec.js.local.?;
        const c = constraints orelse {
            return rejectTypeErr(exec, "At least one of audio and video must be requested");
        };

        var wants_audio = false;
        var wants_video = false;
        if (c.isObject()) {
            const parsed = c.toZig(Constraints) catch null;
            if (parsed) |cc| {
                wants_audio = cc.audio orelse false;
                wants_video = cc.video orelse false;
            } else {
                // nested constraint objects ({video:{width:1280}}) fail the
                // bool conversion — they ARE requests
                wants_audio = true;
                wants_video = true;
            }
        } else if (c.isNumber() or c.isString() != null) {
            return rejectTypeErr(exec, "The provided value is not of type 'UserMediaStreamConstraints'.");
        } else {
            // null / undefined / bool / anything else: nothing requested
            return rejectTypeErr(exec, "At least one of audio and video must be requested");
        }

        if (!wants_audio and !wants_video) {
            return rejectTypeErr(exec, "At least one of audio and video must be requested");
        }
        // Valid constraints, no permission granted: NotAllowedError.
        const resolver = local.createPromiseResolver();
        resolver.rejectError("getUserMedia", .{ .dom_exception = .{ .err = error.NotAllowedError } });
        return resolver.promise();
    }

    fn getDisplayMedia(_: *const MediaDevices, constraints: ?js.Value, exec: *const Execution) !js.Promise {
        _ = constraints;
        const local = exec.js.local.?;
        const resolver = local.createPromiseResolver();
        resolver.rejectError("getDisplayMedia", .{ .dom_exception = .{ .err = error.NotAllowedError } });
        return resolver.promise();
    }

    const SupportedConstraints = struct {
        aspectRatio: bool = true,
        autoGainControl: bool = true,
        channelCount: bool = true,
        deviceId: bool = true,
        displaySurface: bool = true,
        echoCancellation: bool = true,
        facingMode: bool = true,
        frameRate: bool = true,
        groupId: bool = true,
        height: bool = true,
        noiseSuppression: bool = true,
        sampleRate: bool = true,
        sampleSize: bool = true,
        width: bool = true,
    };

    fn getSupportedConstraints(_: *const MediaDevices) SupportedConstraints {
        return .{};
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(MediaDevices);

        pub const Meta = struct {
            pub const name = "MediaDevices";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const enumerateDevices = bridge.function(MediaDevices.enumerateDevices, .{ .js_name = "enumerateDevices" });
        pub const getUserMedia = bridge.function(MediaDevices.getUserMedia, .{ .js_name = "getUserMedia" });
        pub const getDisplayMedia = bridge.function(MediaDevices.getDisplayMedia, .{ .js_name = "getDisplayMedia" });
        pub const getSupportedConstraints = bridge.function(MediaDevices.getSupportedConstraints, .{ .js_name = "getSupportedConstraints" });
    };
};
