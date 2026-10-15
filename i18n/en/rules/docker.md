# Docker

Local Docker is available for tests and experiments. The daemon may be stopped — then start it: `bin/harness docker-up`.

## Label everything you launch

Docker cleanup finds resources by label and tells your own from the neighbour sessions' by the session label. Do not create anything without the labels. The session start hook sets `HARNESS_SESSION`.

- Compose: the project name `harness-<project>-$HARNESS_SESSION` — `docker compose -p "harness-<project>-$HARNESS_SESSION" up -d`.
- Individual resources: `--label harness=1 --label harness.session="$HARNESS_SESSION"` for `docker run`, `docker network create`, `docker volume create`, `docker build`.

## Clean up after yourself

- Right after a test or experiment, without waiting for the end of the session: `docker compose -p "harness-<project>-$HARNESS_SESSION" down -v --remove-orphans`, then `bin/harness docker-clean`. It removes this session's resources and stopped resources without a session label; neighbour sessions' resources and running containers without a label stay.
- The work is not finished until `bin/harness docker-check` shows zeros for this session. Clean up even when the test failed.
- `bin/harness docker-clean --all` removes every harness resource, including running ones of neighbour sessions — only on the owner's word.
- If you started the daemon and it is no longer needed, tell the owner — you do not need to stop the daemon yourself.

## Do not touch what is not yours

- Containers, networks, volumes and images without the harness label belong to the owner. No `docker system prune`, no `docker volume prune`, no removal of "everything stopped".
- Downloaded base images stay as a cache; only images built with the label `harness=1` are removed.
