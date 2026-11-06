# Randomized testing

Randomized tests explore combinations that directed tests may miss. Always record the random seed, tool version, configuration parameters and failing transaction trace. A failure must be reproducible.

Constrain random stimulus to legal protocol behavior unless deliberately testing illegal inputs. Bias distributions toward boundaries: zero, maximum, minimum signed value, alignment edges, full/empty transitions and threshold equality.

Use a bounded test duration and report how many transactions and checks actually completed. Random testing without coverage goals or a reproducible seed is difficult to interpret.
