# Tasks in Plane

This rule applies if `harness.json` has the key `integrations.plane`. If it is absent, no task tracker is connected: do not create tasks, and tell the owner so when they ask.

The Plane address, workspace and default project are recorded in `harness.json` (`integrations.plane`: `url`, `workspace`, `default_project`, `default_project_id`). How to call the API is in `.claude/integrations/plane.md`.

## Which project to create in

1. A task about a project from the registry — in its Plane project: the fields `plane_project` and `plane_project_id` in `registry/repos.json`.
2. A task about a server or service — in the project of the repository responsible for it: `bin/harness map <server>`.
3. In all other cases, and also if the repository has no project specified — in the default project from `harness.json`.

## The task status is always current

Change the task state in Plane yourself at every stage, without waiting for a reminder:

- **Started work** — move it to `In Progress` immediately, before the first command on the task. This applies to tasks you created yourself too.
- **Did part** — leave `In Progress` and write a comment: what is done, what remains.
- **Did everything described in the task and verified the result** — move it to `Done` and write a final comment with numbers "before → after".
- **Work stopped** (waiting for the owner's decision, access, an external event) — leave `In Progress` and write in a comment what exactly you are waiting for.
- **The task is not needed** — `Cancelled` with a reason, only by the owner's decision.

If only part of a task is done and the owner did not ask to do the rest now, do not leave the task open silently: ask whether to close it, and move the remainder into a separate task.

In the final message to the owner, state the current status of every affected task.

State identifiers are specific to each project: take them from the `/states/` of that project by the `group` field (`started` — In Progress, `completed` — Done).

## How to create

- Create a task when the owner asks for it or when the work has revealed a problem that must be solved separately. Before creating, check that there is no such task already.
- In the task: what was found (with numbers), the cause, the proposed solution in steps, risks. Do not write secrets or the contents of `.env` into tasks.
- After creating, return the identifier and the link to the owner.
- You maintain the state of the tasks you work on (see above). Do not touch tasks you are not working on; delete tasks only at the owner's request.
- If a project has its own task-handling rules (branches by task number, synchronization with a plan file), follow them.
