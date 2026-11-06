#!/usr/bin/env python3
"""Extract common resource/timing lines from Gowin text reports.

This is a convenience index, not a complete parser for every Gowin version.
Always inspect the original report and verify the report section/instance.
"""
from __future__ import annotations
import argparse
import re
from pathlib import Path

PATTERNS = {
    "LUT": re.compile(r"\bLUT(?:4|[0-9]+)?\b", re.I),
    "FF": re.compile(r"\b(?:REG|FF|FLIP[- ]?FLOP)\b", re.I),
    "BSRAM": re.compile(r"\b(?:BSRAM|B[- ]?SRAM|BLOCK RAM)\b", re.I),
    "DSP": re.compile(r"\b(?:DSP|MULT18X18|MULT18)\b", re.I),
    "SLACK": re.compile(r"\bslack\b", re.I),
    "FREQUENCY": re.compile(r"\b(?:frequency|Fmax|MHz)\b", re.I),
    "ERROR": re.compile(r"\bERROR\b|\bTA1132\b", re.I),
    "WARNING": re.compile(r"\bWARNING\b", re.I),
}

def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("reports", nargs="+", type=Path, help="Gowin report or log files")
    ap.add_argument("--all-matches", action="store_true", help="print every matching line")
    args = ap.parse_args()
    missing = 0
    for path in args.reports:
        if not path.is_file():
            print(f"MISSING: {path}")
            missing += 1
            continue
        print(f"\n## {path}")
        try:
            lines = path.read_text(errors="replace").splitlines()
        except OSError as exc:
            print(f"READ ERROR: {exc}")
            missing += 1
            continue
        found = 0
        for category, pattern in PATTERNS.items():
            matches = [(i, line.strip()) for i, line in enumerate(lines, 1) if pattern.search(line)]
            if matches:
                found += len(matches)
                chosen = matches if args.all_matches else matches[:8]
                print(f"[{category}] {len(matches)} matching line(s)")
                for number, line in chosen:
                    print(f"  {number}: {line}")
                if len(matches) > len(chosen):
                    print(f"  ... {len(matches)-len(chosen)} more; rerun with --all-matches")
        if not found:
            print("No recognized resource/timing/error keywords found. Inspect report manually.")
    print("\nNOTE: keyword matches are not normalized resource totals. Check original report sections.")
    return 1 if missing else 0

if __name__ == "__main__":
    raise SystemExit(main())
