# Ready/valid streaming interface

A transfer occurs on a rising clock edge when both `valid` and `ready` are high. The producer must keep `valid` asserted and payload stable until a transfer occurs. The consumer may deassert `ready` to apply backpressure.

Specify reset values, payload width, whether combinational ready/valid paths are allowed, and whether a transfer can occur in the same cycle as reset release. Test random backpressure, consecutive transfers, long stalls and reset while stalled.
