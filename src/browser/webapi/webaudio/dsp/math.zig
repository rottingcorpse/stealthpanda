// Copyright (C) 2023-2026  Lightpanda (Selecy SAS)
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

// Audio fingerprinting hashes the rendered samples, and the compressor's
// binary search flips on a single ulp. Chrome's float functions behave as the
// correctly rounded double result, so the f32 ones here round libm's double.

const std = @import("std");

// STEALTHPANDA: identity switch — stood-down (internal test) builds keep the
// stock float paths; see stealth/identity.zig `enabled`.
const stealth_identity = @import("../../../../stealth/identity.zig");

extern "c" fn pow(x: f64, y: f64) f64;
extern "c" fn exp(x: f64) f64;
extern "c" fn sin(x: f64) f64;
extern "c" fn asin(x: f64) f64;
extern "c" fn log10(x: f64) f64;
extern "c" fn log2(x: f64) f64;
extern "c" fn exp2(x: f64) f64;

pub const pi_f32: f32 = @floatCast(std.math.pi);
pub const pi_over_two_f32: f32 = @floatCast(std.math.pi / 2.0);

fn powf(x: f32, y: f32) f32 {
    return @floatCast(pow(x, y));
}

fn log10f(x: f32) f32 {
    return @floatCast(log10(x));
}

pub fn log2f(x: f32) f32 {
    return @floatCast(log2(x));
}

pub fn exp2f(x: f32) f32 {
    return @floatCast(exp2(x));
}

pub fn powd(x: f64, y: f64) f64 {
    @setFloatMode(.strict); // STEALTHPANDA: no FMA contraction in DSP

    return libm.pow(x, y);
}

pub fn expd(x: f64) f64 {
    @setFloatMode(.strict); // STEALTHPANDA: no FMA contraction in DSP

    return libm.exp(x);
}

pub fn sind(x: f64) f64 {
    @setFloatMode(.strict); // STEALTHPANDA: no FMA contraction in DSP

    return libm.sin(x);
}

pub fn asind(x: f64) f64 {
    @setFloatMode(.strict); // STEALTHPANDA: no FMA contraction in DSP

    return libm.asin(x);
}

// STEALTHPANDA: link to libm's powf for exact float parity with Chrome
// (Zig's powf differs from glibc's at the last bit, which accumulates
// to a measurable DSP delta over 1000 samples — measured 8e-6).
const libm = struct {
    extern fn powf(x: f32, y: f32) f32;
    extern fn log10f(x: f32) f32;
    // STEALTHPANDA: f64 functions too — Zig's implementations differ from
    // glibc at the last bits, which accumulates through the compressor kernel.
    extern fn pow(x: f64, y: f64) f64;
    extern fn exp(x: f64) f64;
    extern fn sin(x: f64) f64;
    extern fn asin(x: f64) f64;
};

pub fn decibelsToLinear(decibels: f32) f32 {
    @setFloatMode(.strict); // STEALTHPANDA: no FMA contraction in DSP

    // STEALTHPANDA: stock double-rounds through the f64 extern; the
    // Chrome-parity path calls glibc's float powf directly. Stood-down
    // (internal test) builds keep stock.
    if (!stealth_identity.enabled) return powf(10, 0.05 * decibels);

    return libm.powf(10, 0.05 * decibels);
}

pub fn linearToDecibels(linear: f32) f32 {
    @setFloatMode(.strict); // STEALTHPANDA: no FMA contraction in DSP

    // STEALTHPANDA: stock double-rounds through the f64 extern; stood-down
    // (internal test) builds keep stock.
    if (!stealth_identity.enabled) return 20 * log10f(linear);

    return 20 * libm.log10f(linear);
}

// The per-frame factor k that makes x += (target - x) * k approach target
// with the given time constant.
pub fn discreteTimeConstant(time_constant: f64, sample_rate: f64) f64 {
    return 1 - libm.exp(-1 / (sample_rate * time_constant));
}

pub const Rounding = enum { nearest, down, up };

// Oversampling by a power of two first makes k / sample_rate map back to k for
// most integer k, despite the round-off in the division.
pub fn timeToSampleFrame(time: f64, sample_rate: f64, comptime rounding: Rounding) u64 {
    const oversample: f64 = 1024;
    var frame = @round(time * sample_rate * oversample) / oversample;
    frame = switch (rounding) {
        .nearest => @round(frame),
        .down => @floor(frame),
        .up => @ceil(frame),
    };
    if (frame <= 0) {
        return 0;
    }
    if (frame >= @as(f64, @floatFromInt(std.math.maxInt(u64)))) {
        return std.math.maxInt(u64);
    }
    return @intFromFloat(frame);
}
