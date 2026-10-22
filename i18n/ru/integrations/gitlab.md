# GitLab

Собственный GitLab владельца: репозитории, CI, registry. Интеграция включена, если в `harness.json` есть `integrations.gitlab.url`; репозиторий живёт в GitLab, если `bin/harness forge <путь>` печатает `gitlab`.

- API: `<url>/api/v4`, адрес — `integrations.gitlab.url`.
- Авторизация: заголовок `PRIVATE-TOKEN: $GITLAB_TOKEN`. Токен выпускает владелец (личный токен с правом `api`).
- `gh` с GitLab не работает. Запросы на слияние и релизы — командами `bin/harness`, остальное — через API.

## Команды harness

```bash
bin/harness forge repos/<имя>                       # gitlab, github или other
bin/harness mr repos/<имя> --title "<заголовок>" --body-file /абсолютный/путь.md [--base main]
bin/harness mr-status repos/<имя> <номер>           # конвейер и готовность к слиянию
bin/harness release-create <путь> v<версия> --title "v<версия> — <суть>" --notes-file /абсолютный/путь.md
```

Тексты передаются файлом с абсолютным путём: хук проверяет их на AI-атрибуцию, как и тексты `gh`.

## Вызов API

```bash
gl() { curl -sS --max-time 60 -H @<(printf 'PRIVATE-TOKEN: %s' "$GITLAB_TOKEN") -H 'Content-Type: application/json' "$(jq -r .integrations.gitlab.url harness.json)/api/v4$1" "${@:2}"; }
p=$(printf '%s' '<группа>/<проект>' | jq -sRr @uri)

gl "/projects/$p" | jq '{id, path_with_namespace, default_branch, merge_method, only_allow_merge_if_pipeline_succeeds}'
gl "/projects/$p/merge_requests?state=opened" | jq '.[] | {iid, title, source_branch, detailed_merge_status}'
gl "/projects/$p/pipelines?per_page=5" | jq '.[] | {id, ref, status}'
gl "/projects/$p/pipelines/<id>/jobs" | jq '.[] | {id, name, status, duration}'
gl "/projects/$p/jobs/<id>/trace" | tail -40                 # журнал задания
gl "/projects/$p/merge_requests/<номер>/merge" -X PUT -d '{"squash": true}'   # слить
gl "/projects/$p/ci/lint" -X POST -d "$(jq -n --rawfile c .gitlab-ci.yml '{content: $c}')"   # проверить .gitlab-ci.yml
```

## Правила

- Чтение — свободно. Создание и удаление проектов, групп, веток, тегов, переменных CI и ключей развёртывания, слияние запросов — по правилам проекта и после подтверждения владельца.
- Значения переменных CI не выводи. Секрет в переменную кладёт команда, которая читает его из источника и передаёт прямо в API; переменная — маскированная и, если нужна только тегам, защищённая.
- Composer в CI ходит на GitHub с токеном: переменная `COMPOSER_AUTH` уровня GitLab (маскированная, не защищённая — она нужна и конвейерам запросов на слияние), значение — в хранилище владельца. Анонимно у раннера 60 запросов в час, и `composer install` получает HTTP 429. В переменной лежит голый токен, а composer читает её сам и ждёт JSON: проект, где CI запускает composer, оборачивает её в `default.before_script` — `case "$COMPOSER_AUTH" in ""|"{"*) ;; *) export COMPOSER_AUTH="{\"github-oauth\":{\"github.com\":\"$COMPOSER_AUTH\"}}" ;; esac`. Без обёртки composer падает с `COMPOSER_AUTH environment variable is malformed`. В `docker build` она передаётся только как BuildKit secret (`--secret id=composer_auth,env=COMPOSER_AUTH`, в Dockerfile `RUN --mount=type=secret,id=composer_auth`), не build arg — тот остаётся в истории образа.
- Перед отправкой новой `.gitlab-ci.yml` проверь её через `ci/lint`: ошибка в файле даёт конвейер без единого задания.
- Слияние — только при зелёном конвейере, если проект этого требует (`only_allow_merge_if_pipeline_succeeds`).
