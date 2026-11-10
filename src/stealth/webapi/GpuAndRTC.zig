// STEALTHPANDA: src/stealth/webapi/GpuAndRTC.zig
// navigator.gpu (WebGPU) presence + RTCPeerConnection (WebRTC fail-closed).
//
// Reference behavior (Chrome 157, this machine — a GPU-less host):
//   - navigator.gpu exists; gpu.requestAdapter() resolves null (no adapter)
//   - RTCPeerConnection is a function; ICE gathering yields nothing
//     (creepjs reads the whole WebRTC block as "blocked" on the reference
//     too — fail-closed IS the reference shape here)
//
// bladebro's coherence layer pins WebRTC fail-closed as their design.
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const lp = @import("lightpanda");

const js = @import("../../browser/js/js.zig");
const Execution = js.Execution;
const EventTarget = @import("../../browser/webapi/EventTarget.zig");

pub fn registerTypes() []const type {
    return &.{ GPU, RTCPeerConnection };
}

/// navigator.gpu — Chrome 157 exposes WebGPU on all desktop builds; on a
/// host without an adapter, requestAdapter() resolves null.
pub const GPU = struct {
    _pad: bool = false,

    fn requestAdapter(_: *const GPU, _: ?js.Value, exec: *const Execution) !js.Promise {
        // No adapter on this host class: resolves null per spec/Chrome.
        return exec.js.local.?.resolvePromise(null);
    }

    fn getWGSLFeatureNames(_: *const GPU) []const []const u8 {
        return &.{};
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(GPU);

        pub const Meta = struct {
            pub const name = "GPU";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const requestAdapter = bridge.function(GPU.requestAdapter, .{});
        pub const wgslFeatureNames = bridge.accessor(GPU.getWGSLFeatureNames, null, .{});
    };
};

/// RTCPeerConnection — present (webrtc-exists checks typeof === 'function')
/// but connectivity is fail-closed: no candidates ever surface.
pub const RTCPeerConnection = struct {
    _pad: bool = false,

    pub fn init(options_: ?js.Value, exec: *const Execution) !*RTCPeerConnection {
        _ = options_;
        return exec._factory.create(RTCPeerConnection{});
    }

    fn createDataChannel(_: *RTCPeerConnection, _: []const u8) js.Undefined {
        return .{};
    }

    fn createOffer(_: *RTCPeerConnection, exec: *const Execution) !js.Promise {
        // Never gathers; the promise stays pending exactly like a blocked
        // network would look. Detectors read this as fail-closed.
        const resolver = exec.js.local.?.createPromiseResolver();
        return resolver.promise();
    }

    fn setLocalDescription(_: *RTCPeerConnection, _: ?js.Value, exec: *const Execution) !js.Promise {
        const resolver = exec.js.local.?.createPromiseResolver();
        return resolver.promise();
    }

    fn close(_: *RTCPeerConnection) void {}

    fn getOnIceCandidate(_: *const RTCPeerConnection) ?js.Value {
        return null;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(RTCPeerConnection);

        pub const Meta = struct {
            pub const name = "RTCPeerConnection";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(RTCPeerConnection.init, .{});
        pub const createDataChannel = bridge.function(RTCPeerConnection.createDataChannel, .{ .noop = true });
        pub const createOffer = bridge.function(RTCPeerConnection.createOffer, .{});
        pub const setLocalDescription = bridge.function(RTCPeerConnection.setLocalDescription, .{});
        pub const close = bridge.function(RTCPeerConnection.close, .{ .noop = true });
        pub const onicecandidate = bridge.accessor(RTCPeerConnection.getOnIceCandidate, null, .{});
    };
};
