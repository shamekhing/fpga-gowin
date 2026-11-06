#!/usr/bin/env bash
# new_project.sh -- copy the starter templates into a new project folder.
# Fills in only the top module name. Other placeholders (<...>) must be filled by hand.
# Usage: scripts/new_project.sh <dest_dir> <top_module_name>
# Exit codes: 0 ok, 2 bad arguments or destination exists, 3 templates missing.
set -eu
if [ "$#" -ne 2 ]; then echo "usage: $0 <dest_dir> <top_module_name>" >&2; exit 2; fi
DEST="$1"; TOP="$2"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$ROOT/templates"
[ -d "$TPL" ] || { echo "error: templates not found at $TPL" >&2; exit 3; }
[ -e "$DEST" ] && { echo "error: $DEST already exists; choose a new folder" >&2; exit 2; }
mkdir -p "$DEST/rtl" "$DEST/constraints"
cp "$TPL/led_blink_top.sv" "$DEST/rtl/$TOP.sv"
sed -i "s/led_blink_top/$TOP/g" "$DEST/rtl/$TOP.sv"
cp "$TPL/led_blink_top_tb.sv" "$DEST/rtl/${TOP}_tb.sv"
sed -i "s/led_blink_top/$TOP/g" "$DEST/rtl/${TOP}_tb.sv"
cp "$TPL/build_template.tcl" "$DEST/build.tcl"
sed -i "s/<top_module>/$TOP/g" "$DEST/build.tcl"
cp "$TPL/constraints_template.sdc" "$DEST/constraints/board.sdc"
cp "$TPL/constraints_template.cst" "$DEST/constraints/board.cst"
left=$(grep -RhoE '<[A-Za-z_][A-Za-z0-9_ ]*>' "$DEST" | sort -u | wc -l)
echo "created $DEST with top module '$TOP'"
echo "placeholders still to fill: $left (see: grep -rn '<' $DEST)"
