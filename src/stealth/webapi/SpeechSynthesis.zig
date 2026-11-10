// STEALTHPANDA: src/stealth/webapi/SpeechSynthesis.zig
// Web Speech API surface (the `speechSynthesis` global). Stock lightpanda
// lacks it entirely — bladebro's battery.js AND vectors.html crash on
// `speechSynthesis.getVoices()`, and creepjs reports the whole Speech block
// "blocked".
//
// Shape follows the reference capture of Chrome-for-Testing 157.0.8103.38
// on this machine (captures/reference-tier1-shapes.json):
//   typeof "object"; getVoices() -> [] (voiceless host: reference Chrome
//   answers the same); pending/speaking/paused = false; proto keys
//   cancel/getVoices/onvoiceschanged/pause/paused/pending/resume/speak/
//   speaking.
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const js = @import("../../browser/js/js.zig");

pub fn registerTypes() []const type {
    return &.{ SpeechSynthesis, SpeechSynthesisVoice };
}

pub const SpeechSynthesis = struct {
    _pad: bool = false,

    fn getVoices(_: *const SpeechSynthesis) []*SpeechSynthesisVoice {
        // Truthful for this host class: the reference Chrome on the same
        // machine also returns zero voices.
        return &.{};
    }

    fn getPending(_: *const SpeechSynthesis) bool {
        return false;
    }

    fn getSpeaking(_: *const SpeechSynthesis) bool {
        return false;
    }

    fn getPaused(_: *const SpeechSynthesis) bool {
        return false;
    }

    fn getOnVoicesChanged(_: *const SpeechSynthesis) ?js.Value {
        return null;
    }

    fn speak(_: *SpeechSynthesis, utterance: js.Value) void {
        // No speech backend on this host; the utterance is accepted and
        // silently dropped (a voiceless desktop fires no audible difference).
        _ = utterance;
    }

    fn cancel(_: *SpeechSynthesis) void {}
    fn pause(_: *SpeechSynthesis) void {}
    fn @"resume"(_: *SpeechSynthesis) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SpeechSynthesis);

        pub const Meta = struct {
            pub const name = "SpeechSynthesis";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const pending = bridge.accessor(SpeechSynthesis.getPending, null, .{});
        pub const speaking = bridge.accessor(SpeechSynthesis.getSpeaking, null, .{});
        pub const paused = bridge.accessor(SpeechSynthesis.getPaused, null, .{});
        pub const onvoiceschanged = bridge.accessor(SpeechSynthesis.getOnVoicesChanged, null, .{});
        pub const getVoices = bridge.function(SpeechSynthesis.getVoices, .{});
        pub const speak = bridge.function(SpeechSynthesis.speak, .{ .noop = true });
        pub const cancel = bridge.function(SpeechSynthesis.cancel, .{ .noop = true });
        pub const pause = bridge.function(SpeechSynthesis.pause, .{ .noop = true });
        pub const @"resume" = bridge.function(SpeechSynthesis.@"resume", .{ .noop = true });
    };
};

pub const SpeechSynthesisVoice = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SpeechSynthesisVoice);

        pub const Meta = struct {
            pub const name = "SpeechSynthesisVoice";
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};
