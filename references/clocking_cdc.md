# Clocking and clock-domain crossing

## Clock architecture first

Draw a clock-domain diagram before RTL implementation. For each domain, record source, nominal frequency, tolerance, reset source, and the logic that crosses into or out of it. Use PLL-generated clocks only where required and use the vendor-supported clock network for clock distribution.

## Do not use ordinary logic as a clock

Prefer a clock enable for periodic work within one clock domain. A counter-generated pulse used as an enable is not a new clock. If a derived clock is genuinely required, declare it as a generated clock in timing constraints and use appropriate clock routing resources.

## Single-bit CDC

A two-or-more-stage synchronizer can reduce the probability that metastability propagates for a slowly changing single-bit level. It does not make an arbitrary pulse safe: a pulse shorter than the destination sampling interval can be missed. Use a toggle synchronizer, pulse-stretch/acknowledge protocol, or asynchronous FIFO according to event rate and loss requirements.

Synchronizer registers should be placed close together where supported, marked with the vendor-recognized attribute only after checking the tool documentation, and excluded from inappropriate functional retiming. Do not apply a false path broadly without preserving the intended synchronizer implementation and checking timing coverage.

## Multi-bit CDC

Do not synchronize each bit of a changing binary bus independently and assume the result is coherent. Use one of:

- request/acknowledge transfer while the source holds the bus stable;
- Gray-coded counters for suitable monotonic pointers;
- an asynchronous FIFO for streaming data.

An asynchronous FIFO needs correctly synchronized read/write pointers, full/empty logic, and reset behavior that is safe in both domains. Verify wraparound and near-full/near-empty conditions.

## Reset crossing

Asynchronous reset assertion may be useful for immediate reset, but deassertion should be synchronized independently in each clock domain. Ensure reset release cannot leave related state machines in inconsistent states. A reset synchronizer is not a substitute for a system-level reset sequence.

## Timing constraints

Constrain every primary clock from the board's actual oscillator specification. Add generated clocks for PLL outputs and derived clocks where required by the timing engine. Define asynchronous clock groups only when the domains are truly asynchronous and the crossing logic is designed accordingly. Review unconstrained-path and ignored-path reports after every constraint change.

## CDC verification checklist

- [ ] Clock-domain diagram exists and matches the RTL.
- [ ] Every crossing has an explicit protocol.
- [ ] Single-bit pulses cannot be lost, or loss is explicitly acceptable.
- [ ] Multi-bit data uses a coherent transfer mechanism.
- [ ] Reset deassertion is safe in every domain.
- [ ] Timing constraints cover all synchronous paths and correctly classify asynchronous crossings.
- [ ] CDC lint or structural review is performed; simulation alone cannot prove metastability safety.
