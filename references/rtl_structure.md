# RTL structure: packages, bundles, and module boundaries

This reference covers how a design is organized, not how individual lines are
written. For signal and file names see `naming_conventions.md`. For coding
patterns see `rtl_design_patterns.md`.

The goal is that a reader can find where any signal is owned, what it means,
and which module changes it, without tracing the whole design. A design that
needs a long hunt to answer those questions has a structure problem even when
it simulates correctly.

Evidence level for every rule below: **Standard practice.** Tool support for
specific constructs is marked separately in the last section and must be
confirmed on the installed Icarus and Gowin versions.

## 1. Write the interface contract before the body

Before writing a module, write its header contract:

- purpose in one sentence;
- clock domain(s) and reset polarity and style;
- ports grouped by role (see rule 4), with each handshake's protocol;
- latency and initiation interval, if data flows through it;
- what the module does not do (its non-responsibilities).

If the contract cannot be written in about ten lines, the module has more than
one responsibility. Split it before writing the body.

Comments in the header describe the contract and must match the code. A header
that says "parallel" for a module that uses one shared datapath is a defect,
the same as a wrong port width. Check header claims against the code during
review, and check them against the architecture document.

## 2. One module, one responsibility, one clock domain

- A module owns one datapath or one control FSM, not both unless the control is
  trivial and local.
- Do not mix clock domains inside a module. Put each domain's logic in its own
  module, and put crossings in a dedicated synchronizer or FIFO module.
- A module that instantiates many other modules and computes nothing itself is
  a top or wrapper. Keep those free of datapath logic.

## 3. Packages: put only shared things in them

A package is for declarations that two or more files need: shared types,
protocol field definitions, and widths or counts that must agree across files.

- Put a shared type in a package once. Do not repeat its field layout in two
  modules.
- Keep a module's private parameters and internal types in the module.
- Use one package per domain (for example `bus_pkg`, `datapath_pkg`), not one
  package that holds everything. A package that is imported by every file is a
  sign that unrelated things have been collected in it.
- Each package starts with a comment listing what it owns and which files use
  it.
- Derive dependent widths from one source. If `N_HIDDEN` drives three arrays,
  define it once and derive the others, rather than repeating the number.
- Compile packages first in the file list. Gowin project files and Icarus
  command lines must reflect that order.

Do not create a package for a single signal, a single constant used in one
file, or a convenience alias. Those add a file to read without removing any
complexity.

## 4. Bundle only what travels together

A struct or bus type groups signals that share all of the following:

- the same clock domain;
- the same handshake or valid/ready pair;
- the same lifetime (they are produced and consumed together);
- the same owner (one module drives all of them).

Test before bundling: if a consumer ever reads one field without the others,
or two fields have different valid timing, do not put them in one struct. Put
each handshake group in its own bundle.

Do not bundle "everything that is an output". A bundle named for a concept
(`spike_event_t`, `bus_req_s`) is correct. A bundle named `outputs_t` or
`top_bus_t` is a dumping ground and makes the next change harder.

Bundle a port group only when it has more than about four scalars that form
one concept. Keep ports that have a single clear meaning as scalars.

## 5. Port lists: order and grouping

- Declare ports in this order: clock and reset, configuration, input requests
  or data, output responses or data, status. Keep the same order in every
  module of the project.
- Group related ports with a comment line per group.
- A module with more than about ten scalar ports is a candidate for bundling,
  or for splitting.
- Use the same name for the same signal across a boundary. Map to a different
  name only when the parent has a distinct local meaning, and say so in a
  comment.

## 6. Top levels wire, they do not compute

The top module should:

- instantiate blocks and connect them;
- contain at most small glue logic (inversions, resets, status OR-reduction);
- declare only the nets needed to connect instances.

If the top module declares many internal signals that are then computed or
transformed, move that logic into a submodule. Count the top module's local
declarations during review; a long list is a sign that a datapath has leaked
upward.

Do not write a top-level `generate` that builds a bus from scattered signals
when a submodule can produce the bus directly.

## 7. Eliminate dead and inert intermediates

- Every intermediate signal must have a reader that affects an output or state.
- Remove signals that exist only to feed another signal that is itself unused.
- Remove ports that are never driven from outside or never read inside.
- Compile with unused-signal warnings enabled and resolve each one.

## 8. Keep sequential and combinational logic visibly separate

- `always_ff` for registers, `always_comb` for combinational logic. Avoid
  `assign` chains that read registers written in another process, because
  they hide the register boundary.
- Name the registered and next-state values with the `_q` / `_d` pattern from
  `naming_conventions.md`.
- Make a module's outputs either all registered or all combinational, and
  state which in the header.

## 9. One name per concept across the whole project

Two names for one concept in adjacent modules is a defect, not a style choice.
Example: `spike_valid` in one module and `spk_valid` in its parent for the same
signal. Keep a short glossary (concept to name) in the project documentation
and rename everywhere in one change.

Renaming a public interface, a file-format field, or a vendor name is a
separate, deliberate change. Do not mix it with behavior changes.

## 10. Refactor in steps that keep the baseline green

- Run the existing tests before changing anything, and record the result.
- Make one structural change per step: a new package, one bundle, one module
  split, or one rename. Run the tests after each step.
- Do not change interfaces and behavior in the same step. If a bundle change
  alters what a module computes, the two effects cannot be separated during
  debugging.
- Keep the old and new forms visible in the diff so a reviewer can compare.

## 11. Files and directories

- One module or package per file, named after it (`naming_conventions.md`).
- Directories mirror the hierarchy: for example `rtl/pkg/`, `rtl/core/`,
  `rtl/mem/`, `rtl/top/`. A reader should know where a module lives from its
  role.
- Testbenches sit beside or in a parallel `tb/` tree. Each testbench names the
  module it covers.

## 12. Review question

For each module, a reviewer should be able to answer these in under a minute:

1. What does it own?
2. Which clock drives it?
3. What does each port group mean, and what is its protocol?
4. Where is each of its internal signals used?

If any answer needs a search across several files, the structure needs work.

## Tool support to confirm before relying on these rules

These constructs are standard SystemVerilog, but simulator and synthesis
support varies. Confirm each one on the installed tool before using it in a
shared design:

- packed `struct` types as module ports (Icarus and Gowin SystemVerilog mode);
- `typedef enum` shared through a package and imported in ports;
- `always_comb` with struct-typed signals;
- unpacked arrays of structs as ports (often unsupported or fragile; prefer
  packed structs or a flat array);
- SystemVerilog `interface` and `modport` (check Icarus support first; avoid
  unless the simulator and the synthesizer both handle them).

Record the outcome in the project notes: the tool version, the construct, and
whether it simulated and synthesized.
