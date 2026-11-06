#!/usr/bin/env bash
# gowin_batch.sh -- run a Gowin project through gw_sh in batch mode (run all), with the
# environment fixes from references/gowin_ide_cli.md.
# Usage: GOWIN_HOME=<install dir> TOP_MODULE=<top> scripts/gowin_batch.sh <project.gprj>
# Exit codes: 0 ok, 2 bad arguments or missing project, 3 GOWIN_HOME or gw_sh missing, other = gw_sh exit code.
set -u
set -o pipefail
if [ "$#" -lt 1 ]; then echo "usage: GOWIN_HOME=<dir> $0 <project.gprj>" >&2; exit 2; fi
PROJ="$1"
[ -f "$PROJ" ] || { echo "error: project file not found: $PROJ" >&2; exit 2; }
[ -n "${GOWIN_HOME:-}" ] || { echo "error: set GOWIN_HOME to the Gowin EDA install folder" >&2; exit 3; }
[ -n "${TOP_MODULE:-}" ] || { echo "error: set TOP_MODULE to the design top module" >&2; exit 3; }
GW="$GOWIN_HOME/IDE/bin/gw_sh"
[ -x "$GW" ] || { echo "error: gw_sh not executable at $GW" >&2; exit 3; }
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/gowin-cache}"
mkdir -p "$XDG_CACHE_HOME"
FREETYPE=/usr/lib/x86_64-linux-gnu/libfreetype.so.6
printf 'open_project %s\nset_option -verilog_std sysv2017\nset_option -top_module %s\nrun all\nexit\n' \
  "$(readlink -f "$PROJ")" "$TOP_MODULE" | \
  QT_QPA_PLATFORM=minimal QT_OPENGL=software QT_QUICK_BACKEND=software \
  QT_XCB_GL_INTEGRATION=none LD_PRELOAD="$FREETYPE" "$GW"
exit $?
