# Context and subagents

The context window is the main limited resource. Protect it.

## Saving context

- Read selectively: search first (`grep`, `git grep`, `rg`), then the needed fragment of a file, not the whole file.
- Limit command output: `| head`, `| tail`, `--quiet`, `--oneline`, `jq` selecting the needed fields. For build and test logs, only the tail and the errors.
- Do not preload what may not be needed: cheat sheets from `.claude/integrations/`, documentation, neighboring projects.
- Do not re-read what is already in the context.

## Project context

A new session must carry on without the owner explaining things again. So a project's context lives in the repository itself — in `CLAUDE.md` and `.claude/`: decisions, current state, constraints and a warm-up prompt for starting a session (for example, `.claude/warmup.md`).

- When closing each task (and when finishing a stage that has no task), check that the context and the warm-up prompt are current: the current version, what is done, what is in progress, the next step, the owner's open decisions. Rewrite what is outdated instead of appending: the warm-up prompt is a short snapshot of "where we are and what is next", not a log.
- No warm-up prompt yet — create one. Context edits follow the same process as the project's code (branch, MR, deploy).
- In the final comment of the task, note that the context was checked or updated.

## Subagents

- By default a single agent works. A subagent is needed when the task is independent and read-heavy (code review, search across several repositories, log analysis) and only the output should return to the main context.
- Do small tasks of a few calls yourself: launching a subagent costs more.
- Launch independent tasks in parallel, in one message.
- A subagent returns a compressed result: conclusions, `file:line` paths, what could not be verified. No retelling of what was read.

## Model for a subagent

Choose the cheapest model on which quality does not suffer, and specify it explicitly at launch.

| Task | Model |
| --- | --- |
| Search, inventory, fact gathering, log analysis, mechanical edits following a pattern | `haiku` |
| Implementation from a clear specification, tests, review of ordinary code, documentation | `sonnet` |
| Architecture, tangled debugging, decisions with a high cost of error, security | the main session's model |

If you doubt between two, take the cheaper one and check the result yourself; if it is weak, relaunch on the higher model rather than finishing the subagent's work by hand.
