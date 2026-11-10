// STEALTHPANDA: src/stealth/webapi/WebGL.zig
// Fingerprint-grade WebGL surface. Stock lightpanda answers getParameter
// with "" and Canvas.getContext('webgl') returns null — creepjs reports the
// whole WebGL block "blocked", bot.sannysoft shows "Canvas has no webgl
// context", and bladebro's vectors/battery fail every gl* probe.
//
// This module supplies the *identity* half of WebGL: every parameter,
// extension, precision and attribute answer comes from
// src/stealth/gl_profile.zig (one coherent profile — same answers in
// window, worker and iframe contexts). Drawing operations are no-op
// successes (fingerprint detectors read parameters; they do not diff
// rendered pixels against a reference GPU — creepjs hashes our canvas and
// compares it to ITSELF for stability, which no-ops satisfy).
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const std = @import("std");

const js = @import("../../browser/js/js.zig");
const gl = @import("../gl_profile.zig");
const Frame = @import("../../browser/Frame.zig");

pub fn registerTypes() []const type {
    return &.{ ShaderPrecisionFormat, WebGL2RenderingContext, WebGL2DebugRendererInfo };
}

/// WEBGL_debug_renderer_info extension object for webgl2 contexts.
pub const WebGL2DebugRendererInfo = struct {
    _pad: bool = false,

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGL2DebugRendererInfo);

        pub const Meta = struct {
            pub const name = "WEBGLDebugRendererInfo";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const UNMASKED_VENDOR_WEBGL = bridge.property(0x9245, .{ .template = false });
        pub const UNMASKED_RENDERER_WEBGL = bridge.property(0x9246, .{ .template = false });
    };
};

/// Polymorphic getParameter answer. The bridge serializes a tagged union
/// as its active payload (Local.zig zigValueToJs .@"union" branch).
pub const GLValue = union(enum) {
    str: []const u8,
    int: u32,
    boolean: bool,
    floats: [4]f32,
};

/// The probe-relevant + commonly feature-detected method names every real
/// WebGL context answers (kept identical for WebGL1 and WebGL2 contexts).
const COMMON_NOOP_METHODS = [_][]const u8{
    "activeTexture",                     "attachShader",         "bindAttribLocation",
    "bindBuffer",                        "bindFramebuffer",      "bindRenderbuffer",
    "bindTexture",                       "blendColor",           "blendEquation",
    "blendEquationSeparate",             "blendFunc",            "blendFuncSeparate",
    "bufferData",                        "bufferSubData",        "checkFramebufferStatus",
    "clear",                             "clearColor",           "clearDepth",
    "clearStencil",                      "colorMask",            "compileShader",
    "copyTexImage2D",                    "copyTexSubImage2D",    "cullFace",
    "deleteBuffer",                      "deleteFramebuffer",    "deleteProgram",
    "deleteRenderbuffer",                "deleteShader",         "deleteTexture",
    "depthFunc",                         "depthMask",            "depthRange",
    "detachShader",                      "disable",              "disableVertexAttribArray",
    "drawArrays",                        "drawElements",         "enable",
    "enableVertexAttribArray",           "finish",               "flush",
    "framebufferRenderbuffer",           "framebufferTexture2D", "frontFace",
    "generateMipmap",                    "getBufferParameter",   "getError",
    "getFramebufferAttachmentParameter", "getProgramParameter",  "getProgramInfoLog",
    "getRenderbufferParameter",          "getShaderInfoLog",     "getShaderParameter",
    "getShaderSource",                   "getTexParameter",      "getUniform",
    "getUniformLocation",                "getVertexAttrib",      "getVertexAttribOffset",
    "hint",                              "isBuffer",             "isEnabled",
    "isFramebuffer",                     "isProgram",            "isRenderbuffer",
    "isShader",                          "isTexture",            "lineWidth",
    "linkProgram",                       "pixelStorei",          "polygonOffset",
    "readPixels",                        "renderbufferStorage",  "sampleCoverage",
    "scissor",                           "shaderSource",         "stencilFunc",
    "stencilMask",                       "stencilOp",            "texImage2D",
    "texParameterf",                     "texParameteri",        "texSubImage2D",
    "uniform1f",                         "uniform2f",            "uniform3f",
    "uniform4f",                         "useProgram",           "validateProgram",
    "vertexAttrib1f",                    "vertexAttribPointer",  "viewport",
};

pub const ShaderPrecisionFormat = struct {
    _range_min: i32,
    _range_max: i32,
    _precision: i32,

    fn getRangeMin(self: *const ShaderPrecisionFormat) u32 {
        return @intCast(self._range_min);
    }

    fn getRangeMax(self: *const ShaderPrecisionFormat) u32 {
        return @intCast(self._range_max);
    }

    fn getPrecision(self: *const ShaderPrecisionFormat) u32 {
        return @intCast(self._precision);
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(ShaderPrecisionFormat);

        pub const Meta = struct {
            pub const name = "WebGLShaderPrecisionFormat";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const rangeMin = bridge.accessor(ShaderPrecisionFormat.getRangeMin, null, .{});
        pub const rangeMax = bridge.accessor(ShaderPrecisionFormat.getRangeMax, null, .{});
        pub const precision = bridge.accessor(ShaderPrecisionFormat.getPrecision, null, .{});
    };
};

/// getParameter dispatch shared by WebGL1 and WebGL2.
pub fn parameterDispatch(pname: u32) GLValue {
    if (gl.parameterString(pname)) |s| return .{ .str = s };
    if (gl.parameterInt(pname)) |v| return .{ .int = v };
    return switch (pname) {
        0x0D4A => .{ .floats = .{ 16384, 16384, 0, 0 } }, // MAX_VIEWPORT_DIMS
        0x0B49 => .{ .floats = .{ 1, 255, 0, 0 } }, // ALIASED_POINT_SIZE_RANGE
        0x0B50 => .{ .floats = .{ 1, 1, 0, 0 } }, // ALIASED_LINE_WIDTH_RANGE
        0x0D55 => .{ .int = gl.red_bits }, // RED_BITS
        0x0D56 => .{ .int = gl.green_bits }, // GREEN_BITS
        0x0D57 => .{ .int = gl.blue_bits }, // BLUE_BITS
        0x0D58 => .{ .int = gl.alpha_bits }, // ALPHA_BITS
        0x0D59 => .{ .int = gl.depth_bits }, // DEPTH_BITS
        0x0D5A => .{ .int = gl.subpixel_bits }, // SUBPIXEL_BITS
        else => .{ .int = 0 }, // unknown enums: 0 is the GL default
    };
}

/// getShaderPrecisionFormat(shaderType, precisionType) — profile-driven.
/// Mesa i915 class: every float level answers the HIGH values (remap),
/// ints answer the int table.
pub fn precisionFor(shader_type: u32, precision_type: u32) *ShaderPrecisionFormat {
    _ = shader_type;
    return switch (precision_type) {
        36336, 36337, 36338 => &float_precision_instance, // LOW/MEDIUM/HIGH FLOAT
        else => &int_precision_instance, // int levels (and unknowns)
    };
}

var float_precision_instance: ShaderPrecisionFormat = blk: {
    const p = gl.shaderPrecisionFloat(36338);
    break :blk .{ ._range_min = p.range_min, ._range_max = p.range_max, ._precision = p.precision };
};

var int_precision_instance: ShaderPrecisionFormat = blk: {
    const p = gl.shaderPrecisionInt(36341);
    break :blk .{ ._range_min = p.range_min, ._range_max = p.range_max, ._precision = p.precision };
};

/// Context attributes (battery glCtxAttrs / vectors).
pub fn contextAttrs() gl.ContextAttributes {
    return .{};
}

pub const WebGL2RenderingContext = struct {
    _pad: bool = false,

    fn getParameter(_: *const WebGL2RenderingContext, pname: u32) GLValue {
        return switch (pname) {
            0x8D6A => .{ .int = 16 }, // MAX_DRAW_BUFFERS (webgl2)
            36183 => .{ .int = gl.max_samples }, // MAX_SAMPLES
            0x9122 => .{ .int = 4 }, // MAX_COLOR_ATTACHMENTS
            0x8CDF => .{ .int = 16384 }, // MAX_3D_TEXTURE_SIZE
            0x904D => .{ .int = 2048 }, // MAX_ARRAY_TEXTURE_LAYERS
            0x9115 => .{ .int = 256 }, // MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS
            else => parameterDispatch(pname),
        };
    }

    fn getSupportedExtensions(_: *const WebGL2RenderingContext) []const []const u8 {
        return &gl.webgl2_extensions;
    }

    fn getShaderPrecisionFormat(_: *const WebGL2RenderingContext, shader_type: u32, precision_type: u32) *ShaderPrecisionFormat {
        return precisionFor(shader_type, precision_type);
    }

    fn getContextAttributes(_: *const WebGL2RenderingContext) gl.ContextAttributes {
        return contextAttrs();
    }

    fn getError(_: *const WebGL2RenderingContext) u32 {
        return 0; // NO_ERROR
    }

    /// WEBGL_debug_renderer_info for webgl2 (the upstream Extension union
    /// only serves the WebGL1 class; glInfo's try/catch turns a missing
    /// method into a null context).
    fn getExtension(_: *const WebGL2RenderingContext, name: []const u8, exec: *js.Execution) !?*WebGL2DebugRendererInfo {
        if (!std.mem.eql(u8, name, "WEBGL_debug_renderer_info")) return null;
        return exec._factory.create(WebGL2DebugRendererInfo{});
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGL2RenderingContext);

        pub const Meta = struct {
            pub const name = "WebGL2RenderingContext";
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const getParameter = bridge.function(WebGL2RenderingContext.getParameter, .{});
        pub const getSupportedExtensions = bridge.function(WebGL2RenderingContext.getSupportedExtensions, .{});
        pub const getShaderPrecisionFormat = bridge.function(WebGL2RenderingContext.getShaderPrecisionFormat, .{});
        pub const getContextAttributes = bridge.function(WebGL2RenderingContext.getContextAttributes, .{});
        pub const getError = bridge.function(WebGL2RenderingContext.getError, .{});
        pub const getExtension = bridge.function(WebGL2RenderingContext.getExtension, .{});

        // STEALTHPANDA: GL enum constants (spec values) + webgl2-only ones.
        const prop = bridge.property;
        pub const VENDOR = prop(7936, .{ .template = false });
        pub const RENDERER = prop(7937, .{ .template = false });
        pub const VERSION = prop(7938, .{ .template = false });
        pub const SHADING_LANGUAGE_VERSION = prop(35724, .{ .template = false });
        pub const MAX_TEXTURE_SIZE = prop(3379, .{ .template = false });
        pub const MAX_COMBINED_TEXTURE_IMAGE_UNITS = prop(35661, .{ .template = false });
        pub const MAX_SAMPLES = prop(36183, .{ .template = false });
        pub const MAX_DRAW_BUFFERS = prop(34852, .{ .template = false });
        pub const MAX_COLOR_ATTACHMENTS = prop(36063, .{ .template = false });
        pub const MAX_3D_TEXTURE_SIZE = prop(32883, .{ .template = false });
        pub const MAX_ARRAY_TEXTURE_LAYERS = prop(35071, .{ .template = false });
        pub const FRAGMENT_SHADER = prop(35632, .{ .template = false });
        pub const VERTEX_SHADER = prop(35633, .{ .template = false });
        pub const LOW_FLOAT = prop(36336, .{ .template = false });
        pub const MEDIUM_FLOAT = prop(36337, .{ .template = false });
        pub const HIGH_FLOAT = prop(36338, .{ .template = false });
        pub const LOW_INT = prop(36339, .{ .template = false });
        pub const MEDIUM_INT = prop(36340, .{ .template = false });
        pub const HIGH_INT = prop(36341, .{ .template = false });
    };
};
