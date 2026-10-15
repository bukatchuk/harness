# Plane

Task tracker. The integration is enabled if `harness.json` has the key `integrations.plane`.

- The address, the workspace and the default project are in `harness.json`: `integrations.plane.url`, `workspace`, `default_project_id`.
- Authorization: `PLANE_TOKEN` in the environment. The token is issued in Plane: Profile Settings → Personal Access Tokens.
- API documentation: https://developers.plane.so/api-reference/introduction

## Harness commands

Handle tasks with `bin/harness` commands, not with direct API requests: they pick the project from the registry, find the state by its group, turn the text into HTML, walk through pages and wait at the request limit.

```bash
bin/harness task create --title "<title>" --body-file /absolute/path.md [--repo <name> | --project <PROJECT>] [--parent <PROJECT-N>] [--state todo] [--priority medium]
bin/harness task state <PROJECT-N> started            # backlog, todo, started, done, cancelled
bin/harness task comment <PROJECT-N> --body-file /absolute/path.md
bin/harness task link <PROJECT-N> <url> [--title "<title>"]   # MR, release, pipeline
bin/harness task show <PROJECT-N>
bin/harness task list [--repo <name> | --project <PROJECT>] [--state open|all|started|…] [--limit N]
bin/harness tasks [--stale 7]                         # tasks in progress across all projects and days without movement
```

- `--repo` picks the repository's project from the registry, and the task gets the label `repo:<name>` in any project; the label is created when missing. `task list --repo <name>` shows the tasks with that label.
- The text is a Markdown file (paragraphs, `#` headings, `-` and `1.` lists, `` `code` ``, `**bold**`) or ready HTML. The hook and the command itself check it for AI attribution.
- A task is given as `PROJECT-number`, for example `SHOP-12`; `create` and `show` print the link.
- The session start hook names tasks in progress that have not moved for more than 7 days; the list is `bin/harness tasks --stale 7`.

## Direct API requests

Needed for what the commands cannot do. The base is `<url>/api/v1/workspaces/<workspace>`, the header `X-API-Key: $PLANE_TOKEN`.

- `GET /work-items/<PROJECT-N>/` — a task by its number.
- `fields=id,name,state,updated_at` — only the needed fields: the response is lighter and faster; `expand=state` — the state as an object with the `group` field.
- Lists have no state filter: filter with `jq`.
- When a task is created, Plane ignores the state and puts it in Backlog — the state is changed by a separate `PATCH` with the field `state`.
- The HTML must have no spaces or line breaks between tags: Plane turns them into empty list items.

## Rules

- Select fields with `jq` or `fields`: Plane responses are large, do not print them whole into the context.
- Reading is free. Create and change tasks when the owner asks and per `.claude/rules/tasks.md`; bulk changes only after confirmation.
- The limit is 60 requests per minute per token.
