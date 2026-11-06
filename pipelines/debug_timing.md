# Pipeline: timing or synthesis fails

1. Read the full error or warning text from the log, not a summary.
2. Classify it: language mode, top module, missing file, constraint, primitive parameter, or timing.
3. For timing, open the timing report and read the worst setup path: the start point, the end point, the clock and the slack.
4. Check the clock constraints against the real source before changing the logic.
5. Fix one thing, re-run the build, and compare the report with the previous one.
6. Record the before and after numbers, and the report file each came from.
