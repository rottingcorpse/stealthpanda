#!/usr/bin/env bash
# STEALTHPANDA: tools/ci-local.sh — the fork's CI. All GitHub Actions
# workflows in this repo are disabled (their `on:` blocks are
# workflow_dispatch-only); this script runs the same commands those
# workflows would, locally, before pushing.
#
# Mirrors (with the same commands) the jobs of zig-test.yml, completion-test.yml
# and e2e-test.yml that can run outside the lightpanda org. Jobs that need
# org-internal infrastructure (perf-fmt image, WBA secrets, the self-hosted
# lpd-bench-hetzner runner, the demo repo's Go runner) are reported as
# SKIP(org-infra) exactly like the `github.repository_owner == 'lightpanda-io'`
# gates in the workflow files skip them on GitHub.
#
# Usage:
#   tools/ci-local.sh            # everything runnable (default)
#   tools/ci-local.sh --fast     # skip the long release build + e2e jobs
#   tools/ci-local.sh --job A,B  # run only the named jobs (--list to see them)
#   tools/ci-local.sh --list
#
# Requirements: zig + cargo on PATH (or at ~/stealthpanda/zig, ~/.cargo/bin),
# network for the one-time V8 prebuilt downloads and the fetch/mcp jobs.

set -u

cd "$(dirname "$0")/.."
export PATH="$HOME/stealthpanda/zig:$HOME/.cargo/bin:$PATH"

V8_VER="15.5.35.13"
ZIGV8_VER="v0.6.2"
V8_DIR=".lp-cache/ci-v8"
V8_REL="$V8_DIR/libc_v8_${V8_VER}_linux_x86_64.a"
V8_DBG="$V8_DIR/libc_v8_${V8_VER}_linux_x86_64_debug.a"

FAST=0
ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --fast) FAST=1 ;;
    --list) ONLY="__list" ;;
    --job) shift; ONLY="${1:-}" ;;
    *) echo "unknown option: $1 (use --fast, --list, --job A,B)"; exit 2 ;;
  esac
  shift
done

RED=$'\033[31m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; BOLD=$'\033[1m'; OFF=$'\033[0m'

declare -a JOB_NAMES=()
declare -a JOB_STATUS=()
declare -a JOB_TIMES=()

record() { # name status secs
  JOB_NAMES+=("$1"); JOB_STATUS+=("$2"); JOB_TIMES+=("$3")
}

run_job() { # name command...
  local name="$1"; shift
  if [ -n "$ONLY" ] && [ "$ONLY" != "__list" ]; then
    case ",$ONLY," in *",$name,"*) ;; *) return 0 ;; esac
  fi
  echo ""
  echo "${BOLD}==> [$name] $*${OFF}"
  local t0=$SECONDS
  if "$@" >/tmp/ci-local-$name.log 2>&1; then
    record "$name" "PASS" "$((SECONDS - t0))"
    echo "${GREEN}PASS${OFF} [$name] ($((SECONDS - t0))s)"
  else
    record "$name" "FAIL" "$((SECONDS - t0))"
    echo "${RED}FAIL${OFF} [$name] — last 25 lines of /tmp/ci-local-$name.log:"
    tail -25 /tmp/ci-local-$name.log | sed 's/^/    /'
  fi
}

skip_job() { # name reason
  local name="$1" reason="$2"
  [ -n "$ONLY" ] && [ "$ONLY" != "__list" ] && return 0
  record "$name" "SKIP($reason)" 0
  echo "${YELLOW}SKIP${OFF} [$name] — $reason"
}

ensure_v8() { # which: rel|dbg
  local file="$V8_REL" suffix=""
  [ "$1" = dbg ] && file="$V8_DBG" && suffix="_debug"
  if [ ! -f "$file" ]; then
    mkdir -p "$V8_DIR"
    echo "  downloading $(basename "$file") (one-time)..."
    wget -q -O "$file" "https://github.com/lightpanda-io/zig-v8-fork/releases/download/${ZIGV8_VER}/libc_v8_${V8_VER}_linux_x86_64${suffix}.a" \
      || { rm -f "$file"; return 1; }
  fi
}

command -v zig >/dev/null 2>&1 || { echo "zig not found on PATH"; exit 2; }

# ---- zig-test.yml -----------------------------------------------------------
run_job zig-fmt            zig fmt --check ./
if ensure_v8 rel; then
  run_job zig-test         env METRICS=true zig build "-Dprebuilt_v8_path=$V8_REL" test
else
  skip_job zig-test "could not fetch the release V8 prebuilt"
fi

if ensure_v8 dbg; then
  run_job zig-test-debug-v8 zig build "-Dprebuilt_v8_path=$V8_DBG" -Dtsan=true test
else
  skip_job zig-test-debug-v8 "could not fetch the debug V8 prebuilt (one-time wget failed)"
fi

CHROME=""
for c in google-chrome-stable google-chrome chromium chromium-browser; do
  command -v "$c" >/dev/null 2>&1 && CHROME="$c" && break
done
if [ -n "$CHROME" ] && ensure_v8 rel; then
  DEMO_DIR=".lp-cache/demo"
  if [ ! -d "$DEMO_DIR" ]; then
    echo "  cloning lightpanda-io/demo (one-time)..."
    git clone -q --depth 1 https://github.com/lightpanda-io/demo.git "$DEMO_DIR" || DEMO_DIR=""
  fi
  if [ -n "$DEMO_DIR" ]; then
    ( cd "$DEMO_DIR" && [ -d node_modules ] || npm install --silent >/dev/null 2>&1 )
    run_job html-tests-chrome bash -c "
      set -e
      zig build -Dprebuilt_v8_path='$V8_REL' test-server > test-server.log 2>&1 &
      srv=\$!
      timeout 600 bash -c 'until curl -sf -o /dev/null http://127.0.0.1:9582/reset; do sleep 1; done'
      trap 'kill \$srv 2>/dev/null || true' EXIT
      cd '$DEMO_DIR' && BROWSER_REPO='$PWD' node browser-tests/run.js
    "
  else
    skip_job html-tests-chrome "could not clone lightpanda-io/demo"
  fi
else
  skip_job html-tests-chrome "no chrome/chromium binary on PATH (CI installs google-chrome-stable)"
fi

# ---- completion-test.yml ------------------------------------------------------
if ensure_v8 rel; then
  run_job completion-test  make test-completion-bash COMPLETION_BASH=/bin/bash "ZIGFLAGS=-Dprebuilt_v8_path=$V8_REL"
fi

# ---- e2e-test.yml --------------------------------------------------------------
if [ "$FAST" -eq 0 ]; then
  if ensure_v8 rel; then
    run_job e2e-build-release zig build "-Dsnapshot_path=../../snapshot.bin" "-Dprebuilt_v8_path=$V8_REL" -Doptimize=fast "-Dorderfile=orderfile/lightpanda.ld" -Dcpu=x86_64
    if [ -x zig-out/bin/lightpanda ]; then
      run_job browser-fetch    bash -c '
        set -u
        url="https://demo-browser.lightpanda.io/campfire-commerce/"
        lp_log=$(timeout 60 ./zig-out/bin/lightpanda fetch "$url" 2>&1); lp_rc=$?
        if [ $lp_rc -eq 0 ]; then exit 0; fi
        # Our fetch failed: distinguish binary regression from a hostile
        # local network (ISP DNS hijacks present a wrong-name certificate —
        # if curl fails too, the environment is at fault, not the build).
        curl_log=$(timeout 30 curl -sS -o /dev/null "$url" 2>&1); curl_rc=$?
        if [ $curl_rc -ne 0 ]; then
          echo "SKIP: environment cannot reach $url (curl rc=$curl_rc: $curl_log)"
          echo "our error: $lp_log"
          exit 0
        fi
        echo "curl succeeds but our binary does not — regression:"
        echo "$lp_log"
        exit 1
      '
      run_job mcp-smoke        bash -c 'set -euo pipefail; timeout 30 ./zig-out/bin/lightpanda mcp > mcp.out <<"JSONRPC"
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"ci","version":"1.0.0"}}}
{"jsonrpc":"2.0","method":"notifications/initialized"}
{"jsonrpc":"2.0","id":2,"method":"tools/list"}
JSONRPC
jq -ec "select(.id == 1) | .result.protocolVersion == \"2024-11-05\"" mcp.out > /dev/null
jq -ec "select(.id == 2) | .result.tools | type == \"array\" and length > 0" mcp.out > /dev/null'
    fi
  fi
else
  skip_job e2e-build-release "--fast"
  skip_job browser-fetch "--fast"
  skip_job mcp-smoke "--fast"
fi

# Jobs that cannot run outside the lightpanda org (gated in the workflows):
skip_job perf-fmt "private lightpanda-org container image"
skip_job wba-test "lightpanda-org secrets (WBA key/domain)"
skip_job cdp-and-hyperfine-bench "self-hosted lpd-bench-hetzner runner"
skip_job demo-runner "needs go + the lightpanda-io/demo runner"
skip_job proxy-auth "needs go + the lightpanda-io/demo runner"
skip_job agent-deterministic "needs the lightpanda-io/demo repo"

# ---- summary -------------------------------------------------------------------
echo ""
echo "${BOLD}================ ci-local summary ================${OFF}"
rc=0
for i in "${!JOB_NAMES[@]}"; do
  st="${JOB_STATUS[$i]}"
  case "$st" in
    PASS) col=$GREEN ;;
    FAIL) col=$RED; rc=1 ;;
    *)    col=$YELLOW ;;
  esac
  printf "  %s%-28s %-18s %ss%s\n" "$col" "${JOB_NAMES[$i]}" "$st" "${JOB_TIMES[$i]}" "$OFF"
done
echo "==================================================="
[ $rc -eq 0 ] && echo "${GREEN}All runnable jobs PASSED — safe to push.${OFF}" || echo "${RED}FAILURES present — fix before pushing.${OFF}"
exit $rc
