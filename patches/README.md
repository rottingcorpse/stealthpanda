# Dependency patches (optional — full network-fingerprint parity)

A stock `make build` produces a fully working StealthPanda with every
JS/DOM/canvas/audio stealth layer. Two network-level fingerprints,
however, live in the vendored dependencies and require the patches in
this directory:

| Patch | Applies to | What it adds |
|---|---|---|
| `curl-8.23.0-chrome-h2-settings.patch` | curl 8.23.0 (`lib/http2.c`) | Chrome's exact HTTP/2 SETTINGS frame (HEADER_TABLE_SIZE 65536, ENABLE_PUSH 0, INITIAL_WINDOW_SIZE 6291456, MAX_HEADER_LIST_SIZE 262144) + connection WINDOW_UPDATE(15663105) |
| `boringssl-ech-grease.patch` | boringssl @ 7c1efd8d | `SSL_CTX_set_ech_grease_enabled()` — CTX-level ECH GREASE, which Chrome sends on every ClientHello |
| `boringssl-zig-ech-grease.patch` | lightpanda-io/boringssl-zig | points the wrapper at the patched boringssl tree |

Without the patches: HTTP/2 fingerprint = curl defaults, and the
ClientHello omits ECH GREASE. Everything else (cipher list and order,
curves, GREASE, extension permutation, sigalgs, SCT/OCSP) is applied
through boringssl's public API at runtime and ships in the stock build.

## Applying (Linux, zig 0.17.0)

```sh
git clone https://github.com/<you>/stealthpanda && cd stealthpanda

# 1. Fetch dependencies so you have pristine sources to patch
zig fetch --save git+https://github.com/lightpanda-io/boringssl-zig.git#5b5ad66f65c5cc4323680ab71284403598251678
zig fetch --save https://github.com/curl/curl/releases/download/curl-8_23_0/curl-8.23.0.tar.gz

# 2. Extract the two cached packages to sibling dirs and patch them
#    (paths below assume $PWD/..; adjust to taste)
git clone https://github.com/lightpanda-io/boringssl-zig.git ../boringssl-zig-local
cd ../boringssl-zig-local && git checkout 5b5ad66f65c5cc4323680ab71284403598251678
git clone https://boringssl.googlesource.com/boringssl ../boringssl-src
cd ../boringssl-src && git checkout 7c1efd8d6ffb36a57feba44e8c73cf674801f3cb
patch -p1 -d ../boringssl-src    < ../stealthpanda/patches/boringssl-ech-grease.patch
patch -p1 -d ../boringssl-zig-local < ../stealthpanda/patches/boringssl-zig-ech-grease.patch

mkdir -p ../curl-local && cd ../curl-local
tar xzf $(ls ~/.cache/zig/p/*/curl-8.23.0.tar.gz 2>/dev/null || echo curl-8.23.0.tar.gz) --strip-components=1
curl -sSL -o curl.tar.gz https://github.com/curl/curl/releases/download/curl-8_23_0/curl-8.23.0.tar.gz
tar xzf curl.tar.gz --strip-components=1
patch -p1 < ../stealthpanda/patches/curl-8.23.0-chrome-h2-settings.patch

# 3. Point build.zig.zon at the patched trees (same shape as upstream's
#    commented .path examples):
#      .@"boringssl-zig" = .{ .path = "../boringssl-zig-local" },
#      .curl = .{ .path = "../curl-local" },

# 4. Build
make download-v8 && make build
```

The patches are minimal and readable; review them before applying.
