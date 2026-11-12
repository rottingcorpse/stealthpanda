#!/usr/bin/env bash
# STEALTHPANDA: tools/stealth-check.sh — stealth regression check.
# Runs the fork's instruments against the built release binary and diffs
# them against the latest recorded baseline captures:
#
#   make build && tools/stealth-check.sh [tag]
#
# Checks: vectors FAIL count vs baseline; oracle divergent == 0;
# TLS ClientHello shape vs reference-tls-chrome157.jsonl; detector sites
# (network permitting). Every run appends a <tag>-* capture set under
# docs/stealthpanda/captures/ (append-only evidence).

set -u

cd "$(dirname "$0")/.."
LP="$PWD/zig-out/bin/lightpanda"
CHROME=~/stealthpanda/instruments/chrome-linux64/chrome
INSTR=~/stealthpanda/instruments
CAP="$PWD/docs/stealthpanda/captures"
TAG="${1:-check-$(date +%Y%m%d-%H%M%S)}"
BASE_VECTORS="$CAP/final27-vectors.txt"
BASE_ORACLE="$CAP/final27-oracle-report.txt"
BASE_SANNYSOFT="$CAP/final27-sannysoft"
REF_TLS="$CAP/reference-tls-chrome157.jsonl"

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BOLD=$'\033[1m'; OFF=$'\033[0m'
declare -a NAMES=() VERDICTS=()
verdict() { NAMES+=("$1"); VERDICTS+=("$2"); echo "$3"; }
fail=0

echo "${BOLD}stealth-check [$TAG]${OFF}"

# --- freshness: the binary must be newer than every source file ----------
if [ ! -x "$LP" ]; then
  echo "${RED}no zig-out/bin/lightpanda — run make build first${OFF}"; exit 2
fi
newest_src=$(find src build.zig -type f -newer "$LP" 2>/dev/null | head -1)
if [ -n "$newest_src" ]; then
  echo "${RED}binary is stale (e.g. $newest_src changed after the build) — run make build first${OFF}"
  exit 2
fi

mkdir -p "$CAP"
cd "$INSTR"

# --- 1. vectors -------------------------------------------------------------
python3 sp_vectors.py --lightpanda "$LP" --out "$CAP/$TAG-vectors-lightpanda.txt" >/dev/null 2>&1
v_now=$(grep -c "^FAIL" "$CAP/$TAG-vectors-lightpanda.txt" 2>/dev/null); v_now=${v_now:-997}
v_base=$(grep -c "^FAIL" "$BASE_VECTORS" 2>/dev/null); v_base=${v_base:-998}
if [ "$v_now" -le "$v_base" ]; then
  verdict vectors PASS "${GREEN}PASS${OFF} vectors: FAIL now=$v_now baseline=$v_base"
else
  verdict vectors FAIL "${RED}FAIL${OFF} vectors: FAIL now=$v_now > baseline=$v_base"; fail=1
fi

# --- 2. oracle vs real chrome ------------------------------------------------
python3 sp_oracle.py --chrome "$CHROME" --lightpanda "$LP" --url "https://example.com" \
  --report "$CAP/$TAG-oracle-report.txt" --json-report "$CAP/$TAG-oracle.json" >/dev/null 2>&1
d_now=$(grep -ci "divergent.*0\|0.*divergent" "$CAP/$TAG-oracle-report.txt" 2>/dev/null || echo 0)
div_line=$(grep -i "divergent" "$CAP/$TAG-oracle-report.txt" 2>/dev/null | head -1)
if [ "$d_now" -ge 1 ]; then
  verdict oracle PASS "${GREEN}PASS${OFF} oracle: $div_line"
else
  verdict oracle FAIL "${RED}FAIL${OFF} oracle: divergent probes present ($div_line)"; fail=1
fi

# --- 3. TLS ClientHello shape -------------------------------------------------
# Baseline = the newest accepted lightpanda capture EXCLUDING this run's own
# tag (append-only), NOT the raw Chrome reference: the fork ships a
# documented extension deficit vs Chrome (compress_certificate/psk/
# Chrome-privates). fe0d (ECH GREASE) is excluded from the set compare — it
# is a build-flag feature (-Dech_grease=true + patched boringssl), reported
# separately.
BASE_TLS=""
# prefer the highest after<N> capture (the fork's verified-state series),
# then any other accepted capture that isn't this run's own tag.
for f in $(ls -1 "$CAP"/after*-tls-lightpanda.jsonl 2>/dev/null | sort -V | tail -1); do
  BASE_TLS="$f"
done
if [ -z "$BASE_TLS" ]; then
  for f in $(ls -1t "$CAP"/*-tls-lightpanda.jsonl 2>/dev/null); do
    [ "$(basename "$f")" = "$TAG-tls-lightpanda.jsonl" ] && continue
    BASE_TLS="$f"; break
  done
fi
[ -z "$BASE_TLS" ] && BASE_TLS="$REF_TLS"
rm -f /tmp/stealth-check-tls.jsonl
python3 sp_tls.py --port 8448 --out /tmp/stealth-check-tls.jsonl >/dev/null 2>&1 &
TLS=$!
sleep 1
python3 sp_tlscapture.py --lightpanda "$LP" --port 8448 >/dev/null 2>&1
kill $TLS 2>/dev/null
tls_out=$(python3 - "$BASE_TLS" <<'PY'
import json, sys
def extsets(path):
    from collections import Counter
    c = Counter()
    for l in open(path):
        if not l.strip():
            continue
        r = json.loads(l)
        e = r.get('client_hello', {}).get('extensions', [])
        ids = tuple(sorted((x.get('type') if isinstance(x, dict) else x) for x in e))
        c[(ids, r.get('alpn_negotiated'))] += 1
    return c
now = extsets('/tmp/stealth-check-tls.jsonl')
base = extsets(sys.argv[1])
def core(sets):
    # union of extension-id sets per alpn, ignoring fe0d and grease-count noise
    out = set()
    for (ids, alpn) in sets:
        out.add((tuple(x for x in ids if x != 'fe0d' and (int(x, 16) & 0xFF) != (int(x, 16) >> 8)), alpn))
    return out
now_core, base_core = core(now), core(base)
now_ech = any('fe0d' in ids for (ids, _) in now)
base_ech = any('fe0d' in ids for (ids, _) in base)
if now_core and now_core == base_core:
    print(f"MATCH ech_now={int(now_ech)} ech_base={int(base_ech)}")
elif now_core:
    print("DIFF")
    for n in now_core - base_core:
        print("  only-now :", n)
    for b in base_core - now_core:
        print("  only-base:", b)
else:
    print("EMPTY")
PY
)
if [[ "$tls_out" == MATCH* ]]; then
  ech_state=$(echo "$tls_out" | grep -o "ech_now=[01] ech_base=[01]")
  cp /tmp/stealth-check-tls.jsonl "$CAP/$TAG-tls-lightpanda.jsonl"
  verdict tls PASS "${GREEN}PASS${OFF} tls: ClientHello == $(basename "$BASE_TLS") (ECH GREASE: $ech_state)"
elif [[ "$tls_out" == EMPTY ]]; then
  verdict tls SKIP "${YELLOW}SKIP${OFF} tls: no capture (local echo failed)"
else
  verdict tls FAIL "${RED}FAIL${OFF} tls: ClientHello drifted from $BASE_TLS"; fail=1
fi
[[ "$tls_out" == MATCH* ]] || echo "$tls_out"

# --- 4. detectors (network-dependent) ----------------------------------------
# Row-diff of the sannysoft result JSON against the baseline capture.
mkdir -p /tmp/stealth-check-det
det_out=$(timeout 180 python3 sp_detectors.py --lightpanda "$LP" --outdir /tmp/stealth-check-det 2>&1 || true)
det_json=/tmp/stealth-check-det/before-detector-sannysoft-lightpanda.json
if echo "$det_out" | grep -qi "nameserverfailure\|peerfailedverification\|could not resolve\|connection reset"; then
  verdict detectors SKIP "${YELLOW}SKIP${OFF} detectors: network unavailable/hijacked (run manually when clean)"
elif [ ! -s "$det_json" ]; then
  verdict detectors SKIP "${YELLOW}SKIP${OFF} detectors: no sannysoft result (site unreachable?) — output tail:"
  echo "$det_out" | tail -4
else
  python3 - "$det_json" "$BASE_SANNYSOFT/before-detector-sannysoft-lightpanda.json" <<'PY' > /tmp/stealth-check-det.diff
import json, sys
now = json.load(open(sys.argv[1]))
base = json.load(open(sys.argv[2]))
nd = {r.split(" = ")[0]: r for r in now.get("rows", []) if " = " in r}
bd = {r.split(" = ")[0]: r for r in base.get("rows", []) if " = " in r}
diffs = [k for k in sorted(set(nd) | set(bd)) if nd.get(k) != bd.get(k)]
print(f"rows now={len(nd)} base={len(bd)} diffs={len(diffs)}")
for k in diffs[:10]:
    print(f"  DIFF [{k}]\n    base: {bd.get(k, '<absent>')}\n    now : {nd.get(k, '<absent>')}")
PY
  d=$(grep -oE "diffs=[0-9]+" /tmp/stealth-check-det.diff | head -1 | cut -d= -f2)
  if [ "$d" = "0" ]; then
    verdict detectors PASS "${GREEN}PASS${OFF} sannysoft: $(head -1 /tmp/stealth-check-det.diff)"
  else
    verdict detectors FAIL "${RED}FAIL${OFF} sannysoft: $(head -1 /tmp/stealth-check-det.diff)"; fail=1
    sed -n '2,12p' /tmp/stealth-check-det.diff
  fi
fi

# --- summary -------------------------------------------------------------------
echo ""
echo "${BOLD}================ stealth-check [$TAG] ================${OFF}"
for i in "${!NAMES[@]}"; do
  case "${VERDICTS[$i]}" in
    PASS) col=$GREEN ;;
    FAIL) col=$RED ;;
    *)    col=$YELLOW ;;
  esac
  printf "  %s%-12s %s%s\n" "$col" "${NAMES[$i]}" "${VERDICTS[$i]}" "$OFF"
done
echo "==================================================="
if [ $fail -eq 0 ]; then
  echo "${GREEN}stealth intact — captures appended under docs/stealthpanda/captures/$TAG-*${OFF}"
else
  echo "${RED}STEALTH REGRESSION — do not push. Investigate the FAIL rows above.${OFF}"
fi
exit $fail
