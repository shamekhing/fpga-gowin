# Minimal-resource design

Use this file when the goal is to fit a design into a small FPGA, or to cut LUT, register and block RAM use. Each rule says where it came from. Rules marked MEASURE must be confirmed with the synthesis and place-and-route reports before you rely on them.

## 1. Decide the architecture before the RTL

- Time-multiplex identical units instead of instantiating them all. Wang et al. (2014, FPGA design framework for large-scale SNNs) use one physical neuron that serves many virtual neurons, with state kept in memory. Source: https://researchers.westernsydney.edu.au/en/publications/an-fpga-design-framework-for-large-scale-spiking-neural-networks/
- Cost of parallel units: the Spiker accelerator paper (Carpegna et al., ISVLSI 2022) describes an FPGA-optimized SNN design that scales its resource use with the number of neurons. Source: https://iris.polito.it/retrieve/handle/11583/2971596/603697
- A time-multiplexed design needs explicit state memory and address/control logic. Count those as cost. Source: general practice; confirm with your reports.
- Event-driven updates touch only active units. Gupta et al. (IIT Guwahati) update a neuron only when it receives spikes, and report lower energy and fewer updates than a clock-driven design. Source: https://ar5iv.labs.arxiv.org/html/2010.01200
- Compare the options on paper first: cycles per image x units x registers x memory bits. Pick the cheapest option that meets your throughput.

## 2. Put state in block RAM, not in registers

- Block RAM is dedicated memory and does not use LUTs or flip-flops. The Tang-class GW2A-18 has 828 Kbit of block RAM. Source: a community tutorial (hdl-00-noob-to-brain, chapter 5), so check the device datasheet.
- Large arrays in registers cost one flip-flop per bit. Use block RAM for arrays, and keep only the working values in registers.
- MEASURE: check the BSRAM count in the PnR report after each change.

## 3. Infer block RAM with synchronous reads

- Vendor guidance (Intel Quartus design recommendations) says a RAM read with an address that is not registered can add bypass logic and slow the path. Use a registered address and a registered output, so the tool can map the array to block RAM. Source: https://intel.com/content/www/us/en/docs/programmable/683323/18-1/single-clock-synchronous-ram-with-new.html
- Synplify's RAM-inference note says tools infer RAM from an array with a clocked write and a registered read address and output. Source: https://www.ece.ucdavis.edu/%7Esoheil/teaching/EEC180B-S06/inferring_blockRAMs.pdf
- Avoid a read-during-write case that the RTL leaves undefined. Write the behavior explicitly, as the Intel examples do.
- MEASURE: confirm the array is in BSRAM, not distributed RAM or registers, in the PnR report.

## 4. Size every width from measured ranges

- Find the largest and smallest value each signal reaches on real input data, using the reference model. Size the register to that range plus a margin you choose.
- Widths drive the cost: a 16-bit register and its adder cost about twice an 8-bit one. This is a general rule of arithmetic logic, not from one source.
- Use fixed-point integers. The Carpegna and Gupta designs use integer weights and fixed-point potentials, and the paper behind this project uses shifts for decay. Keep the decay a shift when the decay factor is a power of two.
- MEASURE: compare the register count before and after each width change.

## 5. Replace arithmetic with cheaper operations

- Multiplying by a power of two is a shift; use it.
- A multiply by a binary spike (0 or 1) is an AND or a conditional add.
- Share one adder across units when the units run at different times (see section 1).
- A threshold compare against a power of two is a bit test.
- Avoid wide parallel muxes that select one of many words. Each mux level costs LUTs. Read a row from a block RAM instead when the access pattern allows it.

## 6. Pipelining and timing

- A pipeline adds registers, so it costs area. Add it only where the critical path needs it, and check the timing report first.
- A slower clock with fewer units can use fewer resources than a fast clock with many units. Choose the operating point with the reports.

## 7. Check the design is what you think it is

- An unused module, or an output that is constant, is removed by synthesis. A very small resource count can mean the datapath was never connected. Check the synthesis hierarchy report against the design. See pipelines/synthesize_route.md, section 4.
- Keep the golden test passing after each change. A smaller design that computes the wrong answer is not smaller in any useful sense.

## 8. Loop to follow

1. Write the resource estimate for the architecture (registers, LUTs, block RAM bits).
2. Change one thing.
3. Run the golden test and the regression.
4. Build with `scripts/gowin_batch.sh`, then `scripts/verify_build.sh`.
5. Compare the PnR summary with the estimate. Record both.
6. Keep the change only if the golden test passes and the resource number moved in the right direction.

## Sources
- Wang, Hamilton, Tapson, van Schaik (2014). FPGA design framework for large-scale spiking neural networks.
- Carpegna, Savino, Di Carlo (2022). Spiker: an FPGA-optimized hardware accelerator for SNNs. ISVLSI.
- Gupta, Vyas, Trivedi (2020). FPGA implementation of a simplified spiking neural network. arXiv 2010.01200.
- Intel Quartus Prime design recommendations, RAM coding style.
- Synplify application note, RAM inference.
- Community Gowin tutorial, chapter 5 (block RAM). Check against the Gowin datasheet.

## Not verified
- The exact block RAM coding style Gowin's tools need. The rules above come from Intel and Synplify documentation. Confirm the Gowin rules against the Gowin synthesis guide for your version.
- The savings percentages. None of the sources gives a figure for this design. Measure each change.
