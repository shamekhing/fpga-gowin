#!/usr/bin/env bash
# check_env.sh -- report which FPGA tools are on PATH and their versions. Never fails.
# Usage: scripts/check_env.sh
for t in gw_sh openFPGALoader iverilog vvp verilator git; do
  if command -v "$t" >/dev/null 2>&1; then
    printf 'FOUND    %-14s %s\n' "$t" "$(command -v "$t")"
  else
    printf 'MISSING  %-14s\n' "$t"
  fi
done
exit 0
