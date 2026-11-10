// STEALTHPANDA: src/stealth/webapi/root.zig
// Convenience re-export root so upstream hook files need exactly ONE
// import line for the whole Tier-1 surface set.

pub const ChromeNamespace = @import("ChromeNamespace.zig");
pub const SpeechSynthesis = @import("SpeechSynthesis.zig").SpeechSynthesis;
pub const SpeechSynthesisVoice = @import("SpeechSynthesis.zig").SpeechSynthesisVoice;
pub const NetworkInformation = @import("NetworkInformation.zig").NetworkInformation;
pub const MediaDevices = @import("MediaDevices.zig").MediaDevices;
pub const GPU = @import("GpuAndRTC.zig").GPU;
pub const RTCPeerConnection = @import("GpuAndRTC.zig").RTCPeerConnection;
pub const WebGL2RenderingContext = @import("WebGL.zig").WebGL2RenderingContext;
pub const ShaderPrecisionFormat = @import("WebGL.zig").ShaderPrecisionFormat;
pub const PluginArray = @import("Plugins.zig").PluginArray;
pub const Plugin = @import("Plugins.zig").Plugin;
pub const MimeTypeArray = @import("Plugins.zig").MimeTypeArray;
pub const MimeType = @import("Plugins.zig").MimeType;
