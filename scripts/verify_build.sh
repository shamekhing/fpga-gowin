#!/usr/bin/env bash
# verify_build.sh -- check the outputs of a Gowin build before calling it verified.
# Checks: bitstream exists and is non-empty; PNR report exists; no ERROR or TA1132 lines
# in the build logs; slack and clock lines are present in the timing report.
# It does NOT judge the slack value: read the printed lines and compare them with your target.
# Usage: scripts/verify_build.sh <output_base_name> [project_dir]
# Exit codes: 0 all checks passed, 1 a check failed, 2 bad arguments.
set -u
if [ "$#" -lt 1 ]; then echo "usage: $0 <output_base_name> [project_dir]" >&2; exit 2; fi
BASE="$1"; DIR="${2:-.}"
cd "$DIR" || { echo "error: cannot enter $DIR" >&2; exit 2; }
fail=0
FS="impl/pnr/${BASE}.fs"
if [ -s "$FS" ]; then echo "PASS bitstream: $FS"; else echo "FAIL bitstream missing or empty: $FS"; fail=1; fi
RPT=$(ls -t impl/pnr/*.rpt.txt 2>/dev/null | head -n 1)
if [ -n "$RPT" ]; then echo "PASS PNR report: $RPT"; else echo "FAIL no impl/pnr/*.rpt.txt report"; fail=1; fi
# Gowin reports use uppercase ERROR and TA1132; match those case-sensitively so ordinary words like 'errors' do not fail the check.
BAD=$( { grep -RnE '(^|[^[:alnum:]])(ERROR|TA1132)([^[:alnum:]]|$)' impl/gwsynthesis impl/pnr 2>/dev/null; grep -RniE 'determined to be a clock.*not created' impl/gwsynthesis impl/pnr 2>/dev/null; } )
if [ -z "$BAD" ]; then echo "PASS no ERROR or TA1132 lines in build logs"; else echo "FAIL build log problems:"; echo "$BAD" | head -n 20; fail=1; fi
if [ -n "$RPT" ] && grep -qiE 'slack' "$RPT"; then
  echo "INFO slack lines from $RPT (read these against your target):"
  grep -iE 'slack' "$RPT" | head -n 10
else
  echo "FAIL no slack lines found in the timing report; timing is not verified"; fail=1
fi
exit "$fail"
