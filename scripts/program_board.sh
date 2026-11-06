#!/usr/bin/env bash
# program_board.sh -- detect the board, then program a bitstream with openFPGALoader.
# Usage: scripts/program_board.sh <bitstream.fs> [cable]
#   cable defaults to ft2232 (the value used in the chat sessions).
# Exit codes: 0 ok, 2 bad arguments or missing file, 3 tool missing, 4 detect failed, 5 programming failed.
set -u
if [ "$#" -lt 1 ]; then echo "usage: $0 <bitstream.fs> [cable]" >&2; exit 2; fi
BIT="$1"; CABLE="${2:-ft2232}"
[ -f "$BIT" ] || { echo "error: bitstream not found: $BIT" >&2; exit 2; }
command -v openFPGALoader >/dev/null 2>&1 || { echo "error: openFPGALoader not on PATH" >&2; exit 3; }
if ! openFPGALoader -c "$CABLE" --detect; then
  echo "error: detect failed on cable '$CABLE'. Check power, cable, udev rules (see toolchain_openfpgaloader.md)." >&2
  exit 4
fi
if ! openFPGALoader -c "$CABLE" "$BIT"; then
  echo "error: programming failed. 'usb bulk write failed' usually means power or cable; replug and retry." >&2
  exit 5
fi
echo "programmed: $BIT"
