# Contributing

[Русская версия ниже](#как-участвовать)

Thanks for considering a contribution. harness is small on purpose, so the bar for adding things is "can this be a script or a hook instead of a rule?".

## Ground rules

- **Keep it thin.** A new rule costs context in every session of every user. Prefer a check in `bin/harness` or a hook; delete a rule that is no longer needed.
- **Two languages, always.** Rules, skills and cheat sheets live in `i18n/ru` and `i18n/en` and must match in file set and in meaning. Files under `.claude/` are a deployed copy — never edit them. CLI messages are written as a pair: `say "<русский>" "<english>"`.
- **No personal data in the core.** Names, hosts, URLs and ids belong in `harness.json` and `registry/`, which are not part of this repository.
- **Every commit bumps the version**: `VERSION`, plus an entry in `CHANGELOG.md` and `CHANGELOG.en.md`. The git hooks enforce it.
- **bash 3.2 compatible**: macOS ships it, so no associative arrays, no `mapfile`, no `${var,,}`.

## Workflow

```bash
git clone https://github.com/bukatchuk/harness.git && cd harness
bin/harness init                  # owner, language, git hooks
# edit i18n/ru/… and i18n/en/…, or bin/harness
bin/harness lang                  # redeploy .claude/ from i18n
bin/harness selfcheck             # integrity: versions, language sets, syntax
tests/smoke.sh                    # end-to-end in a sandbox
bin/harness release-build --preview   # public build + leak check
```

Open a pull request against `main`. CI runs the same checks on Linux and macOS.

## Reporting bugs and security issues

Bugs and ideas — GitHub issues. Vulnerabilities — see [SECURITY.md](SECURITY.md); please do not open a public issue for them.

---

# Как участвовать

Спасибо, что хочешь помочь. harness намеренно небольшой, поэтому главный вопрос к любому добавлению: «нельзя ли решить это скриптом или хуком вместо правила?».

## Основные правила

- **Держи harness тонким.** Новое правило стоит контекста в каждой сессии каждого пользователя. Лучше проверка в `bin/harness` или хук; правило, которое перестало быть нужным, удаляется.
- **Всегда два языка.** Правила, skills и шпаргалки лежат в `i18n/ru` и `i18n/en` и совпадают по составу файлов и по смыслу. Файлы в `.claude/` — развёрнутая копия, их не правят. Сообщения CLI пишутся парой: `say "<русский>" "<english>"`.
- **В ядре нет личных данных.** Имена, адреса, ссылки и идентификаторы живут в `harness.json` и `registry/`, которые в этот репозиторий не входят.
- **Каждый коммит поднимает версию**: `VERSION` и запись в `CHANGELOG.md` и `CHANGELOG.en.md`. Это проверяют git-хуки.
- **Совместимость с bash 3.2**: он стоит в macOS, поэтому без ассоциативных массивов, `mapfile` и `${var,,}`.

## Порядок работы

```bash
git clone https://github.com/bukatchuk/harness.git && cd harness
bin/harness init                  # владелец, язык, git-хуки
# правки в i18n/ru/… и i18n/en/… или в bin/harness
bin/harness lang                  # развернуть .claude/ из i18n
bin/harness selfcheck             # целостность: версии, языковые комплекты, синтаксис
tests/smoke.sh                    # сквозная проверка в песочнице
bin/harness release-build --preview   # публичная сборка и проверка на утечки
```

Открой pull request в `main`. CI запускает те же проверки на Linux и macOS.

## Ошибки и уязвимости

Ошибки и идеи — в issues на GitHub. Уязвимости — см. [SECURITY.md](SECURITY.md); публичный issue для них не открывай.
