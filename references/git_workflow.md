# Git workflow for FPGA repos

## Before a commit
    git status --short
    git diff --check
    git diff --stat

## Stage explicit paths
Avoid `git add -A` when the tree has unrelated or generated changes. Add the source and documentation paths you intend to commit.

Keep local and generated files out:
    git restore --staged <project>.gprj.user
Also ignore the build output and IDE-regenerated files (device.cfg, cmd.do, impl/temp/).

## Verify the staged set
    git diff --cached --check && git diff --cached --stat

## Commit messages
Describe the change in one line, in the present tense: "Fix carry chaining", "Pipeline fetch for timing". Include the test result in the body when a regression was run.

## Read-only checkouts
If `.git` is mounted read-only, commits and branches fail. Check the mount and permissions first. Do not work around it by copying metadata.
