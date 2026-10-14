# GitLab

The owner's own GitLab: repositories, CI, registry. The integration is enabled if `harness.json` has `integrations.gitlab.url`; a repository lives in GitLab if `bin/harness forge <path>` prints `gitlab`.

- API: `<url>/api/v4`, the address is `integrations.gitlab.url`.
- Authorization: the `PRIVATE-TOKEN: $GITLAB_TOKEN` header. The owner issues the token (a personal token with the `api` scope).
- `gh` does not work with GitLab. Merge requests and releases go through `bin/harness` commands, everything else through the API.

## Harness commands

```bash
bin/harness forge repos/<name>                      # gitlab, github or other
bin/harness mr repos/<name> --title "<title>" --body-file /absolute/path.md [--base main]
bin/harness mr-status repos/<name> <number>         # the pipeline and whether it can be merged
bin/harness release-create <path> v<version> --title "v<version> — <summary>" --notes-file /absolute/path.md
```

Texts are passed as a file with an absolute path: the hook checks them for AI attribution, the same as `gh` texts.

## Calling the API

```bash
gl() { curl -sS --max-time 60 -H @<(printf 'PRIVATE-TOKEN: %s' "$GITLAB_TOKEN") -H 'Content-Type: application/json' "$(jq -r .integrations.gitlab.url harness.json)/api/v4$1" "${@:2}"; }
p=$(printf '%s' '<group>/<project>' | jq -sRr @uri)

gl "/projects/$p" | jq '{id, path_with_namespace, default_branch, merge_method, only_allow_merge_if_pipeline_succeeds}'
gl "/projects/$p/merge_requests?state=opened" | jq '.[] | {iid, title, source_branch, detailed_merge_status}'
gl "/projects/$p/pipelines?per_page=5" | jq '.[] | {id, ref, status}'
gl "/projects/$p/pipelines/<id>/jobs" | jq '.[] | {id, name, status, duration}'
gl "/projects/$p/jobs/<id>/trace" | tail -40                 # job log
gl "/projects/$p/merge_requests/<number>/merge" -X PUT -d '{"squash": true}'   # merge
gl "/projects/$p/ci/lint" -X POST -d "$(jq -n --rawfile c .gitlab-ci.yml '{content: $c}')"   # check .gitlab-ci.yml
```

## Rules

- Reading is free. Creating and deleting projects, groups, branches, tags, CI variables and deploy keys, and merging requests follow the project's rules and need the owner's confirmation.
- Do not print the values of CI variables. A secret goes into a variable by a command that reads it from its source and passes it straight to the API; the variable is masked and, if only tags need it, protected.
- Before pushing a new `.gitlab-ci.yml`, check it through `ci/lint`: an error in the file gives a pipeline without a single job.
- Merge only on a green pipeline when the project requires it (`only_allow_merge_if_pipeline_succeeds`).
