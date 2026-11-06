#!/usr/bin/env bash
# check_naming.sh -- flag SystemVerilog naming violations that can be checked mechanically.
# Based on references/naming_conventions.md. It reports candidates; judge each one.
# Checks: module name is snake_case and matches the file basename; testbench files and
# modules end in _tb; typedef suffixes (_t, _s, _e); parameters are UPPER_SNAKE_CASE;
# ports do not use in_/out_ prefixes.
# Usage: scripts/check_naming.sh <dir_or_file> [...]
# Exit codes: 0 no findings, 1 findings, 2 bad arguments.
set -u
if [ "$#" -lt 1 ]; then echo "usage: $0 <dir_or_file> [...]" >&2; exit 2; fi
files=()
for arg in "$@"; do
  if [ -d "$arg" ]; then while IFS= read -r f; do files+=("$f"); done < <(find "$arg" -name '*.sv' -type f)
  elif [ -f "$arg" ]; then files+=("$arg")
  else echo "error: not found: $arg" >&2; exit 2; fi
done
TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT
for f in "${files[@]}"; do
  base=$(basename "$f" .sv)
  # module names
  grep -nE '^[[:space:]]*module[[:space:]]+[A-Za-z_]' "$f" | while IFS=: read -r ln rest; do
    name=$(echo "$rest" | sed -E 's/^[[:space:]]*module[[:space:]]+([A-Za-z_][A-Za-z0-9_]*).*/\1/')
    [[ "$name" =~ ^[a-z][a-z0-9_]*$ ]] || echo "$f:$ln: module '$name' is not lowercase snake_case" >> "$TMP"
    if [[ "$base" == *_tb ]]; then
      [[ "$name" == *_tb ]] || echo "$f:$ln: testbench module '$name' should end in _tb" >> "$TMP" >> "$TMP"
    elif [[ "$name" == tb_* ]]; then
      echo "$f:$ln: module '$name' uses a tb_ prefix; use a _tb suffix" >> "$TMP"
    fi
    if [ "$name" != "$base" ] && [[ "$name" != *_pkg ]]; then
      echo "$f:$ln: module '$name' does not match file basename '$base'" >> "$TMP"
    fi
  done
  # typedef suffixes
  grep -nE '^[[:space:]]*typedef[[:space:]]+(enum|struct)' "$f" | while IFS=: read -r ln rest; do
    if echo "$rest" | grep -q 'enum'; then want='_e'; else want='_s'; fi
    line=$(sed -n "${ln}p" "$f")
    echo "$line" | grep -q '' || continue
    # name follows the closing brace: "} name;"
    name=$(awk -v s="$ln" 'NR>=s && /}/ {print; exit}' "$f" | sed -E 's/.*}[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*;.*/\1/')
    [ -n "$name" ] && [[ "$name" != *"$want" ]] && echo "$f:$ln: type '$name' should end in $want" >> "$TMP" >> "$TMP"
  done
  grep -nE '^[[:space:]]*typedef[[:space:]]+logic' "$f" | while IFS=: read -r ln rest; do
    name=$(echo "$rest" | sed -E 's/.*[[:space:]]([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*;.*/\1/')
    [[ "$name" == *_t ]] || echo "$f:$ln: alias type '$name' should end in _t" >> "$TMP" >> "$TMP"
  done
  # parameters must be UPPER_SNAKE_CASE
  grep -nE '(parameter|localparam)[[:space:]]+(int[[:space:]]+|logic[[:space:]]+\[[^]]*\][[:space:]]+|[[:space:]]+)' "$f" | while IFS=: read -r ln rest; do
    name=$(echo "$rest" | sed -E 's/.*(parameter|localparam)[[:space:]]+(int[[:space:]]+|logic[[:space:]]*(\[[^]]*\])?[[:space:]]*|)?([A-Za-z_][A-Za-z0-9_]*).*/\4/')
    [ -n "$name" ] && [[ "$name" =~ ^[A-Z][A-Z0-9_]*$ ]] || { [ -n "$name" ] && echo "$f:$ln: parameter '$name' should be UPPER_SNAKE_CASE" >> "$TMP"; }
  done
  # ports with in_/out_ prefixes
  grep -nE '^[[:space:]]*(input|output|inout)[[:space:]].*\b(in_|out_)[A-Za-z0-9_]+' "$f" | while IFS=: read -r ln rest; do
    echo "$f:$ln: port uses an in_/out_ prefix; name the role instead of the direction" >> "$TMP"
  done
done
cat "$TMP"
findings=$(grep -c . "$TMP")
if [ "$findings" -eq 0 ]; then echo "no naming findings in ${#files[@]} file(s)"; exit 0; fi
echo "$findings finding(s); review each against references/naming_conventions.md"
exit 1
