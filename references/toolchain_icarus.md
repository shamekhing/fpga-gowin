# Simulation and lint

## Icarus Verilog (iverilog)
Requires `-g2012` for SystemVerilog. Use a file list so the compile order is fixed:

    iverilog -g2012 -s <tb_top> -f filelist.f <tb>.sv -o /tmp/<tb>.out
    vvp /tmp/<tb>.out

Rules:
- Packages must appear before the modules that import them, in both the file list and any script.
- Add `timescale` to RTL and testbench modules to avoid warnings and timing mismatches.
- Icarus cannot elaborate every construct Verilator accepts. A variable index in some constructs fails with an elaboration error. Work around it by checking the wiring with Verilator, or by simplifying the construct.
- Vendor simulation models take defines (device, speed grade, width). Confirm each define against the vendor model before reuse.

## Verilator (lint and elaboration)
    verilator --lint-only -Wno-fatal --top-module <top> <sources>

Use it for elaboration checks on the full design. A clean lint is not proof of correct behavior.

## Regression script
Keep one entry point (for example `run.sh --no-gui`) that runs every suite and returns a nonzero exit code on failure. Report the count per suite, not just the exit code.

## Testbench hygiene
- Initialize every testbench variable. An uninitialized error flag can make a failing test look clean.
- Test state transitions, not only the final value: reset, back-to-back operations, and the first cycle after a stall.
- Compare against a reference model when one exists.

## Waveforms (gtkwave)
If gtkwave fails to launch with a GLIBC or shared-library symbol error, a snap library path is probably being injected by the environment of the editor. Launch it from a clean environment (`env -i` with DISPLAY, HOME and PATH set), or from a terminal outside the editor.

## TODO (confirm before relying on these)
- The `-V` and `--version` checks in SKILL.md are UNVERIFIED on this environment.
- The Verilator flags for the full design (`--timing -Wall`) were used in the chat; confirm the warning count on your version.
