<p align="center">
  <h1 align="center">StealthPanda</h1>
  <p align="center"><strong>Where LightPanda Meets BladeBro</strong></p>
</p>

<p align="center">
<strong>A stealth-hardened fork of the Lightpanda browser: a headless browser written in Zig that presents a stock-Chrome-shaped surface to pages, JavaScript detectors, and network fingerprinting.</strong><br>
Not a Chromium fork. Not a WebKit patch. Lightpanda's lean Zig engine, dressed as the Chrome it isn't.
</p>

## What StealthPanda is

StealthPanda is [Lightpanda](https://github.com/lightpanda-io/browser) —
the headless browser built from scratch in Zig — plus an integrated
anti-detection layer developed in this fork. Every observable a page, a
JS fingerprinting script, or a TLS/HTTP-2 probe can read has been shaped
to match a stock desktop Chrome 157 on Linux: one coherent identity
across `navigator`, client hints, canvas, WebGL, WebAudio, CSSOM,
workers, iframes, subresource headers, the TLS ClientHello, and the
HTTP/2 preface.

The stealth layer was built against
[BladeBro](https://github.com/dondai44423/bladebro)'s published
methodology and verified with BladeBro's own instruments (their
111-check audit, their 99-probe differential oracle vs. real Chrome, and
their 80-site Stealth Bench). No BladeBro code is included — see
[Credits](#credits).

## Quick start

```sh
git clone https://github.com/rottingcorpse/stealthpanda && cd stealthpanda
make download-v8   # fetch the prebuilt V8 archive once (a full V8 build takes 10+ min)
make build
```

That produces a fully working StealthPanda with every JS/DOM/canvas/
audio stealth layer. Two network-level fingerprints (Chrome's exact
HTTP/2 SETTINGS and ECH GREASE in the TLS ClientHello) live in the
vendored dependencies and are enabled with the reviewed patches in
[patches/](patches/) — see
[patches/README.md](patches/README.md).

## Results (BladeBro's instruments, run unmodified)

| Instrument | Result |
|---|---|
| Stealth Bench V1 (80 sites, 11 anti-bot vendors) | **72/80 (90%)** — BladeBro's published score: 68/80 (85%) |
| 99-probe differential oracle vs. real Chrome | **80 identical / 19 expected / 0 divergent** |
| 111-check local audit | **103/103** (real Chrome on the same host: 92/100) |
| bot.sannysoft.com | 57/57 all pass |
| Performance vs. pristine upstream | cost-neutral (startup +0.3%, nav −0.2%, RSS +0.1%) |

Per-site results and methodology conditions:
[docs/stealthpanda/README.md](docs/stealthpanda/README.md). Verified
surfaces and known gaps: [docs/stealthpanda/SUPPORT-MATRIX.md](docs/stealthpanda/SUPPORT-MATRIX.md).

## How it differs from upstream Lightpanda

The short version: upstream Lightpanda deliberately identifies itself
("Lightpanda/1.0" on every surface) and stubs or omits APIs a headless
automation browser doesn't need. StealthPanda adds a complete stealth
layer under `src/stealth/` plus small, marked hooks (`// STEALTHPANDA`)
in ~25 upstream files, changing what the browser *claims to be* and what
it *answers* — never how it's built or run:

- **One claimed identity** — Chrome 157 across navigator, client hints,
  `Sec-Ch-Ua` headers, and CDP `/json/version`
- **120+ missing web APIs** — speech synthesis, media devices,
  connection, battery, GPU, the full CSSOM and SVG class families,
  WebGL object types — the window shape matches Chrome 259/259
- **Canvas & WebGL without a GPU** — a software rasterizer, real PNG
  encoding, and one coherent Intel GPU profile across window, worker,
  and iframe realms
- **Bit-exact WebAudio** — the sine oscillator plays Chrome's own
  wavetable; the offline-render fingerprint matches to the last bit
- **Chrome-shaped network stack** — TLS ClientHello via boringssl
  knobs, HTTP/2 SETTINGS via the curl patch, per-destination
  subresource headers, css/img/iframes/workers all load
- **Behavior & residue** — trusted-input bezier mouse paths, no
  function patches, no phone-home (upstream telemetry is disabled)

Full details: [docs/stealthpanda/README.md](docs/stealthpanda/README.md).

Upstream merges stay cheap: new code lives under `src/stealth/`, every
upstream touch-point is marked, and the fork tracks
`lightpanda-io/browser` for periodic merges.

## Credits

- **[Lightpanda](https://github.com/lightpanda-io/browser)** — the
  entire browser engine. Upstream project, AGPL-3.0, © Lightpanda
  (Selecy SAS) and contributors. StealthPanda is a fork and inherits
  the AGPL-3.0 license in full.
- **[BladeBro](https://github.com/dondai44423/bladebro)** (Apache-2.0,
  © its authors) — the inspiration and the measuring stick. The
  six-layer stealth model, the Stealth Bench V1 methodology, the
  111-check audit, and the 99-probe oracle are BladeBro's designs; this
  fork re-implemented the techniques in original Zig and used BladeBro's
  instruments unmodified as the verification bar. No BladeBro source
  code is contained in this repository.
- **Chrome** (Chromium project) — the reference implementation every
  fingerprint is shaped against.

## License

AGPL-3.0 (inherited from Lightpanda). See [LICENSE](LICENSE).
