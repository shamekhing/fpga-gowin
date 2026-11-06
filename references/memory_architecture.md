# FPGA memory architecture

## Choose memory by access pattern

| Structure | Typical use | Main trade-off |
|---|---|---|
| Flip-flop array | Tiny, highly asynchronous or multiported state | High logic/register cost |
| Distributed/LUT memory | Small tables where supported | Consumes LUT fabric |
| Embedded block RAM | Buffers, tables, weights, state arrays | Fixed port modes and synchronous latency |
| External DDR | Large datasets and frame buffers | Controller/PHY complexity and bandwidth latency |
| FIFO | Decoupling producer and consumer rates | Adds storage and control latency |

## Inference requirements

Synthesis infers embedded memory only when the RTL access pattern matches a supported primitive. Read the device family memory guide and inspect the inferred-resource report. Common inference blockers include asynchronous reads, unsupported port combinations, reset loops that clear every location, and incompatible read-during-write semantics.

Do not assume that a behavioral array maps to block RAM. Confirm the mapped primitive and its width/depth configuration in the synthesis report.

## Capacity calculations

Logical storage bits are `depth * width`. Physical block count depends on the device primitive capacity and supported width/depth modes, plus parity or byte-enable configuration and port requirements. A raw bit-count division is only a lower bound.

For the Tang Primer 20K configuration documented in this repository, the stated device resources are 46 B-SRAM blocks totaling 828 Kbits, nominally 18 Kbits per block. Confirm these figures against the exact FPGA part and current vendor datasheet before using them in a final budget. A 401,408-bit logical array therefore requires at least `ceil(401408 / 18432) = 22` nominal blocks by capacity alone; actual mapping can require more or may be impossible for a given port/width arrangement.

## Read latency and collision semantics

Document whether reads are combinational or registered, and what happens when a read and write target the same address in one cycle. Possible behaviors include read-first, write-first, or no-change, depending on primitive configuration. Never let the design depend on unspecified collision behavior.

## FIFO design

For synchronous FIFOs, test empty/full transitions, simultaneous push/pop, pointer wraparound and reset. For asynchronous FIFOs, use a recognized Gray-pointer architecture and synchronize pointers across domains. Do not derive a FIFO's safety from simulation alone.

## External DDR

Treat the DDR controller as a subsystem with its own clocking, calibration, arbitration, refresh, burst, alignment and error-reporting requirements. Validate the memory interface with a dedicated walking-bit/address/data test before using it as application storage. Buffer application traffic to absorb latency and burst efficiently.

## Memory design checklist

- [ ] Access pattern and port count are specified.
- [ ] Read latency and collision behavior are specified.
- [ ] Reset behavior does not unintentionally prevent RAM inference.
- [ ] Synthesis report confirms the expected primitive count and mode.
- [ ] Capacity calculation includes width/depth packing constraints.
- [ ] FIFO boundary and wraparound tests pass.
- [ ] External memory passes standalone hardware tests before integration.
