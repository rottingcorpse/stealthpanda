// STEALTHPANDA: src/stealth/webapi/Plugins.zig
// navigator.plugins / navigator.mimeTypes with the exact Chromium PDF
// inventory. Stock lightpanda reports an empty PluginArray (length 0) —
// bot.sannysoft flags it red and creepjs blocks the whole plugins block.
//
// Reference data (Chrome 157, this machine, captures/reference-tier1-shapes.json):
//   5 plugins — PDF Viewer, Chrome PDF Viewer, Chromium PDF Viewer,
//   Microsoft Edge PDF Viewer, WebKit built-in PDF — each filename
//   "internal-pdf-viewer", description "Portable Document Format",
//   2 mime types (application/pdf, text/pdf).
//   navigator.mimeTypes — 2 entries, suffixes "pdf", enabledPlugin = the
//   first plugin ("PDF Viewer").
//   PluginArray proto: constructor/item/length/namedItem/refresh.
//
// This module REPLACES the upstream stub registration (PluginArray.zig /
// MimeTypeArray.zig stay untouched upstream; the class registry points
// here instead — see the marked hooks in bridge.zig and Navigator.zig).
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const std = @import("std");

const js = @import("../../browser/js/js.zig");

pub fn registerTypes() []const type {
    return &.{ PluginArray, Plugin, MimeTypeArray, MimeType };
}

// ---------------------------------------------------------------------------
// Data — the Chromium built-in PDF viewer inventory (comptime).
// ---------------------------------------------------------------------------

/// Both mime types resolve enabledPlugin back to plugins_data[0]
/// ("PDF Viewer"), matching the reference capture. Indices, not pointers,
/// to keep the comptime graph acyclic.
const mimetypes_data = [_]MimeType{
    .{ ._type = "application/pdf", ._suffixes = "pdf", ._description = "Portable Document Format", ._plugin_index = 0 },
    .{ ._type = "text/pdf", ._suffixes = "pdf", ._description = "Portable Document Format", ._plugin_index = 0 },
};

const plugins_data = [_]Plugin{
    .{ ._name = "PDF Viewer", ._filename = "internal-pdf-viewer", ._description = "Portable Document Format", ._types = &.{ 0, 1 } },
    .{ ._name = "Chrome PDF Viewer", ._filename = "internal-pdf-viewer", ._description = "Portable Document Format", ._types = &.{ 0, 1 } },
    .{ ._name = "Chromium PDF Viewer", ._filename = "internal-pdf-viewer", ._description = "Portable Document Format", ._types = &.{ 0, 1 } },
    .{ ._name = "Microsoft Edge PDF Viewer", ._filename = "internal-pdf-viewer", ._description = "Portable Document Format", ._types = &.{ 0, 1 } },
    .{ ._name = "WebKit built-in PDF", ._filename = "internal-pdf-viewer", ._description = "Portable Document Format", ._types = &.{ 0, 1 } },
};

// ---------------------------------------------------------------------------

pub const MimeType = struct {
    _pad: bool = false,
    _type: []const u8 = "",
    _suffixes: []const u8 = "",
    _description: []const u8 = "",
    /// Index into `mimetypes_data`.
    _plugin_index: usize = 0,

    fn getType(self: *const MimeType) []const u8 {
        return self._type;
    }

    fn getSuffixes(self: *const MimeType) []const u8 {
        return self._suffixes;
    }

    fn getDescription(self: *const MimeType) []const u8 {
        return self._description;
    }

    fn getEnabledPlugin(self: *const MimeType) *Plugin {
        return @constCast(&plugins_data[self._plugin_index]);
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(MimeType);

        pub const Meta = struct {
            pub const name = "MimeType";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const @"type" = bridge.accessor(MimeType.getType, null, .{});
        pub const suffixes = bridge.accessor(MimeType.getSuffixes, null, .{});
        pub const description = bridge.accessor(MimeType.getDescription, null, .{});
        pub const enabledPlugin = bridge.accessor(MimeType.getEnabledPlugin, null, .{});
    };
};

// ---------------------------------------------------------------------------

pub const Plugin = struct {
    _pad: bool = false,
    _name: []const u8 = "",
    _filename: []const u8 = "",
    _description: []const u8 = "",
    /// Indices into `mimetypes_data`.
    _types: []const usize = &.{},

    fn getName(self: *const Plugin) []const u8 {
        return self._name;
    }

    fn getFilename(self: *const Plugin) []const u8 {
        return self._filename;
    }

    fn getDescription(self: *const Plugin) []const u8 {
        return self._description;
    }

    fn getLength(self: *const Plugin) u32 {
        return @intCast(self._types.len);
    }

    fn getAtIndex(self: *const Plugin, index: usize) ?*MimeType {
        if (index >= self._types.len) return null;
        return @constCast(&mimetypes_data[self._types[index]]);
    }

    fn getByName(self: *const Plugin, name: []const u8) ?*MimeType {
        for (self._types) |mi| {
            const mt = &mimetypes_data[mi];
            if (std.mem.eql(u8, mt._type, name)) return @constCast(mt);
        }
        return null;
    }

    fn item(self: *const Plugin, index: i32) ?*MimeType {
        if (index < 0) return null;
        return getAtIndex(self, @intCast(index));
    }

    fn namedItem(self: *const Plugin, name: []const u8) ?*MimeType {
        return getByName(self, name);
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(Plugin);

        pub const Meta = struct {
            pub const name = "Plugin";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const name = bridge.accessor(Plugin.getName, null, .{});
        pub const filename = bridge.accessor(Plugin.getFilename, null, .{});
        pub const description = bridge.accessor(Plugin.getDescription, null, .{});
        pub const length = bridge.accessor(Plugin.getLength, null, .{});
        pub const item = bridge.function(Plugin.item, .{});
        pub const namedItem = bridge.function(Plugin.namedItem, .{});
        pub const @"[int]" = bridge.indexed(Plugin.getAtIndex, null, .{ .null_as_undefined = true });
        pub const @"[str]" = bridge.namedIndexed(Plugin.getByName, null, null, null, null, .{ .null_as_undefined = true });
    };
};

// ---------------------------------------------------------------------------

pub const PluginArray = struct {
    _pad: bool = false,

    fn getLength(_: *const PluginArray) u32 {
        return plugins_data.len;
    }

    fn getAtIndex(_: *const PluginArray, index: usize) ?*Plugin {
        if (index >= plugins_data.len) return null;
        return @constCast(&plugins_data[index]);
    }

    fn getByName(_: *const PluginArray, name: []const u8) ?*Plugin {
        for (&plugins_data) |*p| {
            if (std.mem.eql(u8, p._name, name)) return @constCast(p);
        }
        return null;
    }

    fn item(self: *const PluginArray, index: i32) ?*Plugin {
        if (index < 0) return null;
        return getAtIndex(self, @intCast(index));
    }

    fn namedItem(self: *const PluginArray, name: []const u8) ?*Plugin {
        return getByName(self, name);
    }

    fn refresh(_: *const PluginArray) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(PluginArray);

        pub const Meta = struct {
            pub const name = "PluginArray";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const length = bridge.accessor(PluginArray.getLength, null, .{});
        pub const item = bridge.function(PluginArray.item, .{});
        pub const namedItem = bridge.function(PluginArray.namedItem, .{});
        pub const refresh = bridge.function(PluginArray.refresh, .{ .noop = true });
        pub const @"[int]" = bridge.indexed(PluginArray.getAtIndex, null, .{ .null_as_undefined = true });
        pub const @"[str]" = bridge.namedIndexed(PluginArray.getByName, null, null, null, struct {
            fn wrap(_: *const PluginArray, _: []const u8) !u32 {
                return error.NotHandled;
            }
        }.wrap, .{ .null_as_undefined = true });
    };
};

// ---------------------------------------------------------------------------

pub const MimeTypeArray = struct {
    _pad: bool = false,

    fn getLength(_: *const MimeTypeArray) u32 {
        return mimetypes_data.len;
    }

    fn getAtIndex(_: *const MimeTypeArray, index: usize) ?*MimeType {
        if (index >= mimetypes_data.len) return null;
        return @constCast(&mimetypes_data[index]);
    }

    fn getByName(_: *const MimeTypeArray, name: []const u8) ?*MimeType {
        for (&mimetypes_data) |*m| {
            if (std.mem.eql(u8, m._type, name)) return @constCast(m);
        }
        return null;
    }

    fn item(self: *const MimeTypeArray, index: i32) ?*MimeType {
        if (index < 0) return null;
        return getAtIndex(self, @intCast(index));
    }

    fn namedItem(self: *const MimeTypeArray, name: []const u8) ?*MimeType {
        return getByName(self, name);
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(MimeTypeArray);

        pub const Meta = struct {
            pub const name = "MimeTypeArray";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const length = bridge.accessor(MimeTypeArray.getLength, null, .{});
        pub const item = bridge.function(MimeTypeArray.item, .{});
        pub const namedItem = bridge.function(MimeTypeArray.namedItem, .{});
        pub const @"[int]" = bridge.indexed(MimeTypeArray.getAtIndex, null, .{ .null_as_undefined = true });
        pub const @"[str]" = bridge.namedIndexed(MimeTypeArray.getByName, null, null, null, null, .{ .null_as_undefined = true });
    };
};
