# Spiking neural-network accelerator architecture

## State and event representation

An SNN implementation must define neuron state, synaptic weights, spike representation, time-step semantics and layer scheduling. A spike may be represented as a one-bit event, a count, or a timestamped event; each choice changes routing and buffering requirements.

## Time-stepped versus event-driven

A time-stepped design evaluates state updates at fixed intervals and can use regular memory access. An event-driven design processes only emitted spikes but needs event queues, routing and arbitration. Hybrid approaches are possible. Compare total activity, control overhead and memory traffic rather than assuming event-driven is always cheaper.

## Scheduling

Specify whether all neurons update in parallel, in tiles, or through shared compute units. Define when incoming spikes are accumulated, when membrane state updates, and whether spikes generated at time t are consumed at t or t+1.

## Verification

Use a software model with exactly matching update order, threshold comparison, reset timing, quantization and time-step convention. Compare membrane state and spike events per neuron per time step.
