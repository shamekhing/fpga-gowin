# Using IP cores: obtain, use, configure

This reference is device-independent. It covers any intellectual-property
block a project pulls in rather than writes: a vendor-generated block, a
third-party or open-source core, or a block the project itself generates.
For a specific memory or peripheral, read its own document and this file
together.

Evidence label for all rules here: **Standard practice**, unless a rule says
otherwise.

## 1. Obtain the IP

Record where every IP came from before using it:

- **Source:** the vendor IDE catalog, a vendor download, an open-source
  repository, or the project itself.
- **Version:** exact version or commit hash. "Latest" is not a version.
- **License:** the terms that govern use and redistribution. Check before a
  design ships.
- **Integrity:** a checksum or a commit hash for files brought in from outside.

Keep this in the project notes or a manifest file under version control, so
a future change can be traced to a source.

Do not copy an IP's source files into the project tree by hand unless the
license and the vendor's workflow allow it. Prefer generating or fetching
the IP through the tool's own mechanism so the configuration and the output
stay linked.

## 2. Understand what the IP requires before using it

Read the IP's own documentation for:

- its ports and what each one means, including active-low and reset-polarity
  conventions;
- its clock and reset requirements: which clocks, which frequencies, which
  reset sequence, and whether it needs a clock that is stable before reset is
  released;
- its initialization or calibration behavior, and the status signal that
  reports completion or failure;
- its latency, its handshake protocol, and any user-side timing rules;
- any constraints it needs (clock definitions, pin assignments, I/O standard)
  and whether the tool generates them or the project must add them.

Do not start integration from the port list alone. Ports without the protocol
and the sequence are not enough to use an IP correctly.

## 3. Use the IP through a thin wrapper

**Standard practice:**

- Instantiate each IP inside one project module of your own, a wrapper that
  maps the IP's ports to the project's naming and bundle conventions (see
  `rtl_structure.md`). Other project modules then talk to the wrapper, not to
  the raw IP.
- Keep the wrapper small: connections, renaming and status gating only. No
  datapath logic.
- Gate user requests on the IP's ready or done status. Do not issue requests
  during initialization or calibration.
- Keep the IP's clock and reset distribution in one place, so a reset sequence
  can be read from one file.
- Never edit the generated output of an IP. If it needs a change, change the
  configuration and regenerate.

## 4. Configure the IP reproducibly

- **Keep the configuration in version control.** The generator's configuration
  file is the source of truth. Commit it. Commit the wrapper that uses it.
- **Regenerate, do not hand-edit.** Regenerate the output from the
  configuration whenever a parameter changes, and review the diff.
- **Keep generated outputs out of git** when the tool regenerates them on each
  run (see `git_workflow.md`), unless the project's policy requires them.
- **Record every non-default parameter** and the reason for it, in the wrapper
  or the project notes. A default that changes in a later tool version is
  otherwise invisible.
- **Test the chosen configuration**, not only the default. A configuration
  that differs from the one tested is untested.

## 5. Verify the IP in simulation before hardware

- Simulate with the IP's provided simulation model, or a model for the exact
  external part if the IP talks to one. A generic stand-in does not check the
  real timing or initialization.
- Test reset, initialization, the status signal, and at least one full
  transaction through the wrapper.
- Test error and timeout behavior: what the wrapper does if the IP never
  reports done, or reports failure.
- Record the simulator version, the IP version and the configuration used with
  each result.

## 6. Compare configurations and versions

When an IP's behavior changes between two runs, check these first, in order:

1. The IP version and tool version used to generate it.
2. The configuration file diff.
3. The generated output diff, if the configuration did not change.
4. The wrapper diff.

A failure after an IP upgrade is usually a configuration or default change, not
a logic bug in the project.

## 7. Evidence levels for IP results

Report IP results with the same labels as the rest of the skill:
- **Estimated:** resource or timing figures from the IP's documentation.
- **Simulated:** a named simulator, the IP version and the test count.
- **Synthesized:** the tool version, with the synthesis report cited.
- **Hardware-validated:** the board, the bitstream, and the observed result.

Do not report a generated IP's resource use as a project's own resource use
without saying so.

## 8. Checklist

- [ ] Source, exact version, license and integrity recorded for each IP.
- [ ] IP documentation read for ports, clock/reset sequence, status and protocol.
- [ ] Constraints the IP needs are present in the project, not assumed.
- [ ] Each IP is used through one project wrapper; no raw IP ports in top levels.
- [ ] Requests are gated on the IP's ready or done status.
- [ ] Configuration file is under version control; output is regenerated, not edited.
- [ ] Every non-default parameter has a recorded reason.
- [ ] Simulation uses the IP's model, covers reset, init, a full transaction and timeout.
- [ ] Hardware results record the IP version and configuration used.
