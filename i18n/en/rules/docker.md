# Docker

Local Docker is available for tests and experiments. The daemon may be stopped — then start it: `bin/harness docker-up`.

## Label everything you launch

Docker cleanup finds resources by label, so do not create anything without a label.

- Compose: a project name with the `harness-` prefix — `docker compose -p harness-<project> up -d`.
- Individual resources: `--label harness=1` for `docker run`, `docker network create`, `docker volume create`, `docker build`.

## Clean up after yourself

- Right after a test or experiment, without waiting for the end of the session: `docker compose -p harness-<project> down -v --remove-orphans`, then `bin/harness docker-clean`.
- The work is not finished until `bin/harness docker-check` shows zeros. Clean up even when the test failed.
- If you started the daemon and it is no longer needed, tell the owner — you do not need to stop the daemon yourself.

## Do not touch what is not yours

- Containers, networks, volumes and images without the harness label belong to the owner. No `docker system prune`, no `docker volume prune`, no removal of "everything stopped".
- Downloaded base images stay as a cache; only images built with the label `harness=1` are removed.
