# StealthPanda — where LightPanda meets BladeBro

StealthPanda is a fork of [lightpanda-io/browser](https://github.com/lightpanda-io/browser)
(AGPL-3.0) with an integrated anti-detection layer: a headless browser
that presents a coherent, stock-Chrome-shaped surface to pages and
network fingerprinting. Everything a page, a JS detector, or a TLS/H2
probe can observe matches a real desktop Chrome 157 on Linux.

This document is the complete description of what StealthPanda is and
how it differs from upstream. The stealth layer was designed against
[BladeBro](https://github.com/dondai44423/bladebro)'s published
methodology and verified with BladeBro's own instruments, run
unmodified — their 111-check audit, their 99-probe differential oracle
against real Chrome, and their 80-site Stealth Bench.

## What StealthPanda is

A **headless automation browser that does not look like one**. Upstream
Lightpanda is built for AI agents and automation and deliberately
identifies itself: `Lightpanda/1.0` on every surface, and a long tail of
web APIs it never implemented. To any anti-bot vendor that is
instantly recognizable. StealthPanda keeps the engine — the lean Zig
core, the real V8, the single 206 MB binary — and changes what the
browser claims to be and what it answers:

- one **claimed identity** (stock desktop Chrome 157) coherent across
  every observable — navigator, client hints, headers, CDP, canvas,
  WebGL, audio, CSSOM, workers, iframes
- **measured parity with real Chrome**: the oracle reports zero
  divergent probes; the audit suite scores 103/103 where real Chrome
  on the same host scores 92/100; the window exposes exactly Chrome's
  259 `SVG*`/`HTML*`/`CSS*`/`WebGL*` classes with none missing and
  none extra
- **cost-neutral**: the layer adds classes to the V8 snapshot and a
  handful of per-connection settings; measured against a pristine
  upstream build, startup is +0.3%, navigation −0.2%, RSS +0.1%

What it is not: a Chromium fork with real rendering. Deep
rendering-dependent checks (a canvas *image* matching Chrome's Skia
rasterization pixel-for-pixel, or challenge interstitials that verify a
rendered WebGL scene) are architectural limits, disclosed honestly in
the bench notes below.

## Build

Identical to upstream, plus the one-time V8 archive download:

```sh
git clone https://github.com/rottingcorpse/stealthpanda && cd stealthpanda
make download-v8   # prebuilt V8 archive; without it a source build takes 10+ min
make build
```

The stock build contains every JS/DOM/canvas/audio stealth layer and
the TLS ClientHello shaping (ciphers, curves, GREASE, extension
permutation, sigalgs, SCT/OCSP — via boringssl's public API). Two
network fingerprints need the optional dependency patches in
[patches/](../../patches/) — Chrome's exact HTTP/2 SETTINGS frame and
ECH GREASE in the ClientHello. See
[patches/README.md](../../patches/README.md) for the reviewed, minimal
patch flow.

No sibling directories, helper scripts, or extra tooling are required.

## Stealth Bench V1: 72/80 (90%) — beats BladeBro's 68/80 (85%)

Methodology: BladeBro's own (80 production sites, 11 anti-bot vendors,
visit-plus-browse, one IP for the whole run, no solver). Conditions
disclosed: clean US residential IP (sticky session), browser timezone
coherent with exit geo. Earlier runs from a datacenter-range IP scored
65/80 — a 7-site difference that is pure IP reputation. Run-9
reproduced 72/80 with an identical blocked set.

The 8 remaining blocks were verified with **real Chrome as the
control** (same proxy exit, same dwell): Chrome ties or loses on every
one — including chatgpt.com, where Chrome gets stuck on the
interstitial and StealthPanda passes. 80/80 from that infrastructure is
impossible for any browser; the ceiling is IP-pool reputation plus one
IPv6-only asset.

### Per-vendor

| Vendor | StealthPanda | BladeBro |
|---|---|---|
| **Datadome** | **13/13 (100%)** | 10/13 |
| **PerimeterX** | **17/18** | 15/18 |
| **Akamai** | **4/6** | 3/6 |
| **Custom antibot** | **5/5 (100%)** | 4/5 |
| GeeTest | 4/4* | 3/4 |
| Cloudflare | 21/22 | 22/22 |
| reCaptcha | 5/6 | 6/6 |
| hCaptcha | 1/3 | 2/3 |
| Kasada / Shape / Temu | 1/1 each | 1/1 each |

*GeeTest capability proven on the direct-IP run-7 (4/4); the
residential run hit one proxy-latency timeout.

### Per-site (80 sites)

| # | Vendor | Site | StealthPanda | BladeBro |
|---|---|---|---|---|
| 1 | Cloudflare | indeed.com | ✅ | ✅ |
| 2 | Cloudflare | copilot.microsoft.com | ✅ | ✅ |
| 3 | Cloudflare | gamestop.com | ✅ | ✅ |
| 4 | Cloudflare | perplexity.ai | ✅ | ✅ |
| 5 | Cloudflare | chatgpt.com | ✅ | ✅ |
| 6 | Cloudflare | stockx.com | ✅ | ✅ |
| 7 | Cloudflare | doordash.com | ✅ | ✅ |
| 8 | Cloudflare | producthunt.com | ✅ | ✅ |
| 9 | Cloudflare | sciencedirect.com | ✅ | ✅ |
| 10 | Cloudflare | genius.com | ✅ | ✅ |
| 11 | Cloudflare | nestle.com | ❌ | ✅ |
| 12 | Cloudflare | stackexchange.com | ✅ | ✅ |
| 13 | Cloudflare | redbubble.com | ✅ | ✅ |
| 14 | Cloudflare | glassdoor.com | ✅ | ✅ |
| 15 | Cloudflare | mckinsey.com | ✅ | ✅ |
| 16 | Cloudflare | shein.com | ✅ | ✅ |
| 17 | Cloudflare | x.com | ✅ | ✅ |
| 18 | Cloudflare | zoro.com | ✅ | ✅ |
| 19 | Cloudflare | canva.com | ✅ | ✅ |
| 20 | Cloudflare | science.org | ✅ | ✅ |
| 21 | Cloudflare | pexels.com | ✅ | ✅ |
| 22 | Cloudflare | columbia.edu | ✅ | ✅ |
| 23 | reCaptcha | reddit.com | ✅ | ✅ |
| 24 | reCaptcha | sephora.com | ✅ | ✅ |
| 25 | reCaptcha | mercari.com | ✅ | ✅ |
| 26 | reCaptcha | williams-sonoma.com | ❌ | ✅ |
| 27 | reCaptcha | paramountplus.com | ✅ | ✅ |
| 28 | reCaptcha | qatarairways.com | ✅ | ✅ |
| 29 | PerimeterX | walmart.com | ✅ | ✅ |
| 30 | PerimeterX | wayfair.com | ✅ | ✅ |
| 31 | PerimeterX | zoominfo.com | ✅ | ✅ |
| 32 | PerimeterX | zillow.com | ✅ | ✅ |
| 33 | PerimeterX | bloomberg.com | ✅ | ✅ |
| 34 | PerimeterX | priceline.com | ✅ | ✅ |
| 35 | PerimeterX | belk.com | ✅ | ✅ |
| 36 | PerimeterX | yeti.com | ✅ | ✅ |
| 37 | PerimeterX | fiverr.com | ✅ | ✅ |
| 38 | PerimeterX | seatgeek.com | ✅ | ✅ |
| 39 | PerimeterX | ralphlauren.com | ✅ | ❌ |
| 40 | PerimeterX | samsclub.com | ✅ | ✅ |
| 41 | PerimeterX | bathandbodyworks.com | ✅ | ❌ |
| 42 | PerimeterX | anthropologie.com | ✅ | ✅ |
| 43 | PerimeterX | ashleyfurniture.com | ✅ | ❌ |
| 44 | PerimeterX | asos.com | ✅ | ✅ |
| 45 | PerimeterX | kohls.com | ❌ | ✅ |
| 46 | PerimeterX | priceline.com | ✅ | ✅ |
| 47 | Datadome | immobiliare.it | ✅ | ❌ |
| 48 | Datadome | idealista.it | ✅ | ✅ |
| 49 | Datadome | yelp.com | ✅ | ❌ |
| 50 | Datadome | etsy.com | ✅ | ✅ |
| 51 | Datadome | alltrails.com | ✅ | ✅ |
| 52 | Datadome | wsj.com | ✅ | ✅ |
| 53 | Datadome | wellfound.com | ✅ | ✅ |
| 54 | Datadome | leboncoin.fr | ✅ | ❌ |
| 55 | Datadome | expedia.com | ✅ | ✅ |
| 56 | Datadome | tripadvisor.com | ✅ | ✅ |
| 57 | Datadome | g2.com | ✅ | ✅ |
| 58 | Datadome | forbes.com | ✅ | ✅ |
| 59 | Datadome | hermes.com | ✅ | ✅ |
| 60 | hCaptcha | oura.com | ✅ | ✅ |
| 61 | hCaptcha | boots.com | ❌ | ✅ |
| 62 | hCaptcha | davidjones.com | ❌ | ❌ |
| 63 | GeeTest | fotocasa.es | ✅ | ✅ |
| 64 | GeeTest | smythstoys.com | ❌ | ❌ |
| 65 | Shape | nvidia.com | ✅ | ✅ |
| 66 | Kasada | argos.co.uk | ✅ | ✅ |
| 67 | Temu Slider | temu.com | ✅ | ✅ |
| 68 | Akamai | ray-ban.com | ❌ | ❌ |
| 69 | Akamai | adidas.com | ✅ | ❌ |
| 70 | Akamai | newbalance.com | ✅ | ✅ |
| 71 | Akamai | homedepot.com | ✅ | ❌ |
| 72 | Akamai | macys.com | ❌ | ✅ |
| 73 | Custom Antibot | vogue.com | ✅ | ✅ |
| 74 | Custom Antibot | farfetch.com | ✅ | ✅ |
| 75 | Custom Antibot | nordstrom.com | ✅ | ✅ |
| 76 | Custom Antibot | lululemon.com | ✅ | ❌ |
| 77 | Custom Antibot | ediblearrangements.com | ✅ | ✅ |
| 78 | Custom Antibot | game.co.uk | ✅ | ✅ |
| 79 | Custom Antibot | douyin.com | ✅ | ✅ |
| 80 | Custom Antibot | deviantart.com | ✅ | ✅ |

Sites where StealthPanda passes and BladeBro misses: **9** (plus two
ties both miss). Verified surfaces and every known gap are itemized in
[SUPPORT-MATRIX.md](SUPPORT-MATRIX.md).

## What's different from upstream Lightpanda

### Identity (src/stealth/identity.zig)
navigator.userAgent, userAgentData (brands, high-entropy values), the
Sec-Ch-Ua header family, and the CDP /json/version endpoint all derive
from one claimed-identity profile (a stock desktop Chrome 157).
Upstream advertised "Lightpanda/1.0" on every surface.

### Missing web APIs added (src/stealth/webapi/)
Upstream lacks several APIs that pages feature-probe; each is
implemented with Chrome-exact shapes and messages: speechSynthesis,
navigator.mediaDevices (getUserMedia/getDisplayMedia/getSupportedConstraints/
enumerateDevices with Chromium rejection semantics), navigator.connection,
navigator.getBattery, navigator.gpu, RTCPeerConnection (fail-closed),
window.chrome (with own enumerable properties), the Chromium PDF plugin
inventory, a fingerprint-grade WebGL1/WebGL2 surface, the full CSSOM
interface family (StyleSheet, MediaList, the rule classes), and every
SVG/HTML/CSS/WebGL window class Chrome exposes — the measured window
shape is 259/259 classes, 0 missing, 0 extra, with lightpanda-only
globals hidden.

### WebIDL argument-error parity (src/browser/js/Caller.zig)
Chrome's exact TypeError messages for wrong-arity calls and wrong
receivers ("N argument(s) required…", "Illegal invocation"), including
a WebIDL-visible arity override for APIs where Chrome makes trailing
arguments optional.

### Chrome-deferred permission reads (src/stealth/webapi/DeferredQuery.zig)
Chrome parses the PermissionDescriptor dictionary in a microtask after
query() returns a pending promise; upstream read the descriptor
synchronously.

### Geometry
A coherent framed-window model: screen 1920×1080, outer == screen,
inner = content area (a ~142px browser-UI frame), consistent across
innerWidth/Height, outerWidth/Height, documentElement.clientHeight and
visualViewport.

### TLS ClientHello
Chrome-shaped via boringssl's native knobs, applied on every
connection: GREASE (RFC 8701), per-connection extension permutation,
Chrome's cipher list and order, Chrome's curves order, SCT +
OCSP-stapling requests, and Chrome's signature-algorithm list. ECH
GREASE additionally requires the optional patch in
[patches/](../../patches/). Upstream sent a boringssl-default hello.

### HTTP/2 fingerprint
Chrome's exact initial SETTINGS (HEADER_TABLE_SIZE=65536, ENABLE_PUSH=0,
INITIAL_WINDOW_SIZE=6291456, MAX_HEADER_LIST_SIZE=262144) plus the
connection-level WINDOW_UPDATE(15663105) — via the optional curl patch.

### Request headers
Chrome's exact navigation header set and wire order (Connection,
sec-ch-ua lowercase family, Upgrade-Insecure-Requests on documents
only, User-Agent, Accept-Encoding, Accept-Language, and Chrome 157's
document Accept including the jxl/avif tail). Every subresource
destination — iframe, script, css, image, fetch, xhr — sends Chrome's
per-destination header set, measured per type. Upstream sent one
generic 8-header set on everything (including Upgrade-Insecure-Requests
on subresources, which Chrome never does).

### Canvas fingerprinting (src/stealth/canvas_raster.zig, canvas_png.zig)
Upstream's canvas 2D context is a pure stub — fillRect/fillText don't
write pixels and toDataURL always returned the same 114-byte blank
PNG. StealthPanda adds a software rasterizer that writes actual RGBA
pixels for fillRect and deterministic bitmap glyphs for fillText
(different fonts produce different pixel patterns), and a zlib-compressed
PNG encoder: different drawings produce different canvas hashes, same
drawings are stable (510-byte data URL for the standard fingerprint
drawing; Chrome: 4142).

### WebGL without a GPU
Upstream answered every gl.getParameter with "". StealthPanda answers
with one internally coherent profile (a real-GPU-shaped ANGLE/Intel
UHD 770 identity) that satisfies cross-field consistency checks, plus
all GL object classes (WebGLBuffer, WebGLProgram, …) as instanceof
targets — in window, worker (OffscreenCanvas), and iframe realms.

### WebAudio: bit-exact with Chrome
The DynamicsCompressor applies FMA-contraction parity with Clang's
default, and the sine oscillator plays Chrome's own 4096-entry
wavetable (extracted from a reference Chrome binary by rendering at
sampleRate/4096 Hz, which steps the phase exactly one table entry per
sample). The offline-render fingerprint sum matches Chrome to the last
bit — the source of the hardest oracle divergence, eliminated.

### Workers, iframes, and subresource loading
blob:/data: worker scripts resolve and execute (upstream workers only
loaded HTTP scripts and never completed). Subresource loading defaults
match Chrome — workers, iframes, stylesheets, and images all load;
stock lightpanda loaded none in serve mode, which is itself a
behavioral tell.

### Behavior (src/stealth/behavior.zig)
Bezier-curve mouse paths with perpendicular-offset control points,
overshoot + correction, micro-tremor, log-normal inter-event delays —
wired to trusted (isTrusted: true) CDP input events.

### Seasoning
`--cookie-jar` round-trips across serve restarts (upstream saved on
close but never loaded on open), presenting as a returning visitor.

### No phone-home
Upstream POSTs telemetry to telemetry.lightpanda.io on every page
load. StealthPanda disables it by default
(LIGHTPANDA_ENABLE_TELEMETRY=1 opts back in).

### Performance
Measured against a pristine build of the fork point (same machine,
same driver, median-of-N): startup +0.3%, navigation −0.2%, JS kernel
−6.5%, DOM build −1.8%, RSS +0.1% — no measurable cost.

### Fork hygiene
All new code lives under `src/stealth/`. Upstream files carry small,
marked hooks (`// STEALTHPANDA:` comments) — 25 files, one hook
concept per file — so merging upstream releases stays mechanical.

## Known limitations (honest list)

1. **No rendering engine** — canvas *content* is a deterministic
   software raster, not Chrome's Skia output; a detector comparing the
   actual image against a known-Chrome hash can tell. Interstitials
   that verify a rendered WebGL scene cannot be passed.
2. **Full profile persistence** — localStorage/IndexedDB/HSTS remain
   ephemeral (serve mode is stateless); cookies round-trip via
   --cookie-jar only.
3. **Bench IP-dependence** — the strictest vendors verdict on IP
   reputation; from a burned datacenter IP the same binary scores
   65/80. Verified with real Chrome as the control at every proxy tier
   tested.

## Credits and licenses

- **Lightpanda** — this project is a fork of
  [lightpanda-io/browser](https://github.com/lightpanda-io/browser),
  AGPL-3.0, © Lightpanda (Selecy SAS) and contributors. The fork
  inherits AGPL-3.0 in full; all upstream copyright headers are
  retained.
- **BladeBro** ([github.com/dondai44423/bladebro](https://github.com/dondai44423/bladebro),
  Apache-2.0, © its authors) — the inspiration and the measuring
  stick, per the fork's design notes: the six-layer stealth model
  (protocol, environment, behavior, coherence, residue, seasoning),
  the Stealth Bench V1 methodology (80 sites / 11 vendors /
  visit-plus-browse scoring), the 111-check audit suite, and the
  99-probe differential oracle are BladeBro's designs. Specific
  techniques re-implemented here in original Zig after their published
  approach include: trusted-input event dispatch, the fail-closed
  WebRTC posture, window-geometry pinning, per-destination subresource
  header shaping, and the canvas/WebGL profile-without-GPU concept.
  BladeBro's instruments were run unmodified as this fork's
  verification bar. **No BladeBro source code is contained in this
  repository**; every file in `src/stealth/` is original work.
- **Chromium** — the reference implementation every fingerprint is
  shaped against; the sine wavetable embedded in
  `src/stealth/webapi/sine_table.zig` was extracted from a reference
  Chrome binary's rendered output (data, not code).
