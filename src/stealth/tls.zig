// STEALTHPANDA: src/stealth/tls.zig
// Chrome-shaped TLS ClientHello, applied via libcurl options at every
// connection reset (hook in src/network/http.zig Connection.reset).
//
// Stock lightpanda (libcurl+boringssl defaults) JA3
// `eb34dc6f0fb76e072758b1585876e2de` vs Chrome `a761b497…`: 17 vs 15
// ciphers, wrong order, no GREASE. curl can control the cipher list,
// TLS1.3 suites and curves — extension ORDER/PRESENCE (padding, ECH,
// session_ticket, compress_certificate, record_size_limit) lives inside
// boringssl's handshake_client and needs the local boringssl patch
// (see HOWTO-AGENTIC.md §4).
//
// Cipher/curve sets derive from the reference capture
// (profiles/chrome-157.json network[0].client_hello):
//   TLS1.3: 1301,1302,1303
//   TLS1.2: c02b,c02f,c02c,c030,cca9,cca8,c013,c014,009c,009d,002f,0035
//   groups: x25519_mlkem768(0x11ec), x25519, secp256r1, secp384r1
//
// New file in the stealthpanda fork (AGPL-3.0); no bladebro code.

const std = @import("std");

/// Chrome's TLS 1.3 suites, in Chrome's order.
pub const tls13_ciphersuites: [:0]const u8 =
    "TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256";

/// Chrome's TLS 1.2 suites, in Chrome's order (12 entries).
pub const tls12_cipher_list: [:0]const u8 =
    "ECDHE-ECDSA-AES128-GCM-SHA256:" ++
    "ECDHE-RSA-AES128-GCM-SHA256:" ++
    "ECDHE-ECDSA-AES256-GCM-SHA384:" ++
    "ECDHE-RSA-AES256-GCM-SHA384:" ++
    "ECDHE-ECDSA-CHACHA20-POLY1305:" ++
    "ECDHE-RSA-CHACHA20-POLY1305:" ++
    "ECDHE-RSA-AES128-SHA:" ++
    "ECDHE-RSA-AES256-SHA:" ++
    "AES128-GCM-SHA256:" ++
    "AES256-GCM-SHA384:" ++
    "AES128-SHA:" ++
    "AES256-SHA";

/// Chrome's supported groups, in Chrome's order. (boringssl spelling:
/// X25519MLKEM768 = 0x11ec.)
pub const ec_curves: [:0]const u8 = "X25519MLKEM768:X25519:P-256:P-384";

test "tls lists are well-formed" {
    // non-empty, colon-separated, no trailing colon
    try std.testing.expect(tls13_ciphersuites.len > 0);
    try std.testing.expect(tls13_ciphersuites[tls13_ciphersuites.len - 1] != ':');
    try std.testing.expect(std.mem.indexOf(u8, tls12_cipher_list, "CHACHA20") != null);
    try std.testing.expect(ec_curves[ec_curves.len - 1] != ':');
}
