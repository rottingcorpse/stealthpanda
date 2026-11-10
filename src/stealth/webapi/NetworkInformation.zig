// STEALTHPANDA: src/stealth/webapi/NetworkInformation.zig
// navigator.connection (NetworkInformation). Stock lightpanda lacks it;
// bladebro's battery probes `navigator.connection.effectiveType` and
// vectors.html checks the connection-api.
//
// Reference values (Chrome 157, this machine): effectiveType "4g",
// rtt 100, downlink 1.55, saveData false; proto keys constructor/downlink/
// effectiveType/onchange/rtt/saveData.
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const js = @import("../../browser/js/js.zig");

pub fn registerTypes() []const type {
    return &.{NetworkInformation};
}

pub const NetworkInformation = struct {
    _pad: bool = false,

    fn getEffectiveType(_: *const NetworkInformation) []const u8 {
        return "4g";
    }

    fn getRtt(_: *const NetworkInformation) u32 {
        return 100;
    }

    fn getDownlink(_: *const NetworkInformation) f64 {
        return 1.55;
    }

    fn getSaveData(_: *const NetworkInformation) bool {
        return false;
    }

    fn getOnChange(_: *const NetworkInformation) ?js.Value {
        return null;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(NetworkInformation);

        pub const Meta = struct {
            pub const name = "NetworkInformation";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const effectiveType = bridge.accessor(NetworkInformation.getEffectiveType, null, .{});
        pub const rtt = bridge.accessor(NetworkInformation.getRtt, null, .{});
        pub const downlink = bridge.accessor(NetworkInformation.getDownlink, null, .{});
        pub const saveData = bridge.accessor(NetworkInformation.getSaveData, null, .{});
        pub const onchange = bridge.accessor(NetworkInformation.getOnChange, null, .{});
    };
};
