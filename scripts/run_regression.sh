#!/usr/bin/env bash
# run_regression.sh -- run a regression command, keep the full log, print the summary lines,
# and exit with the command's own exit code (the summary can print even when a suite fails).
# Usage: scripts/run_regression.sh <command> [args...]
# Env:   LOG (default /tmp/regression.log)
set -u
LOG="${LOG:-/tmp/regression.log}"
if [ "$#" -eq 0 ]; then echo "usage: $0 <command> [args...]" >&2; exit 2; fi
"$@" > "$LOG" 2>&1
result=$?
grep -E 'FAIL|FATAL|TIMEOUT|ALL TESTS PASSED|PASS:' "$LOG" | tail -n 24
echo "log: $LOG  exit: $result"
exit "$result"
