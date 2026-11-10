// STEALTHPANDA: src/stealth/webapi/ChromeNamespace.zig
// The `window.chrome` object. Stock lightpanda exposes nothing —
// bot.sannysoft's "Chrome (New)" check reads red and bladebro's battery
// probes chromeKeys/chromeObj.
//
// v2 (2026-11-10): the oracle's chromeKeys probe reads
// Object.keys(window.chrome) — OWN ENUMERABLE properties. Class
// accessors land on the prototype (keys() = [] — measured). A plain
// struct serializes each field as an OWN data property (zigValueToJs
// struct branch): app (nested struct), csi (function), loadTimes
// (function) — exactly Chrome's own-property shape.
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const js = @import("../../browser/js/js.zig");
const Execution = js.Execution;

pub fn registerTypes() []const type {
    return &.{};
}

/// The value of window.chrome: a plain (non-class) object with own
/// enumerable properties app/csi/loadTimes, built via struct
/// serialization. Functions are runtime callbacks.
pub const ChromeObject = struct {
    app: ChromeAppObject,
    csi: js.Function,
    loadTimes: js.Function,
};

const ChromeAppObject = struct {
    isInstalled: bool = false,
    InstallState: EnumHolder,
    RunningState: EnumHolder,
    getDetails: js.Function,
    getIsInstalled: js.Function,
    installState: js.Function,
    runningState: js.Function,
};

const EnumHolder = struct {
    DISABLED: []const u8 = "disabled",
    INSTALLED_NOT_RUNNING: []const u8 = "installed_not_running",
    INSTALLED_RUNNING: []const u8 = "installed_running",
};

fn csiImpl(_: *CsiFn) js.Undefined {
    return .{};
}
const CsiFn = struct { _pad: bool = false };

fn loadTimesImpl(_: *LoadTimesFn) js.Undefined {
    return .{};
}
const LoadTimesFn = struct { _pad: bool = false };

fn getDetailsImpl(_: *GetDetailsFn) js.Undefined {
    return .{};
}
const GetDetailsFn = struct { _pad: bool = false };

fn getIsInstalledImpl(_: *GetIsInstalledFn) bool {
    return false;
}
const GetIsInstalledFn = struct { _pad: bool = false };

fn installStateImpl(_: *InstallStateFn) []const u8 {
    return "disabled";
}
const InstallStateFn = struct { _pad: bool = false };

fn runningStateImpl(_: *RunningStateFn) []const u8 {
    return "running";
}
const RunningStateFn = struct { _pad: bool = false };

/// Build the whole chrome object (called from Window.getChrome).
/// Returned as a plain value; the bridge serializes it with own props.
const csi_data: CsiFn = .{};
const loadtimes_data: LoadTimesFn = .{};
const getdetails_data: GetDetailsFn = .{};
const getisinstalled_data: GetIsInstalledFn = .{};
const installstate_data: InstallStateFn = .{};
const runningstate_data: RunningStateFn = .{};

pub fn buildChrome(exec: *const Execution) !ChromeObject {
    const local = exec.js.local.?;
    return .{
        .app = .{
            .isInstalled = false,
            .InstallState = .{},
            .RunningState = .{
                .DISABLED = "cannot_run",
                .INSTALLED_NOT_RUNNING = "ready_to_run",
                .INSTALLED_RUNNING = "running",
            },
            .getDetails = local.newCallback(getDetailsImpl, @constCast(&getdetails_data)),
            .getIsInstalled = local.newCallback(getIsInstalledImpl, @constCast(&getisinstalled_data)),
            .installState = local.newCallback(installStateImpl, @constCast(&installstate_data)),
            .runningState = local.newCallback(runningStateImpl, @constCast(&runningstate_data)),
        },
        .csi = local.newCallback(csiImpl, @constCast(&csi_data)),
        .loadTimes = local.newCallback(loadTimesImpl, @constCast(&loadtimes_data)),
    };
}
