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

const js = @import("../../js/js.zig");
const Frame = @import("../../Frame.zig");
const Execution = js.Execution;

// STEALTHPANDA: fingerprint-grade GL answers (src/stealth/).
const stealth_gl = @import("../../../stealth/gl_profile.zig");
const stealth_webgl = @import("../../../stealth/webapi/WebGL.zig");

pub fn registerTypes() []const type {
    return &.{
        WebGLRenderingContext,
        // Extension types should be runtime generated. We might want
        // to revisit this.
        Extension.Type.WEBGL_debug_renderer_info,
        Extension.Type.WEBGL_lose_context,
    };
}

const WebGLRenderingContext = @This();

_pad: bool = false,

/// On Chrome and Safari, a call to `getSupportedExtensions` returns total of 39.
/// The reference for it lists lesser number of extensions:
/// https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Using_Extensions#extension_list
const Extension = union(enum) {
    ANGLE_instanced_arrays: void,
    EXT_blend_minmax: void,
    EXT_clip_control: void,
    EXT_color_buffer_half_float: void,
    EXT_depth_clamp: void,
    EXT_disjoint_timer_query: void,
    EXT_float_blend: void,
    EXT_frag_depth: void,
    EXT_polygon_offset_clamp: void,
    EXT_shader_texture_lod: void,
    EXT_texture_compression_bptc: void,
    EXT_texture_compression_rgtc: void,
    EXT_texture_filter_anisotropic: void,
    EXT_texture_mirror_clamp_to_edge: void,
    EXT_sRGB: void,
    KHR_parallel_shader_compile: void,
    OES_element_index_uint: void,
    OES_fbo_render_mipmap: void,
    OES_standard_derivatives: void,
    OES_texture_float: void,
    OES_texture_float_linear: void,
    OES_texture_half_float: void,
    OES_texture_half_float_linear: void,
    OES_vertex_array_object: void,
    WEBGL_blend_func_extended: void,
    WEBGL_color_buffer_float: void,
    WEBGL_compressed_texture_astc: void,
    WEBGL_compressed_texture_etc: void,
    WEBGL_compressed_texture_etc1: void,
    WEBGL_compressed_texture_pvrtc: void,
    WEBGL_compressed_texture_s3tc: void,
    WEBGL_compressed_texture_s3tc_srgb: void,
    WEBGL_debug_renderer_info: *Type.WEBGL_debug_renderer_info,
    WEBGL_debug_shaders: void,
    WEBGL_depth_texture: void,
    WEBGL_draw_buffers: void,
    WEBGL_lose_context: *Type.WEBGL_lose_context,
    WEBGL_multi_draw: void,
    WEBGL_polygon_mode: void,

    /// Reified enum type from the fields of this union.
    const Kind = blk: {
        const names = @typeInfo(Extension).@"union".field_names;
        const Tag = std.math.IntFittingRange(0, if (names.len == 0) 0 else names.len - 1);
        break :blk @Enum(Tag, .exhaustive, names, &std.simd.iota(Tag, names.len));
    };

    /// Returns the `Extension.Kind` by its name.
    fn find(name: []const u8) ?Kind {
        // Just to make you really sad, this function has to be case-insensitive.
        // So here we copy what's being done in `std.meta.stringToEnum` but replace
        // the comparison function.
        const kvs = comptime build_kvs: {
            const T = Extension.Kind;
            const EnumKV = struct { []const u8, T };
            var kvs_array: [@typeInfo(T).@"enum".field_names.len]EnumKV = undefined;
            for (@typeInfo(T).@"enum".field_names, 0..) |field_name, i| {
                kvs_array[i] = .{ field_name, @field(T, field_name) };
            }
            break :build_kvs kvs_array[0..];
        };
        const Map = std.StaticStringMapWithEql(Extension.Kind, std.static_string_map.eqlAsciiIgnoreCase);
        const map = Map.initComptime(kvs);
        return map.get(name);
    }

    /// Extension types.
    pub const Type = struct {
        pub const WEBGL_debug_renderer_info = struct {
            _: u8 = 0,
            const UNMASKED_VENDOR_WEBGL: u64 = 0x9245;
            const UNMASKED_RENDERER_WEBGL: u64 = 0x9246;

            pub const JsApi = struct {
                pub const bridge = js.Bridge(WEBGL_debug_renderer_info);

                pub const Meta = struct {
                    pub const name = "WEBGL_debug_renderer_info";

                    pub var class_id: bridge.ClassId = undefined;
                };

                pub const UNMASKED_VENDOR_WEBGL = bridge.property(WEBGL_debug_renderer_info.UNMASKED_VENDOR_WEBGL, .{ .template = false, .readonly = true });
                pub const UNMASKED_RENDERER_WEBGL = bridge.property(WEBGL_debug_renderer_info.UNMASKED_RENDERER_WEBGL, .{ .template = false, .readonly = true });
            };
        };

        pub const WEBGL_lose_context = struct {
            _: u8 = 0,
            fn loseContext(_: *const WEBGL_lose_context) void {}
            fn restoreContext(_: *const WEBGL_lose_context) void {}

            pub const JsApi = struct {
                pub const bridge = js.Bridge(WEBGL_lose_context);

                pub const Meta = struct {
                    pub const name = "WEBGL_lose_context";

                    pub var class_id: bridge.ClassId = undefined;
                };

                pub const loseContext = bridge.function(WEBGL_lose_context.loseContext, .{ .noop = true });
                pub const restoreContext = bridge.function(WEBGL_lose_context.restoreContext, .{ .noop = true });
            };
        };
    };
};

/// This actually takes "GLenum" which, in fact, is a fancy way to say number.
/// STEALTHPANDA: answers come from the stealth GL profile (coherent across
/// window/worker/iframe); the stock stub answered "" for everything.
fn getParameter(_: *const WebGLRenderingContext, pname: u32) stealth_webgl.GLValue {
    return stealth_webgl.parameterDispatch(pname);
}

/// getShaderPrecisionFormat — profile-driven (Mesa i915 class remap).
fn getShaderPrecisionFormat(
    _: *const WebGLRenderingContext,
    shader_type: u32,
    precision_type: u32,
) *stealth_webgl.ShaderPrecisionFormat {
    return stealth_webgl.precisionFor(shader_type, precision_type);
}

/// Context attributes (battery glCtxAttrs).
fn getContextAttributes(_: *const WebGLRenderingContext) stealth_gl.ContextAttributes {
    return stealth_webgl.contextAttrs();
}

/// Enables a WebGL extension.
/// STEALTHPANDA: gated by the profile's extension list (absent extensions
/// must return null — bladebro's gl-ext-blocked-call pin).
fn getExtension(_: *const WebGLRenderingContext, name: []const u8, exec: *Execution) !?Extension {
    if (!stealth_gl.webgl1ExtensionSupported(name)) return null;
    const tag = Extension.find(name) orelse return null;

    return switch (tag) {
        .WEBGL_debug_renderer_info => {
            const info = try exec._factory.create(Extension.Type.WEBGL_debug_renderer_info{});
            return .{ .WEBGL_debug_renderer_info = info };
        },
        .WEBGL_lose_context => {
            const ctx = try exec._factory.create(Extension.Type.WEBGL_lose_context{});
            return .{ .WEBGL_lose_context = ctx };
        },
        inline else => |comptime_enum| @unionInit(Extension, @tagName(comptime_enum), {}),
    };
}

/// Returns a list of all the supported WebGL extensions.
/// STEALTHPANDA: the profile's extension list (not the internal stub enum).
fn getSupportedExtensions(_: *const WebGLRenderingContext) []const []const u8 {
    return &stealth_gl.webgl1_extensions;
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(WebGLRenderingContext);

    pub const Meta = struct {
        pub const name = "WebGLRenderingContext";

        pub var class_id: bridge.ClassId = undefined;
    };

    pub const getParameter = bridge.function(WebGLRenderingContext.getParameter, .{});
    pub const getExtension = bridge.function(WebGLRenderingContext.getExtension, .{});
    pub const getSupportedExtensions = bridge.function(WebGLRenderingContext.getSupportedExtensions, .{});
    // STEALTHPANDA: precision + attributes probes.
    pub const getShaderPrecisionFormat = bridge.function(WebGLRenderingContext.getShaderPrecisionFormat, .{});
    pub const getContextAttributes = bridge.function(WebGLRenderingContext.getContextAttributes, .{});

    // STEALTHPANDA: GL enum constants (spec values). Without them on the
    // prototype, `g.VENDOR` is undefined and probes read getParameter(0).
    const prop = bridge.property;
    pub const VENDOR = prop(7936, .{ .template = false });
    pub const RENDERER = prop(7937, .{ .template = false });
    pub const VERSION = prop(7938, .{ .template = false });
    pub const SHADING_LANGUAGE_VERSION = prop(35724, .{ .template = false });
    pub const MAX_TEXTURE_SIZE = prop(3379, .{ .template = false });
    pub const MAX_CUBE_MAP_TEXTURE_SIZE = prop(34076, .{ .template = false });
    pub const MAX_VERTEX_ATTRIBS = prop(34921, .{ .template = false });
    pub const MAX_VERTEX_UNIFORM_VECTORS = prop(36347, .{ .template = false });
    pub const MAX_VARYING_VECTORS = prop(36348, .{ .template = false });
    pub const MAX_FRAGMENT_UNIFORM_VECTORS = prop(36349, .{ .template = false });
    pub const MAX_VERTEX_TEXTURE_IMAGE_UNITS = prop(35660, .{ .template = false });
    pub const MAX_TEXTURE_IMAGE_UNITS = prop(34930, .{ .template = false });
    pub const MAX_COMBINED_TEXTURE_IMAGE_UNITS = prop(35661, .{ .template = false });
    pub const MAX_VIEWPORT_DIMS = prop(3386, .{ .template = false });
    pub const ALIASED_POINT_SIZE_RANGE = prop(33901, .{ .template = false });
    pub const ALIASED_LINE_WIDTH_RANGE = prop(33902, .{ .template = false });
    pub const RED_BITS = prop(3410, .{ .template = false });
    pub const GREEN_BITS = prop(3411, .{ .template = false });
    pub const BLUE_BITS = prop(3412, .{ .template = false });
    pub const ALPHA_BITS = prop(3413, .{ .template = false });
    pub const DEPTH_BITS = prop(3414, .{ .template = false });
    pub const STENCIL_BITS = prop(3415, .{ .template = false });
    pub const SUBPIXEL_BITS = prop(3402, .{ .template = false });
    pub const FRAGMENT_SHADER = prop(35632, .{ .template = false });
    pub const VERTEX_SHADER = prop(35633, .{ .template = false });
    pub const LOW_FLOAT = prop(36336, .{ .template = false });
    pub const MEDIUM_FLOAT = prop(36337, .{ .template = false });
    pub const HIGH_FLOAT = prop(36338, .{ .template = false });
    pub const LOW_INT = prop(36339, .{ .template = false });
    pub const MEDIUM_INT = prop(36340, .{ .template = false });
    pub const HIGH_INT = prop(36341, .{ .template = false });
};

// getContext('web-gl') currently returns null, so this cannot be tested
// const testing = @import("../../../testing.zig");
// test "WebApi: WebGLRenderingContext" {
//     try testing.htmlRunner("canvas/webgl_rendering_context.html", .{});
// }
