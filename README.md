# fpga-gowin

What this repo is: a reusable skill for FPGA work on Gowin devices (Tang Primer 20K / GW2A-18C class) with Gowin EDA, openFPGALoader, Icarus Verilog, Verilator and SystemVerilog RTL. It was distilled from about 180 AI coding sessions (several AI coding-agent tools) in VS Code, covering roughly September to November 2026.

## How to use it
1. Start with `SKILL.md`. It has a table of which file to read for each task.
2. Load one reference or pipeline at a time. Each file is short so a session loads only what it needs.
3. Check the tools first: `scripts/check_env.sh`.
4. Use the scripts in `scripts/` for repeatable steps. They exit with documented codes.

## Layout (matches the original plan)
- `SKILL.md`: entry point, task table, working rules.
- `references/`
  - `rtl_structure.md`: package scope, bundling rules, module boundaries, top-level wiring.
  - `board_tang_primer_20k.md`: board setup, pins, I/O, programming reliability.
  - `toolchain_gowin.md`: Gowin build settings, process config, reports, constraints.
  - `toolchain_openfpgaloader.md`: programming and detection.
  - `toolchain_icarus.md`: simulation, lint, testbench hygiene.
  - `pitfalls.md`: errors ranked by counted frequency, each tagged with its source.
  - Extra files beyond the plan: `gowin_ide_cli.md` (IDE and programmer command line), `terminal_commands.md` (every terminal command used, grouped), `verification.md` (how to prove a result), `git_workflow.md`.
- `pipelines/`: project creation, module addition, synthesis/route, timing, RTL, CDC, memory-inference and hardware debugging.
- `scripts/`: repeatable helpers, including report keyword extraction and memory capacity estimation (see script documentation).
- `checklists/`: RTL review, pre-synthesis and hardware validation gates.
- `agents/`: role-specific procedures for architecture, RTL implementation, verification, synthesis analysis and hardware debugging.
- `board/tang_primer_20k.json`: planning resource inventory with unresolved datasheet discrepancy explicitly recorded.
- `templates/`: starter RTL (LED blink with a testbench that passes in Icarus), build Tcl, SDC and CST templates with placeholders.
- `references/minimal_resource_design.md`: architecture and coding rules for minimal LUT, register and block RAM use, with sources.
- `references/naming_conventions.md`: naming rules for RTL, testbenches, scripts and docs.
- `CHANGELOG.md`: version history.

## Scripts and what was tested
| Script | What it does | Tested here |
|---|---|---|
| `scripts/check_env.sh` | reports which tools are on PATH | run; found iverilog, vvp, git; gw_sh, openFPGALoader, verilator missing |
| `scripts/run_regression.sh` | runs a command, keeps the log, returns the command's exit code | run with a passing and a failing command, and with a real Icarus test (exit 0) |
| `scripts/program_board.sh` | detect, then program a bitstream | argument and missing-file paths (exit 2); missing-tool path (exit 3). Not run against a board |
| `scripts/verify_build.sh` | checks the bitstream, PNR report, ERROR/TA1132 lines, and prints slack lines | tested with a passing build, a TA1132 log, a missing bitstream, and no arguments (exit 0, 1, 1, 2) |
| `scripts/new_project.sh` | copies the starter templates and sets the top module | tested: creates the tree, fills the top name, refuses an existing folder (exit 2) |
| `scripts/check_naming.sh` | flags naming violations that can be checked mechanically (module and file names, _tb, _t/_s/_e suffixes, parameter case, in_/out_ ports) | tested on a conforming sample (exit 0) and a violating sample (7 findings, exit 1); no arguments exits 2 |
| `scripts/gowin_batch.sh` | gw_sh batch build with the environment fixes | argument and GOWIN_HOME paths (exit 2, 3). Not run against a Gowin install |

Scripts marked "not run" need your tools and board before they count as verified.

## Added engineering coverage

- RTL patterns, arithmetic sizing, handshakes and pipeline contracts.
- Clock architecture, CDC, reset crossing and timing-constraint review.
- Embedded memory inference, FIFO semantics and external DDR validation.
- DSP/MAC and fixed-point design considerations.
- Accelerator architecture, MAC arrays, quantization, SNN/LIF and performance estimation.
- Interface guidance for UART, SPI, I2C, ready/valid and external MCU links.
- Expanded verification strategy, self-checking testbenches, reference models, assertions, randomized tests, formal verification and hardware validation.

New helper scripts are convenience tools and have not been validated against every Gowin report format or board configuration. Their output must be checked against the original report or datasheet.

## What is verified
- Verification against the chat export: 38 commands and paths confirmed in the chat, 9 partial matches, 5 marked UNVERIFIED (see CHANGELOG 1.2).
- No command has been run on current tool versions. Run `scripts/check_env.sh` and then the confirmed commands on your machine before relying on them.

## Sources
Every pitfall is tagged with its batch and session. The batch notes (`stage2_batch1_procedures.md` to `stage2_batch11_procedures.md`) list the session IDs behind each batch. Approval-review transcripts replay real tool calls; their replays are counted once, not as separate occurrences.

## Open items
See the TODO sections at the end of `pitfalls.md` and the open-items list in the project notes. The main open items are: which top module each project uses, whether the subtract-with-borrow fix is committed, the board clock constraint, and the USB device-controller wiring.
