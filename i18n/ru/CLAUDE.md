# Harness

Ты работаешь в harness — едином хабе для всех проектов владельца. Кто владелец, сообщает хук на старте сессии; его имя и почта записаны в `harness.json`. С владельцем общайся по-русски и на «ты».

## Что где лежит

- `VERSION`, `CHANGELOG.md` — версия конфигурации harness. Узнать текущую: `bin/harness version`.
- `harness.json` — настройки этой установки: владелец (`owner`), язык (`lang`), подключённые интеграции (`integrations`). Создаётся и меняется командой `bin/harness init`.
- `registry/repos.json` — реестр проектов. Клоны лежат в `repos/<имя>`; это отдельные git-репозитории, в harness они не коммитятся.
- `worktrees/<имя>/<ветка>` — отдельные рабочие копии клонов для параллельных сессий; создаёт `bin/harness worktree`, в git harness не попадают.
- `registry/servers.json` — реестр серверов: адрес, пользователь, окружение, локация, назначение.
- `registry/services.json` — связи: какой репозиторий отвечает за конфигурацию какого сервера и какого сервиса на нём. Смотреть: `bin/harness map <имя>`.
- `.claude/rules/` — универсальные правила, действуют во всех проектах.
- `.claude/skills/` — процедуры: `commit`, `push`, `pr-create`, `repo-add`, `repo-remove`, `repo-sync`, `server-add`, `server-remove`, `service-add`, `service-remove`, `harness-reset`, `harness-update`, `harness-doctor`, `release-public`.
- `.claude/integrations/` — шпаргалки по внешним сервисам (хранилище секретов Bitwarden, Plane, n8n, GitGuardian, GitLab, Yandex Cloud, mailcow, Timeweb Cloud). Прочитай нужную перед первым обращением к сервису, заранее не загружай. Интеграция включена, если её ключ есть в `harness.json`.
- `i18n/` — исходники правил, skills и шпаргалок на русском и английском. Файлы в `.claude/` — их копия на выбранном языке; её создаёт `bin/harness lang`.
- `bin/harness` — CLI: `init`, `lang`, `doctor`, `sync`, `status`, `servers`, `server-check`, `map`, `repo-remove`, `server-remove`, `service-remove`, `reset`, `check-commits`, `docker-up`, `docker-check`, `docker-clean`, `locks`, `unlock`, `worktree`, `forge`, `mr`, `mr-status`, `release-create`, `task`, `tasks`, `secrets`, `selfcheck`, `release-build`, `release-publish`.

## Работа с проектами

- Перед задачей в проекте найди его в реестре: там описание, стек и связанный проект в трекере задач.
- Если проекта нет в `repos/`, склонируй его через `bin/harness sync <имя>`.
- У проекта могут быть свои `CLAUDE.md` и правила. Они уточняют правила harness; при противоречии в вопросах git-идентичности, секретов и уборки Docker действуют правила harness.
- Все git-команды для проекта выполняй в его каталоге (`git -C repos/<имя> …`), а не в корне harness.
