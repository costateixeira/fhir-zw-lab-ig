#!/usr/bin/env bash
# One-command conformance session for a real system. Starts the pass-through
# proxy, shows a friendly live feed of every request's verdict, and on Ctrl+C
# automatically audits everything the system stored and prints a summary.
#
#   ./test-session.sh ehr          # test a real EHR   (proxy on :8080)
#   ./test-session.sh lab 8081     # test a lab system (proxy on :8081)
#   TARGET=https://my-shr/fhir ./test-session.sh ehr   # different real server
#
# Point the system under test at http://<this-machine>:<port> and use it
# normally. Nothing else to configure, nothing to repoint.
set -uo pipefail
cd "$(dirname "$0")"

ACTOR="${1:?usage: test-session.sh <ehr|lab> [port]}"
PORT="${2:-8080}"
# if the requested port is taken (e.g. Docker/OrbStack forwards on 8080/8081),
# walk up to the next free one
while lsof -ti tcp:"$PORT" >/dev/null 2>&1; do
  echo "(port $PORT is in use — trying $((PORT + 1)))"
  PORT=$((PORT + 1))
done
TARGET="${TARGET:-http://173.212.195.88/fhir}"
SESSION="target/sessions/$(date +%Y%m%d-%H%M%S)-${ACTOR}"
mkdir -p "$SESSION"
rm -f target/session-patients.txt session-patients.txt

LAN_IP="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || hostname -I 2>/dev/null | cut -d' ' -f1 || echo localhost)"

echo "──────────────────────────────────────────────────────────────"
echo " ZW Lab conformance session — actor: ${ACTOR}"
echo " Point your system's FHIR base URL at:  http://${LAN_IP}:${PORT}"
echo " Requests flow through to:              ${TARGET}"
echo " Every push is scored against the ZW profiles on the way."
echo " Stop with Ctrl+C to get your audit and summary."
echo "──────────────────────────────────────────────────────────────"

MODE=proxy TARGET="$TARGET" ./run-interceptor.sh "$ACTOR" "$PORT" > "$SESSION/proxy.log" 2>&1 &
PROXY_PID=$!

cleanup() {
  trap - INT TERM
  echo
  echo "── ending session ──"
  kill "${FEED_PID:-}" 2>/dev/null
  kill "$PROXY_PID" 2>/dev/null
  pkill -P "$PROXY_PID" 2>/dev/null
  sleep 1

  PASS=$(rg -c 'ZWPROXY\|push\|[^|]*\|0 errors|ZWPROXY\|pull\|[^|]*\|ok' "$SESSION/proxy.log" 2>/dev/null || echo 0)
  FAIL=$(rg -c 'ZWPROXY\|push\|[^|]*\|[1-9][0-9]* errors|REJECTED' "$SESSION/proxy.log" 2>/dev/null || echo 0)
  FWD=$(rg -c 'ZWPROXY\|[^|]*\|.*\|forwarded' "$SESSION/proxy.log" 2>/dev/null || echo 0)
  echo "session summary:  ✓ ${PASS} conformant   ✗ ${FAIL} with findings   → ${FWD} passed through"

  # per-request verdicts: table for the terminal, JSON artifact for the session folder
  VERDICTS=$(rg 'ZWPROXY\|' "$SESSION/proxy.log" 2>/dev/null | sed -E 's/^([0-9:.]+) .*ZWPROXY\|/\1|/')
  if [ -n "$VERDICTS" ]; then
    echo
    echo "── per-request verdicts ──"
    printf '%s\n' "$VERDICTS" | awk -F'|' '
      BEGIN { printf "  %-13s %-5s %-30s %s\n", "time", "actn", "subject", "result" }
      { printf "  %-13s %-5s %-30s %s\n", $1, $2, $3, $4 }'
    printf '%s\n' "$VERDICTS" | awk -F'|' '
      BEGIN { print "["; sep="" }
      { gsub(/"/, "\\\"")
        printf "%s  {\"time\":\"%s\",\"action\":\"%s\",\"subject\":\"%s\",\"result\":\"%s\"}", sep, $1, $2, $3, $4
        sep=",\n" }
      END { print "\n]" }' > "$SESSION/verdicts.json"
    echo "  (saved as JSON: $SESSION/verdicts.json)"
  fi

  PATIENTS_FILE=""
  for f in target/session-patients.txt session-patients.txt; do
    [ -s "$f" ] && PATIENTS_FILE="$f" && break
  done
  if [ -n "$PATIENTS_FILE" ]; then
    cp "$PATIENTS_FILE" "$SESSION/patients.txt"
    echo
    echo "── auditing what your system stored on ${TARGET} ──"
    while IFS= read -r ident; do
      [ -z "$ident" ] && continue
      echo "· auditing patient ${ident}"
      AUDIT_PATIENT_IDENTIFIER="$ident" SHR_URL="$TARGET" FEATURES=features/auditor.feature ./run-tests.sh @auditor || true
    done < "$SESSION/patients.txt"
  else
    echo "(no patient identifiers seen in pushes — skipping the audit)"
  fi

  echo
  echo "session folder:   $(pwd)/$SESSION/"
  echo "latest report:    $(pwd)/target/karate-reports/karate-summary.html"
  exit 0
}
trap cleanup INT TERM

sleep 4
if ! kill -0 "$PROXY_PID" 2>/dev/null; then
  echo "ERROR: proxy failed to start — see $SESSION/proxy.log" >&2
  exit 1
fi
echo "live feed (one line per request):"

feed() {
  tail -n +1 -F "$SESSION/proxy.log" 2>/dev/null | while IFS= read -r line; do
    case "$line" in
      *ZWPROXY\|push\|*\|0\ errors*)  echo "  ✓ $(echo "$line" | sed -E 's/.*ZWPROXY\|push\|([^|]*)\|.*/push \1 — conformant/')" ;;
      *ZWPROXY\|push\|*errors*)       echo "  ✗ $(echo "$line" | sed -E 's/.*ZWPROXY\|push\|([^|]*)\|([0-9]+) errors.*/push \1 — \2 errors (details in X-ZW-Validation \/ proxy.log)/')" ;;
      *ZWPROXY\|pull\|*REJECTED*)     echo "  ✗ $(echo "$line" | sed -E 's/.*ZWPROXY\|pull\|([^|]*)\|.*/pull \1 — rejected: missing patient scope/')" ;;
      *ZWPROXY\|pull\|*\|ok*)         echo "  ✓ $(echo "$line" | sed -E 's/.*ZWPROXY\|pull\|([^|]*)\|.*/pull \1 — patient-scoped, forwarded/')" ;;
      *ZWPROXY\|*forwarded*)          echo "  → $(echo "$line" | sed -E 's/.*ZWPROXY\|[^|]*\|([^|]*)\|.*/\1 passed through/')" ;;
    esac
  done
}
feed &
FEED_PID=$!

# `wait` (unlike a foreground pipeline) is interruptible, so Ctrl+C reaches
# the trap immediately.
wait "$FEED_PID"
