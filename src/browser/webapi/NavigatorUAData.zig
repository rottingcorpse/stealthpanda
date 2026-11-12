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

const builtin = @import("builtin");

const Config = @import("../../Config.zig");
const js = @import("../js/js.zig");
const Execution = js.Execution;

const NavigatorUAData = @This();

_pad: bool = false,

const Brand = struct {
    brand: []const u8,
    version: []const u8,
};

fn getBrands(_: *const NavigatorUAData) []const Brand {
    return brandList();
}

fn getMobile(_: *const NavigatorUAData) bool {
    return false;
}

fn getPlatform(_: *const NavigatorUAData) []const u8 {
    return uaPlatform();
}

pub fn toJSON(_: *const NavigatorUAData) struct {
    brands: []const Brand,
    mobile: bool,
    platform: []const u8,
} {
    return .{
        .mobile = false,
        .brands = brandList(),
        .platform = uaPlatform(),
    };
}

fn getHighEntropyValues(_: *const NavigatorUAData, hints: []const []const u8, exec: *const Execution) !js.Promise {
    // This should always return `brands` + `mobile` + `platform` and then whatever
    // "hints" field is requested (assuming the browser has permission), but it's
    // also valid to just return everything.

    _ = hints;

    // STEALTHPANDA: stood-down (internal test) builds answer with the stock
    // lightpanda payload, verbatim, including its builtin-derived fields.
    if (!stealth_identity.enabled) {
        const brands = brandList();
        return exec.js.local.?.resolvePromise(.{
            .brands = brands,
            .mobile = false,
            .platform = uaPlatform(),
            .architecture = uaArchitecture(),
            .bitness = uaBitness(),
            .model = "",
            .platformVersion = "",
            .uaFullVersion = if (brands.len > 0) brands[0].version else "1.0.0.0",
            .fullVersionList = brands,
            .wow64 = false,
            .formFactors = [_][]const u8{"Desktop"},
        });
    }

    // STEALTHPANDA: brand lists split to match stock Chrome exactly:
    // brands/fullVersionList split + platformVersion/formFactors shape.
    const brands_major = brandList();
    const brands_full = fullBrandList();

    return exec.js.local.?.resolvePromise(.{
        .brands = brands_major,
        .mobile = stealth_identity.mobile,
        .platform = uaPlatform(),
        .architecture = stealth_identity.architecture,
        .bitness = stealth_identity.bitness,
        .model = stealth_identity.model,
        .platformVersion = stealth_identity.platform_version,
        .uaFullVersion = if (brands_full.len > 0) brands_full[0].version else "1.0.0.0",
        .fullVersionList = brands_full,
        .wow64 = stealth_identity.wow64,
        .formFactors = stealth_identity.form_factors,
    });
}

// STEALTHPANDA: identity source (src/stealth/identity.zig). Stock code
// returned FULL versions in navigator.userAgentData.brands; stock Chrome
// exposes major-only there and keeps full versions for fullVersionList.
const stealth_identity = @import("../../stealth/identity.zig");

fn brandList() []const Brand {
    // STEALTHPANDA: stood-down (internal test) builds report the stock
    // single Lightpanda brand with its FULL version (stock semantics).
    if (!stealth_identity.enabled) {
        const out = comptime blk: {
            const src = &Config.HttpHeaders.lp_brands;
            var arr: [src.len]Brand = undefined;
            for (src, 0..) |b, i| {
                arr[i] = .{ .brand = b.brand, .version = b.full_version };
            }
            const final = arr;
            break :blk final;
        };
        return &out;
    }
    const out = comptime blk: {
        const src = &Config.HttpHeaders.brands;
        var arr: [src.len]Brand = undefined;
        for (src, 0..) |b, i| {
            arr[i] = .{ .brand = b.brand, .version = b.version };
        }
        const final = arr;
        break :blk final;
    };
    return &out;
}

fn fullBrandList() []const Brand {
    const out = comptime blk: {
        var arr: [stealth_identity.brand_table.len]Brand = undefined;
        for (stealth_identity.brand_table, 0..) |b, i| {
            arr[i] = .{ .brand = b.brand, .version = b.full };
        }
        const final = arr;
        break :blk final;
    };
    return &out;
}

fn uaPlatform() []const u8 {
    return switch (builtin.target.os.tag) {
        .macos => "macOS",
        .windows => "Windows",
        .linux => "Linux",
        .freebsd => "FreeBSD",
        else => "Unknown",
    };
}

fn uaArchitecture() []const u8 {
    return switch (builtin.target.cpu.arch) {
        .x86, .x86_64 => "x86",
        .aarch64, .aarch64_be, .arm, .armeb => "arm",
        else => "",
    };
}

fn uaBitness() []const u8 {
    return switch (builtin.target.cpu.arch) {
        .x86_64, .aarch64, .aarch64_be, .powerpc64, .powerpc64le, .riscv64 => "64",
        else => "32",
    };
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(NavigatorUAData);

    pub const Meta = struct {
        pub const name = "NavigatorUAData";
        pub var class_id: bridge.ClassId = undefined;
        pub const empty_with_no_proto = true;
    };

    pub const brands = bridge.accessor(NavigatorUAData.getBrands, null, .{});
    pub const mobile = bridge.accessor(NavigatorUAData.getMobile, null, .{});
    pub const platform = bridge.accessor(NavigatorUAData.getPlatform, null, .{});
    pub const toJSON = bridge.function(NavigatorUAData.toJSON, .{});
    pub const getHighEntropyValues = bridge.function(NavigatorUAData.getHighEntropyValues, .{});
};
