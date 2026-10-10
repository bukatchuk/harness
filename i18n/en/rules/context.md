# Context and subagents

The context window is the main limited resource. Protect it.

## Saving context

- Read selectively: search first (`grep`, `git grep`, `rg`), then the needed fragment of a file, not the whole file.
- Limit command output: `| head`, `| tail`, `--quiet`, `--oneline`, `jq` selecting the needed fields. For build and test logs, only the tail and the errors.
- Do not preload what may not be needed: cheat sheets from `.claude/integrations/`, documentation, neighboring projects.
- Do not re-read what is already in the context.

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
