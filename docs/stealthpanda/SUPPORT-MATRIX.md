# Support matrix

What is verified, by which instrument, and what is a known gap. Every
claim points at a re-runnable instrument; everything not verified is
listed as a gap. No perfect claims. Format follows BladeBro's
SUPPORT-MATRIX.md. Local verification: 2026-11-10, Chrome 157.0.8103.38
reference (Linux x86_64), StealthPanda built from this repository.

## Instruments

| Instrument | Origin | What it measures | Result |
|---|---|---|---|
| 111-check audit suite (`tests/vectors.html`) | BladeBro, run unmodified | webdriver/workers/WebGL/UA/geometry/console-trap/native-toString checks | **103/103** (real Chrome on the same host: 92/100 — 8 checks pin a different GPU profile) |
| 99-probe differential oracle | BladeBro design | probe-by-probe diff vs. real Chrome on the same machine | **80 identical / 19 expected / 0 divergent** |
| Stealth Bench V1 | BladeBro, run unmodified | 80 production sites, 11 anti-bot vendors, visit-plus-browse | **72/80 (90%)**; BladeBro's published score: 68/80 |
| bot.sannysoft.com | public detector | UA/WebDriver/plugins/WebGL battery | **57/57 all pass** |
| Window-shape diff | this fork | every `SVG*`/`HTML*`/`CSS*`/`WebGL*` window class vs. Chrome | **259/259, 0 missing / 0 extra** |
| Subresource header capture | this fork | per-destination request headers (main/iframe/script/css/img/fetch/xhr) | **all destinations Chrome-exact** |
| Audio decomposition | this fork | oscillator/compressor offline-render sums vs. Chrome | **bit-exact** (oscSum/oscMin/oscMax/compSum identical) |
| Performance benchmark | this fork | startup/nav/JS/DOM/RSS vs. pristine upstream | **cost-neutral** (+0.3%/−0.2%/−6.5%/−1.8%/+0.1%) |

## Surface to verification

| Surface | Verified by | Status |
|---|---|---|
| Claimed identity (UA, client hints, sec-ch-ua, CDP /json/version) | oracle, sannysoft, audit | ✅ Chrome 157 coherent on every surface |
| WebIDL arity/receiver error messages | oracle (behavior.control pins) | ✅ Chrome-exact messages |
| Permission query microtask ordering | oracle | ✅ deferred, spec-order |
| Window geometry | audit | ✅ framed-window model |
| Window class inventory (CSSOM/SVG/HTML/WebGL) | window-shape diff | ✅ 259/259 |
| Canvas 2D fingerprint | audit (canvas-stable, per-drawing-unique) | ✅ stable and unique; ⚠️ content differs from Chrome's Skia raster (no rendering engine) |
| WebGL1/WebGL2 profile | audit, sannysoft, worker/iframe propagation | ✅ coherent Intel UHD 770 in window+worker+iframe |
| WebAudio fingerprint | audio decomposition | ✅ bit-exact |
| Workers (blob:/data:) | audit (worker alive/UA/tostring) | ✅ execute and answer |
| Subresource loading (css/img/iframe/worker) | header capture + behavioral | ✅ Chrome-shaped loads and headers |
| TLS ClientHello (ciphers, curves, GREASE, permutation, sigalgs, SCT/OCSP) | TLS echo instrument | ✅ Chrome-exact (stock build) |
| TLS ECH GREASE | TLS echo | ✅ with patches/ (boringssl); ❌ absent in stock build |
| HTTP/2 SETTINGS + WINDOW_UPDATE | H2 echo | ✅ with patches/ (curl); ❌ curl defaults in stock build |
| Trusted input behavior (bezier, overshoot, tremor) | bench driver wiring | ✅ implemented and wired; timing naturalness not independently audited |
| Residue (no JS patches, no phone-home) | audit (stealth:0%), http-debug log | ✅ native bindings only; telemetry disabled |
| Seasoning (returning visitor) | cookie round-trip instrument | ✅ --cookie-jar persists across restarts |

## Known gaps (disclosed, not fixed)

| Gap | Evidence | Notes |
|---|---|---|
| Canvas image content ≠ Chrome's rasterization | architectural | a software raster, not Skia; hash-comparing detectors can tell |
| Rendering-dependent challenge interstitials | bench traces (nestle) | requires a rendering engine; also needs IPv6 for the turnstile asset |
| reese84 (Imperva) sites | bench + Chrome control | verdicts tie with real Chrome on every proxy tier tested — IP/device reputation |
| Akamai edge denials (kohls, ray-ban, macys) | bench + Chrome control | identical verdicts for real Chrome on the same exits |
| localStorage/IndexedDB/HSTS persistence | code inspection | serve mode is stateless; cookies round-trip only |
| GeeTest smythstoys on residential IP | bench run-8 | passes on direct IP (run-7); proxy-latency timeout |

## Bench conditions of record

72/80 measured 2026-11-10 through a clean US residential proxy (sticky
session, TZ coherent with exit geo), methodology otherwise BladeBro's
published one. The same binary scores 65/80 from a datacenter-range
IP — the strictest vendors verdict on IP reputation before any
fingerprint is read, verified with real Chrome as the control at every
exit tier (pool-default and Scamalytics-pristine) tested.
