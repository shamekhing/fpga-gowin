# Pipeline: add a module with a testbench

1. Plan the module: ports, widths, reset behavior, and what the testbench must check. Get approval.
2. Confirm the scope: list every file the change touches before editing.
3. Write the module and add it to the file list in the correct order (packages first).
4. Write a testbench that initializes every variable, checks reset, back-to-back operations and the first cycle after a stall.
5. Run the module test alone, then the full suite. Quote the counts.
6. Run Verilator lint on the full design.
7. Run synthesis and read the resource and timing reports. Record which build the numbers came from.
8. Review `git diff --check` and `git diff --stat`, then commit the explicit paths (git_workflow.md).
