# RTL review checklist

- [ ] Module interface, parameter defaults and reset behavior are documented.
- [ ] Sequential and combinational processes use appropriate assignment styles.
- [ ] Every combinational output has a default assignment.
- [ ] Every register has one procedural driver.
- [ ] Widths, signedness and overflow behavior are explicit.
- [ ] FSM illegal-state behavior is considered.
- [ ] Handshake and pipeline latency are documented.
- [ ] CDC crossings use an explicit protocol.
- [ ] Memory/DSP inference is confirmed in synthesis reports.
- [ ] Unit tests include boundaries and backpressure.
- [ ] Lint warnings are resolved or justified.
