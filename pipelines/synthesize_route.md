# Synthesize, place, route, and generate bitstream

Use this pipeline for a complete headless Gowin build from an existing `.gprj`
project. It runs synthesis, placement, routing, timing analysis, power
analysis, and bitstream generation.

## 1. Check the environment

```bash
command -v gw_sh
test -x "$GOWIN_HOME/IDE/bin/gw_sh"
```

Set `GOWIN_HOME` to the Gowin installation containing `IDE/bin/gw_sh`. The
repository helper also configures a writable cache and the Linux font-library
workaround:

```bash
GOWIN_HOME=<GOWIN_HOME> TOP_MODULE=<top_module> \
  scripts/gowin_batch.sh <project>.gprj
```

The helper exits with:

- `0`: Gowin completed the requested build.
- `2`: missing project or invalid arguments.
- `3`: missing `GOWIN_HOME`, `TOP_MODULE`, or `gw_sh`.
- Any other value: the `gw_sh` exit code.

The helper sets the requested top module, enables SystemVerilog 2017 before
running the flow, and uses `pipefail`, so parser, synthesis, placement, or
routing failures cannot be masked by the command pipe.

## 2. Confirm project inputs before building

Check the `.gprj` file for:

- the intended top module and device;
- every SystemVerilog source, with packages before dependent modules;
- the `.cst` pin constraints;
- every `.sdc` timing constraint, registered as `type="file.sdc"`.

The top-level clock name must match across HDL, CST, and SDC. Derive the
`create_clock` period from the actual oscillator or PLL source.

## 3. Read the generated reports

Do not treat a zero exit code alone as timing proof. Inspect the newest files
under `impl/pnr/`:

```bash
grep -nE 'Timing Constraints File|Global Clock|Clock|slack|Slack|setup|hold' \
  impl/pnr/*.rpt.txt impl/pnr/*.timing_paths
test -s impl/pnr/<output_base_name>.fs
```

Fail the verification if any build log contains an error or the TA1132 clock
warning:

```bash
! grep -RniE '(^|[^[:alnum:]])(ERROR|TA1132|determined to be a clock.*not created)' \
  impl/gwsynthesis impl/pnr
```

Record:

- the timing-constraints file used;
- the constrained clock and its period, where reported;
- worst setup and hold slack from the timing report;
- resource usage from the PNR report;
- the generated `.fs` bitstream path.

The resource check must include the PNR report's Logic, Register, CLS, and I/O
usage lines. The clock check must include the timing-constraints file, the
global-clock signal, and setup/hold timing paths. A bitstream without these
report checks is not a verified PNR result.

If `gw_sh` is unavailable, do not claim synthesis or timing success. If the
build completes but the timing report does not show the intended SDC, fix the
project file or constraint path and rebuild.

## 4. Sanity-check utilization against the intended design

Low utilization is not automatically a good result. Compare the resource
summary with the architecture that is meant to be implemented:

```bash
grep -nE 'MODULE NAME|REG NUMBER|LUT NUMBER|BSRAM NUMBER|DSP NUMBER' \
  impl/gwsynthesis/*_syn_resource.html
grep -nE 'Logic|Register|BSRAM|SSRAM|I/O Port' impl/pnr/*.rpt.txt
grep -RniE 'Current top module|optimized|removed|sweep|NL0002' \
  impl/gwsynthesis/*.log impl/gwsynthesis/*_syn*.html
```

For an accelerator expected to contain memories, neuron layers, schedulers, or
large counters, investigate immediately when the report shows zero BSRAM and
only a handful of LUTs/registers. Check that the selected top module
instantiates the datapath and that its outputs are observable. Unconnected
submodules and constant outputs are legally optimized away. A skeleton top
module with an FSM and a constant output can produce a valid bitstream while
using only a few resources; this is a build of the skeleton, not evidence that
the accelerator is implemented.

The synthesis hierarchy report and the PNR summary must agree closely enough
to explain small differences. For example, a synthesis LUT count of 4 and a
post-PNR logic count of 3 can be normal packing/optimization, but neither
number is meaningful if the intended datapath is absent from the hierarchy.

## 5. Estimate resources before trusting the report

Make a first-order estimate from the configured network dimensions before
accepting utilization results. The estimate is a sanity bound, not a
replacement for Gowin mapping:

```text
hidden weight bits = N_INPUT * N_HIDDEN * W_W
output weight bits = N_HIDDEN * N_OUTPUT * W_W
hidden membrane bits = N_HIDDEN * POT_W       # parallel hidden layer
output membrane bits = N_OUTPUT * POT_W
output counter bits = N_OUTPUT * COUNTER_W
```

As a worked calculation, with `N_INPUT = 784`, `N_HIDDEN = 128` and 4-bit weights (generic example values, not a project spec):

```text
784 * 128 * 4 = 401,408 bits
```

The output weights add `128 * 10 * 4 = 5,120 bits`. If stored in block RAM,
these need at least 22 and 1 nominal blocks respectively when using 18-Kbit blocks
(18,432 bits each; `401,408 / 18,432 = 21.8`, so 22 blocks minimum). This is
a capacity-only lower bound; actual width/depth modes and port requirements can
change the mapped count. Exact
packing depends on the device and inference mode. A parallel hidden
layer needs at least `128 * 16 = 2,048` membrane state bits before accounting
for spike flags, scheduler state, counters, and control logic. A
time-multiplexed implementation can reduce registers, but must then show
explicit neuron state memory and address/control logic instead.

Compare this estimate with both the synthesis hierarchy and PNR reports:

```bash
grep -nE 'MODULE NAME|REG NUMBER|LUT NUMBER|BSRAM NUMBER|DSP NUMBER' \
  impl/gwsynthesis/*_syn_resource.html
grep -nE 'Logic|Register|BSRAM|SSRAM|I/O Port' impl/pnr/*.rpt.txt
```

Required diagnosis rules:

1. If the estimate requires hundreds of thousands of weight bits but PNR
   reports `BSRAM 0`, inspect the top-level instantiation and `$readmemh`
   inference. A ROM module listed in `.gprj` but not instantiated consumes no
   memory.
2. If a parallel layer requires at least thousands of membrane bits but PNR
   reports only a few registers, inspect whether the layer is instantiated and
   whether its outputs feed observable logic.
3. If the synthesis hierarchy contains only the top module, while the project
   contains other modules that the design should use, the unused modules were
   never part of the elaborated design or were optimized away.
4. If `digit` or another top-level result is constant, downstream datapath
   logic can be removed even when source files are present.
5. Do not call a low-utilization result efficient until the estimate, hierarchy,
   and PNR totals are reconciled. Record the missing connection or optimization
   cause explicitly.


## 6. Keep generated output out of source control

Generated files under `impl/` are build artifacts. Preserve them only when the
repository explicitly tracks build results; otherwise add the generated
directories to the repository's existing ignore policy.
