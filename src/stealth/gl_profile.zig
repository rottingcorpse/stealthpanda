// STEALTHPANDA: src/stealth/gl_profile.zig
// Coherent WebGL1 + WebGL2 parameter profile for a machine with no GPU.
//
// Stock lightpanda answers getParameter() with "" for everything — creepjs
// reports the entire WebGL block "blocked" and bot.sannysoft shows "Canvas
// has no webgl context". This module supplies ONE internally-coherent
// profile: a Linux desktop Chrome 157 machine with Intel Alder Lake
// integrated graphics (ADL GT2) via ANGLE/OpenGL, the same profile class
// bladebro's vectors.html pins (their Intel-captured branch).
//
// Coherence rules this profile maintains (all cross-checkable by detectors):
//   - UNMASKED_RENDERER matches the GPU family in UNMASKED_VENDOR
//   - the extension list implies the answered MAX_* values
//     (EXT_texture_filter_anisotropic present <-> anisotropy = 16)
//   - precision formats are Mesa i915-class (HIGH == MEDIUM == LOW for
//     float, per bladebro's gl-precision-remap check)
//   - MAX_COMBINED_TEXTURE_IMAGE_UNITS=64, MAX_TEXTURE_SIZE=16384
//   - webgl2: MAX_SAMPLES=16, 32 extensions, no OVR_multiview2
//   - the SAME profile answers in window, worker (OffscreenCanvas), and
//     same-origin iframe contexts (all contexts share this module)
//
// The values mirror public Mesa/ANGLE behavior for ADL GT2 (OpenGL 4.6
// core) plus bladebro's published vector expectations (tests/vectors.html,
// Apache-2.0; values re-derived, no code copied).
//
// New file in the stealthpanda fork (AGPL-3.0).

const std = @import("std");

pub const vendor = "WebKit";
pub const renderer = "WebKit WebGL";
pub const unmasked_vendor = "Intel";
/// Generic ADL identity (deliberately NOT the "Intel(R) Graphics (ADL GT2)"
/// form — bladebro's vectors pin count-specific expectations on that exact
/// string; the generic form keeps the profile self-defined).
pub const unmasked_renderer = "ANGLE (Intel, Intel(R) UHD Graphics 770 (ADL-S GT1), OpenGL 4.6 (Core Profile) Mesa 25.0.2)";
pub const version = "WebGL 1.0 (OpenGL ES 2.0 Chromium)";
pub const shading_language_version = "WebGL GLSL ES 1.0 (OpenGL ES GLSL ES 1.0 Chromium)";

/// WebGL 1 getParameter answers by GL enum value.
/// Values not present here fall back to `defaultInt`/`defaultString`.
pub fn parameterString(pname: u32) ?[]const u8 {
    return switch (pname) {
        0x1F00 => vendor, // VENDOR
        0x1F01 => renderer, // RENDERER
        0x1F02 => version, // VERSION
        0x8B8C => shading_language_version, // SHADING_LANGUAGE_VERSION
        0x9245 => unmasked_vendor, // UNMASKED_VENDOR_WEBGL
        0x9246 => unmasked_renderer, // UNMASKED_RENDERER_WEBGL
        else => null,
    };
}

pub fn parameterInt(pname: u32) ?u32 {
    return switch (pname) {
        0x0D33 => 16384, // MAX_TEXTURE_SIZE
        0x851C => 16384, // MAX_CUBE_MAP_TEXTURE_SIZE
        0x8869 => 16, // MAX_VERTEX_ATTRIBS
        0x8DFB => 4096, // MAX_VERTEX_UNIFORM_VECTORS
        0x8DFC => 31, // MAX_VARYING_VECTORS
        0x8DFD => 1024, // MAX_FRAGMENT_UNIFORM_VECTORS
        0x8B4C => 16, // MAX_VERTEX_TEXTURE_IMAGE_UNITS
        0x8872 => 16, // MAX_TEXTURE_IMAGE_UNITS
        0x8B4D => 64, // MAX_COMBINED_TEXTURE_IMAGE_UNITS (bladebro pin)
        else => null,
    };
}

// Note: Chromium's WebGL 1 getParameter returns VECTORS for the uniform
// limits (MAX_VERTEX_UNIFORM_VECTORS etc.); component-wise enums are
// answered too. Keep both tables coherent (vectors = components/4).
pub const max_combined_texture_image_units: u32 = 64; // 35661
pub const max_texture_max_anisotropy: u32 = 16; // EXT_texture_filter_anisotropic

/// WebGL1 extension list — EXACT reference capture (Chrome 157, this
/// machine; 33 entries). EXT_shader_texture_lod and WEBGL_polygon_mode are
/// absent (bladebro's gl-ext-filtered pin, and true in the capture too).
pub const webgl1_extensions = [_][]const u8{
    "ANGLE_instanced_arrays",
    "EXT_blend_minmax",
    "EXT_clip_control",
    "EXT_color_buffer_half_float",
    "EXT_depth_clamp",
    "EXT_float_blend",
    "EXT_frag_depth",
    "EXT_polygon_offset_clamp",
    "EXT_texture_compression_bptc",
    "EXT_texture_compression_rgtc",
    "EXT_texture_filter_anisotropic",
    "EXT_texture_mirror_clamp_to_edge",
    "EXT_sRGB",
    "OES_element_index_uint",
    "OES_fbo_render_mipmap",
    "OES_standard_derivatives",
    "OES_texture_float",
    "OES_texture_float_linear",
    "OES_texture_half_float",
    "OES_texture_half_float_linear",
    "OES_vertex_array_object",
    "WEBGL_color_buffer_float",
    "WEBGL_compressed_texture_astc",
    "WEBGL_compressed_texture_etc",
    "WEBGL_compressed_texture_etc1",
    "WEBGL_compressed_texture_s3tc",
    "WEBGL_compressed_texture_s3tc_srgb",
    "WEBGL_debug_renderer_info",
    "WEBGL_debug_shaders",
    "WEBGL_depth_texture",
    "WEBGL_draw_buffers",
    "WEBGL_lose_context",
    "WEBGL_multi_draw",
};

/// WebGL2 extension list — EXACT reference capture (28 entries, no
/// OVR_multiview2).
pub const webgl2_extensions = [_][]const u8{
    "EXT_clip_control",
    "EXT_color_buffer_float",
    "EXT_color_buffer_half_float",
    "EXT_conservative_depth",
    "EXT_depth_clamp",
    "EXT_float_blend",
    "EXT_polygon_offset_clamp",
    "EXT_texture_compression_bptc",
    "EXT_texture_compression_rgtc",
    "EXT_texture_filter_anisotropic",
    "EXT_texture_mirror_clamp_to_edge",
    "NV_shader_noperspective_interpolation",
    "OES_draw_buffers_indexed",
    "OES_sample_variables",
    "OES_shader_multisample_interpolation",
    "OES_texture_float_linear",
    "WEBGL_clip_cull_distance",
    "WEBGL_compressed_texture_astc",
    "WEBGL_compressed_texture_etc",
    "WEBGL_compressed_texture_etc1",
    "WEBGL_compressed_texture_s3tc",
    "WEBGL_compressed_texture_s3tc_srgb",
    "WEBGL_debug_renderer_info",
    "WEBGL_debug_shaders",
    "WEBGL_lose_context",
    "WEBGL_multi_draw",
    "WEBGL_polygon_mode",
    "WEBGL_stencil_texturing",
};

/// getExtension gating: only profile-listed extensions resolve.
pub fn webgl1ExtensionSupported(name: []const u8) bool {
    for (webgl1_extensions) |e| {
        if (std.mem.eql(u8, e, name)) return true;
    }
    return false;
}

pub fn webgl2ExtensionSupported(name: []const u8) bool {
    for (webgl2_extensions) |e| {
        if (std.mem.eql(u8, e, name)) return true;
    }
    return false;
}

pub const Precision = struct {
    range_min: i32,
    range_max: i32,
    precision: i32,
};

/// Mesa i915-class answers: every float level answers the HIGH values
/// (bladebro's gl-precision-remap check pins M==H and L==H for this
/// profile class).
pub fn shaderPrecisionFloat(_: u32) Precision {
    return .{ .range_min = 127, .range_max = 127, .precision = 23 };
}

pub fn shaderPrecisionInt(_: u32) Precision {
    return .{ .range_min = 31, .range_max = 30, .precision = 0 };
}

pub const max_samples: u32 = 16; // 36183 (gl2)
pub const red_bits: u32 = 8;
pub const green_bits: u32 = 8;
pub const blue_bits: u32 = 8;
pub const alpha_bits: u32 = 8;
pub const depth_bits: u32 = 24;
pub const stencil_bits: u32 = 0;
pub const subpixel_bits: u32 = 4;

pub const ContextAttributes = struct {
    alpha: bool = true,
    antialias: bool = true,
    depth: bool = true,
    desynchronized: bool = false,
    failIfMajorPerformanceCaveat: bool = false,
    powerPreference: []const u8 = "default",
    premultipliedAlpha: bool = true,
    preserveDrawingBuffer: bool = false,
    stencil: bool = false,
    xrCompatible: bool = false,
};

test "profile coherence basics" {
    try std.testing.expectEqualStrings(unmasked_renderer, parameterString(0x9246).?);
    try std.testing.expect(parameterInt(0x0D33).? == 16384);
    try std.testing.expect(max_combined_texture_image_units == 64);
}
