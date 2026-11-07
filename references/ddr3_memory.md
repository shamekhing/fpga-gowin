# DDR3 external memory on Gowin devices

Scope: planning, bring-up and verification of a DDR3 path on a Gowin device,
including custom controllers and the vendor DDR3 memory interface IP. Read
this with `references/memory_architecture.md` (external DDR section) and
`references/board_tang_primer_20k.md`.

Evidence labels used below:
- **Sourced:** taken from a named vendor document (see Sources).
- **Standard practice:** general DDR3 behavior from the JEDEC standard and the
  memory datasheet. Confirm the exact timing values for the chosen part.
- **UNVERIFIED:** Gowin-specific IP behavior not confirmed from Gowin
  documentation. Confirm before relying on it.

## 1. Know what memory is on the board

- **Sourced:** Sipeed Tang Primer 20K Datasheet v1.0 lists the core board with
  1 Gbit (128 MB) DDR3 SDRAM and states the board is "DDR3 SODIMM shape".
- **Conflict:** retail listings for the same board state "1 GB" and "32 MB" of
  memory. Those listings contradict the vendor datasheet and the Sipeed wiki
  ("128M DDR3"). Use the datasheet, then confirm with the board schematic and
  the physical part marking.
- **Standard practice:** record the exact DRAM part number, density, width
  (x8 or x16), speed grade and rank count from the schematic before choosing
  any controller parameter. The controller must match the part, not the board
  name.

## 2. Choose the controller source deliberately

There are two paths. Keep them separate in the project notes:

1. **A vendor-generated memory controller** (IP). Its initialization, calibration
   and most timing are handled by the generated block. Obtain, use and configure
   it as described in `references/ip_cores.md`.
2. **A custom or vendored controller** (for example a SystemVerilog controller
   from an open-source project). This path owns every timing rule and every
   calibration step, and you must verify each of them.

**Standard practice:** do not mix the two in one design unless the boundary is
written down. Mixing them produces failures that look like controller bugs but
come from a mismatched configuration.

**UNVERIFIED:** the specific port list, calibration status signals and required
constraints of any vendor memory IP. Extract these from that IP's own
documentation and generated files for the project.

## 3. Comparing a custom controller against vendor IP

When the two disagree, compare them field by field before debugging RTL:

1. Extract the vendor configuration from the IP's configuration file and generated
   wrapper: memory part, density, burst length, CAS latency, write latency,
   clock frequency, refresh behavior, and ODT/drive settings.
2. Build the same table from the custom controller's parameters and
   localparams.
3. Mark each field as matching, different by design, or unknown. Unknown
   fields are the first things to resolve.
4. Check the initialization sequence (reset, clock stable, power-up delay,
   mode-register writes, ZQ calibration, calibration sequence) against the
   memory datasheet, not against the vendor IP.

A mismatch in burst length or CAS latency alone causes data corruption that
looks random. Check those first.

## 4. Standard DDR3 behavior the controller must honor

These are **Standard practice** rules. Take exact numbers from the memory
datasheet for the chosen speed grade and density.

- **Initialization before access.** No read or write may be issued until the
  power-up delay, mode-register programming and ZQ calibration complete. An
  access during initialization can corrupt mode registers.
- **Calibration before use.** Read and write leveling, DQS gate training, and
  read/write delay calibration must finish before user data is accepted.
  Expose a calibration-done status and gate user requests on it.
- **Periodic refresh.** Every row must be refreshed within the refresh
  interval (tREFI). At normal temperature this is typically 7.8 µs, halved
  above the extended temperature range. Refresh must be issued even when the
  user is idle. A controller that refreshes only when idle will eventually miss
  deadlines under load.
- **Refresh cycle time.** After a refresh command, no activate may be issued
  for tRFC, which depends on density. Count it in memory-controller clocks,
  rounding up.
- **Burst length.** DDR3 uses fixed burst length 8 (BL8) or burst chop 4
  (BC4). The user data width and the controller's burst handling must agree,
  otherwise writes land in the wrong columns.
- **Write data mask.** Partial-word writes need the data mask. A controller
  that ignores it overwrites neighboring bytes.
- **Latency.** Read data returns after CAS latency plus the controller's
  internal pipeline. The user interface must track `valid` against the
  latency, not a fixed guess.

## 5. Refresh and write-burst failures

These are the two failure classes most often seen in custom DDR3 controllers.

**Refresh starvation.** Symptoms: data errors that appear only after a long
run, or only under heavy traffic. Check:
- refresh interval is computed in the correct clock domain (memory clock versus
  user clock);
- refresh request has priority over reads and writes once its deadline is
  near, and is not blocked by a pending row-open;
- the controller counts refreshes actually issued, not refresh requests raised;
- the simulation runs long enough to cross several refresh intervals under
  full load. A short test never triggers this.

**Write-burst corruption.** Symptoms: writes appear shifted, partly overwritten,
or the wrong half of a burst is returned. Check:
- burst length in the controller matches the memory mode register;
- the write data word is presented on the correct clock edges relative to the
  write strobe (DQS);
- data mask bits line up with the byte lanes of the write;
- the user-side write data is held stable until the controller accepts it
  (valid/ready, see `rtl_design_patterns.md`).

## 6. Clock domain crossings

The user interface and the memory interface usually run on different clocks.
Treat every crossing as a CDC:
- use an explicit asynchronous FIFO or a handshake protocol for requests and
  data;
- size the FIFO for worst-case refresh and calibration stalls;
- reset each domain's logic with its own synchronized reset;
- do not sample multi-bit request fields across the boundary without a
  handshake.

See `references/clocking_cdc.md` and `pipelines/debug_cdc.md`.

## 7. Verification before application use

Follow `references/verification/hardware_validation.md` for the on-board
checks. In simulation, use a memory model for the exact part, not a generic
behavioral array, so timing and initialization are checked.

Minimum test set:
1. **Reset and calibration:** the design holds user requests until calibration
   reports done, and reports failure if calibration fails.
2. **Walking bits:** write and read back a walking one and a walking zero on
   every data line, at several addresses.
3. **Address as data:** write each address's own value and read it back, to
   find address-line and bank-mapping faults.
4. **Full-width burst:** write and read full bursts with every data mask
   pattern, including partial writes.
5. **Refresh under load:** run continuous traffic for several refresh intervals
   and verify no request misses its deadline and no data is corrupted.
6. **Random traffic against a reference model:** compare every read with a
   golden array, including reads that follow writes to the same address.
7. **Backpressure:** hold the user side not-ready for long periods and confirm
   no data is dropped or duplicated.

On hardware, run the walking-bit and address-as-data tests first, then the
refresh-under-load test, and record the observed results with the bitstream
hash.

## 8. What the board file does and does not tell you

`board/tang_primer_20k.json` records the FPGA resources. It does not record
the DDR3 pin assignments, the memory part number, or the calibration
constraints. Those come from the schematic and the generated IP constraints
and must be added to the project before any DDR3 build is trusted.

## Sources

- Sipeed, "Sipeed Tang Primer 20K Datasheet v1.0" (dl.sipeed.com): 1 Gbit
  DDR3 SDRAM, SODIMM form factor, 41,472 bits SSRAM, 46 BSRAM blocks (828 Kbit).
- Sipeed wiki, "Tang Primer 20K": 128 MB DDR3 on the core board.
- Gowin, "DK-START-GW2A18 V1.0 User Guide" (DBUG354): describes a different
  board with 2 Gbit DDR3 (16-bit). Not the Tang Primer 20K; cited only to show
  Gowin's DDR3 wiring documentation exists.
- JEDEC DDR3 standard and the datasheet of the specific DRAM part: source for
  Section 4 values. Not yet attached to this skill; add the part's datasheet.

## TODO (open until confirmed)

- Vendor memory IP documentation: add its port list, calibration status signals
  and required constraints (see `references/ip_cores.md`, section 2).
- DRAM part number and speed grade from the Tang Primer 20K schematic.
- Pin assignments and I/O bank voltages for the DDR3 path.
- Whether the vendor IP and a custom controller can share one physical pin
  set without a mux.
