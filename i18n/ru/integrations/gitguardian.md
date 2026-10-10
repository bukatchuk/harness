# GitGuardian

Поиск секретов в коде и истории. Интеграция включена, если в `harness.json` есть ключ `integrations.gitguardian`.

- Авторизация: `$GITGUARDIAN_TOKEN`. CLI `ggshield` ждёт переменную `GITGUARDIAN_API_KEY`, поэтому передавай токен в неё на время вызова.
- Установка CLI: `pipx install ggshield`. Через `brew install ggshield` на старых версиях macOS зависимости собираются из исходников часами.
- База API: `https://api.gitguardian.com/v1`, заголовок `Authorization: Token $GITGUARDIAN_TOKEN`.
- Документация: https://docs.gitguardian.com/ggshield-docs/reference/overview

## Вызов

```bash
gg() { GITGUARDIAN_API_KEY="$GITGUARDIAN_TOKEN" ggshield "$@"; }

gg secret scan pre-commit            # то, что добавлено в индекс (запускать в каталоге репозитория)
gg secret scan path -r <каталог>     # файлы на диске
gg secret scan commit-range <база>..HEAD
gg api-status
```

## Правила

- Проверяй индекс перед каждым коммитом (это шаг skill `commit`).
- Нашёлся секрет — не коммить. Сообщи владельцу файл и строку, не цитируя само значение. Если секрет уже попал в историю, его нужно отозвать у сервиса: вычистить историю недостаточно.
- Не добавляй находки в исключения (`ggshield secret ignore`, `.gitguardian.yaml`) без согласия владельца.
