# Changelog

## 1.0
- Initial skill built from the FPGA chat export (stage 1 to stage 3 consolidation).
- Covers Gowin EDA build settings, openFPGALoader programming, Icarus and Verilator checks, git workflow, pitfalls and pipelines.
- Case-specific fixes and unverified items were removed. Re-verify the commands on your tool versions.

## 1.1
- Added pitfalls 26 to 33 from the late-September to early-November sessions.
- Added clock-period, generated-clock, resource-metric, project-file and memory-init notes to toolchain_gowin.md.
- Added references/verification.md (differential testing, baselines, bring-up).
- All in-scope sessions are now processed (batches 1 to 11). Commands are still unverified on current tool versions.
- Pitfall ranking corrected by counted frequency (work-only sessions). Entries 2 to 4 flagged as single events.

## 1.2
- Stage 7 check: 38 commands confirmed in the chat, 9 partial matches kept, 5 marked UNVERIFIED (find for ftdi_sio, tee logging, version checks).
- No command has been run on current tool versions.

## 1.3
- Added references/gowin_ide_cli.md: gw_sh environment fixes (freetype preload, cache dir, offscreen Qt), build.tcl, SDC/CST examples, programmer_cli usage and cable names, licence and education-edition notes.
- Paths generalized to <GOWIN_HOME>. The chat's user-specific paths are not in the skill.
- 1.3 addendum: the most-run Gowin command (piped gw_sh batch, 16 runs), the GUI launch command (6 runs) and the openFPGALoader calls (17 runs) added to references/gowin_ide_cli.md.
- Note: review transcripts replay real tool calls. They are the main source of command data for the 2026-10-31 build. Use them for commands; do not count them as separate occurrences.

## 1.4
- Added references/terminal_commands.md: the terminal commands from the FPGA sessions, including review replays, grouped by task (build, program, IDE launch and diagnosis, simulation, regression, lint, git, baseline comparison, code reading, safe edits). C++ and game commands removed.

## 1.5 (structure matches the original plan)
- Renamed references to the planned names: board_tang_primer_20k.md, toolchain_icarus.md.
- Added README.md at the repo root: purpose, usage, layout, script test status, verification status, sources, open items.
- Added tested scripts: check_env.sh, run_regression.sh, program_board.sh, gowin_batch.sh, and scripts/README.md with exit codes.
- Every pitfall now carries a source tag (batch and session). Added Sources and TODO sections.
- Added TODO sections to the board, Icarus and openFPGALoader references.
- Scripts tested in the sandbox where the tool exists; the rest are marked not run.

## 1.6
- Expanded the Gowin TA1132 clock warning with an SDC primary-clock example, source-period and port-name checks, generated-clock guidance, and timing-report verification.
- Added a 2026-11-06 field report as a source; it is recorded as a recurring pitfall without assigning an unsupported frequency count.

## 1.7
- Documented that SDC files must be registered in the `.gprj` `FileList` with `type="file.sdc"` and `enable="1"`.
- Added a verification rule requiring a fresh place-and-route timing report, and requiring unavailable `gw_sh` validation to be reported as unverified.

## 1.8
- Added `pipelines/synthesize_route.md` for headless Gowin synthesis, placement, routing, timing, power, bitstream generation, and report verification.
- Linked the new pipeline from `SKILL.md`.

## 1.9
- Hardened `gowin_batch.sh` with `pipefail` and explicit SystemVerilog 2017 mode.
- Made TA1132/error scanning and resource/clock report checks mandatory in the synthesis-and-route pipeline.

## 1.10
- Made the top module an explicit `TOP_MODULE` input to the batch pipeline so clean builds do not depend on deleted IDE process-state files.

## 1.11
- Added utilization sanity checks that compare synthesis hierarchy resources with PNR totals and flag unexpectedly tiny designs, zero expected BSRAM, constant outputs, and optimized-away datapaths.

## 1.12
- Added first-order resource estimation for weight memories, membrane state, counters, and parallel versus time-multiplexed layers.
- Documented mandatory reconciliation of estimated resources, synthesis hierarchy, and PNR totals, including a generic layer-size mismatch example.

## 1.13
- Reviewed the revision covering 1.9 to 1.12 and kept its changes.
- Historical note: this earlier estimate incorrectly used 36-Kbit blocks. Corrected in 1.19 to the nominal 18-Kbit B-SRAM capacity documented for the Tang Primer 20K configuration.
- Marked the skeleton-build numbers in synthesize_route.md as a worked example, not a general rule.
- Renamed the README title to match the skill name.

## 1.14
- Generalized the skill: removed project names, file paths, pin numbers and the SNN worked example from the general references; the SNN calculation is now a generic example.
- Checked openFPGALoader against its upstream README: -m is the default SRAM write, -f writes flash on Gowin devices; cable names vary by adapter.
- Added the Tcl option for dual-purpose pins (-use_<pin>_as_gpio) and the Gowin Tcl command list, both web-checked with the source noted.
- Still unverified on your tools: every command in the skill. Confirm the set_option names with your Gowin version.

## 1.15
- Added templates/: LED blink RTL with a testbench (passes in Icarus 12.0 in the sandbox), build Tcl template, SDC and CST templates with placeholders.
- Added a Quick start section to SKILL.md.
- Moved provenance tags out of the pitfall text into a provenance section, so entries read as procedures.
- PR2017/PR2028 fix now names the Tcl option, with the source noted (two community Gowin projects; not confirmed in Gowin's own guide).

## 1.16
- Added scripts/verify_build.sh: checks the bitstream, PNR report, ERROR and TA1132 lines, and prints slack lines for a human to judge. Tested with four cases.
- Added scripts/new_project.sh: copies the starter templates into a new project and fills in the top module name. Tested.
- Error scan is case-sensitive for Gowin tags so ordinary words like 'errors' do not fail a build.
- SKILL.md now includes a verify step after every build and the new project command.

## 1.17
- Added references/naming_conventions.md, generalized from the project document (project name and examples removed).
- Added scripts/check_naming.sh, which flags mechanically checkable violations. Tested: conforming sample passes, violating sample gives 7 findings and exit 1.
- Renamed the testbench template to led_blink_top_tb.sv with module led_blink_top_tb, to follow the _tb suffix rule. new_project.sh updated to match.

## 1.18
- Added references/minimal_resource_design.md: time-multiplexing, block RAM for state, synchronous RAM inference, measured width sizing, cheap arithmetic, and a change-measure loop. Each rule cites a source; Gowin-specific RAM rules are marked unverified.

## 1.19
- Added RTL design patterns, clocking/CDC, memory architecture and DSP/fixed-point references.
- Added accelerator references for MAC arrays, neural networks, SNN/LIF, quantization, dataflow and performance estimation.
- Added verification references for strategy, self-checking benches, reference models, assertions, randomized testing, formal methods and hardware validation.
- Added interface references for UART, SPI, I2C, ready/valid and external-device links.
- Added RTL, CDC, memory-inference and hardware-debug pipelines plus review/validation checklists.
- Added specialized role guides for RTL architecture, implementation, verification, synthesis analysis and hardware debugging.
- Added `parse_gowin_reports.py` (keyword index, not a normalized report parser) and `estimate_memory.py` (capacity-only lower bound).
- Corrected B-SRAM capacity arithmetic to nominal 18-Kbit blocks: 401,408 logical bits require at least 22 blocks by capacity alone. Actual mapping depends on supported primitive modes and port requirements.
- Added a Tang Primer 20K planning resource JSON. It records the nominal 46 x 18 Kibit (828 Kibit) B-SRAM capacity and marks all board figures for confirmation against the exact device datasheet.
- Updated SKILL.md routing and README coverage. New scripts are syntax-checked and locally smoke-tested; no Gowin installation or physical board was available for hardware validation.

## 1.20
- Added references/rtl_structure.md: interface contracts before bodies, module responsibility and clock-domain rules, package scope, bundling criteria, port grouping, top-level wiring, dead-signal removal, and tool-support checks for struct ports.
- Added structure rules to SKILL.md (working rule 14), the RTL review checklist, and the RTL implementer role.
- Removed project-specific example values from pipelines/synthesize_route.md and project references from this changelog.
- Corrected version order (1.13 now precedes 1.14).

## 1.21
- Added references/ddr3_memory.md: board memory facts with a conflict note, controller-source choice, field-by-field comparison procedure, standard DDR3 rules (initialization, calibration, refresh, burst length, data mask), refresh and write-burst failure checks, CDC, and a minimum verification set. Gowin DDR3 IP specifics are marked UNVERIFIED.
- Restored board ssram_bits (41,472) and added SDRAM 1 Gbit, both from the Sipeed datasheet. The 1.20 removal was an error and is reversed here.

## 1.22
- Added references/ip_cores.md: a device-independent guide to obtaining an IP (source, version, license, integrity), using it through a project wrapper, configuring it reproducibly (versioned configuration, regenerate rather than hand-edit), verifying it in simulation, and comparing configurations.
- Routed generic IP questions to ip_cores.md in SKILL.md.
- references/ddr3_memory.md now defers IP obtain/use/configure details to ip_cores.md and keeps only memory-specific guidance.

