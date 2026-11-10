// STEALTHPANDA: src/stealth/canvas_png.zig
// Minimal PNG encoder for canvas toDataURL — uncompressed deflate (stored
// blocks). Produces a valid PNG whose content depends on the actual pixel
// data, giving a stable, per-drawing-unique canvas fingerprint.
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const std = @import("std");

// PNG signature
const png_signature = [_]u8{ 137, 80, 78, 71, 13, 10, 26, 10 };

// CRC32 for PNG chunks
fn crc32(data: []const u8) u32 {
    var crc: u32 = 0xFFFFFFFF;
    for (data) |b| {
        crc ^= b;
        for (0..8) |_| {
            if (crc & 1 != 0) {
                crc = (crc >> 1) ^ 0xEDB88320;
            } else {
                crc >>= 1;
            }
        }
    }
    return ~crc;
}

fn writeChunk(list: *std.ArrayList(u8), allocator: std.mem.Allocator, chunk_type: []const u8, data: []const u8) !void {
    var len_buf: [4]u8 = undefined;
    std.mem.writeInt(u32, &len_buf, @intCast(data.len), .big);
    try list.appendSlice(allocator, &len_buf);
    try list.appendSlice(allocator, chunk_type);
    try list.appendSlice(allocator, data);
    const crc = crc32(chunk_type) ^ crc32(data);
    std.mem.writeInt(u32, &len_buf, crc, .big);
    try list.appendSlice(allocator, &len_buf);
}

/// Encode RGBA pixel data as a valid PNG (uncompressed deflate).
/// Returns a data URL string (caller must free).
pub fn encodeAsDataUrl(
    allocator: std.mem.Allocator,
    width: usize,
    height: usize,
    rgba: []const u8,
) ![]u8 {
    // Build raw scanlines: each row = 1 filter byte + width*4 bytes
    const stride = width * 4;
    const raw_len = height * (1 + stride);
    const raw = try allocator.alloc(u8, raw_len);
    defer allocator.free(raw);

    for (0..height) |y| {
        const row_start = y * (1 + stride);
        raw[row_start] = 0; // filter: none
        const src = y * stride;
        @memcpy(raw[row_start + 1 .. row_start + 1 + stride], rgba[src .. src + stride]);
    }

    // STEALTHPANDA: compress with zlib (already linked for curl) —
    // Chrome produces ~4KB for the same canvas; uncompressed (stored)
    // produces ~77KB — a 19x size difference that toDataURL-length
    // checks detect instantly.
    const zlib = struct {
        extern fn compress2(
            dest: [*]u8,
            destLen: *usize,
            source: [*]const u8,
            sourceLen: usize,
            level: c_int,
        ) c_int;
    };
    const zlib_level_default: c_int = 6; // Z_DEFAULT_COMPRESSION
    var compressed: std.ArrayList(u8) = .empty;
    defer compressed.deinit(allocator);
    {
        const bound = raw_len + (raw_len / 100) + 12; // zlib bound
        try compressed.ensureTotalCapacity(allocator, bound);
        var compressed_len: usize = bound;
        const rc = zlib.compress2(
            compressed.items.ptr,
            &compressed_len,
            raw.ptr,
            raw_len,
            zlib_level_default,
        );
        if (rc != 0) return error.ZlibCompressFailed;
        compressed.items.len = compressed_len;
    }
    const deflate_data = compressed.items;

    // Build the PNG
    var png: std.ArrayList(u8) = .empty;
    errdefer png.deinit(allocator);
    try png.appendSlice(allocator, &png_signature);

    // IHDR: width, height, bit depth 8, color type 6 (RGBA), compression 0, filter 0, interlace 0
    var ihdr: [13]u8 = undefined;
    std.mem.writeInt(u32, ihdr[0..4], @intCast(width), .big);
    std.mem.writeInt(u32, ihdr[4..8], @intCast(height), .big);
    ihdr[8] = 8; // bit depth
    ihdr[9] = 6; // color type: RGBA
    ihdr[10] = 0; // compression
    ihdr[11] = 0; // filter
    ihdr[12] = 0; // interlace
    try writeChunk(&png, allocator, "IHDR", &ihdr);

    // IDAT: the deflate-wrapped scanlines
    try writeChunk(&png, allocator, "IDAT", deflate_data);

    // IEND
    try writeChunk(&png, allocator, "IEND", &[_]u8{});

    // Base64 encode
    const encoder = std.base64.standard.Encoder;
    const b64_len = encoder.calcSize(png.items.len);
    const prefix = "data:image/png;base64,";
    const total = prefix.len + b64_len;
    const result = try allocator.alloc(u8, total);
    _ = encoder.encode(result[prefix.len..], png.items);
    @memcpy(result[0..prefix.len], prefix);
    png.deinit(allocator);

    return result;
}

test "png encodes different data for different pixels" {
    const a = std.testing.allocator;
    const pixels1 = [_]u8{ 255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 255, 255, 255, 255 };
    const pixels2 = [_]u8{ 0, 255, 0, 255, 255, 0, 0, 255, 0, 0, 255, 255, 128, 128, 128, 255 };

    const url1 = try encodeAsDataUrl(a, 2, 2, &pixels1);
    defer a.free(url1);
    const url2 = try encodeAsDataUrl(a, 2, 2, &pixels2);
    defer a.free(url2);

    try std.testing.expect(url1.len > 50); // non-trivial
    try std.testing.expect(!std.mem.eql(u8, url1, url2)); // different pixels = different URL
}
