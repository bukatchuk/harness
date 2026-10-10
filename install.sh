#!/usr/bin/env bash
# harness installer.
#
#   curl -fsSL https://raw.githubusercontent.com/bukatchuk/harness/main/install.sh | bash
#
# Environment:
#   HARNESS_DIR    where to install (default: ~/harness)
#   HARNESS_REPO   repository to clone (default: https://github.com/bukatchuk/harness.git)
#   HARNESS_NAME, HARNESS_EMAIL, HARNESS_LANG (ru|en)
#                  commit author and language; when name and email are set, nothing is asked
set -eu

# The whole script is one function called on the last line: a download cut in the middle runs nothing.
main() {
  local dir="${HARNESS_DIR:-$HOME/harness}"
  local repo="${HARNESS_REPO:-https://github.com/bukatchuk/harness.git}"
  local lang="${HARNESS_LANG:-}" tool missing=""

  if [ -z "$lang" ]; then
    case "${LC_ALL:-${LC_MESSAGES:-${LANG:-}}}" in ru*) lang=ru ;; *) lang=en ;; esac
  fi
  say() { if [ "$lang" = ru ]; then printf '%s\n' "$1"; else printf '%s\n' "$2"; fi; }

  say "Установка harness в $dir" "Installing harness into $dir"

  for tool in git jq; do
    command -v "$tool" >/dev/null 2>&1 || missing="$missing $tool"
  done
  if [ -n "$missing" ]; then
    say "Не хватает утилит:$missing" "Missing tools:$missing"
    case "$(uname -s)" in
      Darwin) say "Установи: brew install$missing" "Install them: brew install$missing" ;;
      *)      say "Установи пакетным менеджером системы, например: sudo apt-get install -y$missing" \
                  "Install them with your package manager, for example: sudo apt-get install -y$missing" ;;
    esac
    exit 1
  fi

  if [ -d "$dir/.git" ] && [ -x "$dir/bin/harness" ]; then
    say "harness уже установлен — обновляю (только fast-forward)" "harness is already installed — updating (fast-forward only)"
    if ! git -C "$dir" pull --quiet --ff-only; then
      say "Обновить не удалось: в $dir есть локальные изменения или ветка разошлась. Ничего не изменено." \
          "Could not update: $dir has local changes or the branch has diverged. Nothing was changed."
      exit 1
    fi
  elif [ -e "$dir" ] && [ -n "$(ls -A "$dir" 2>/dev/null)" ]; then
    say "Каталог $dir существует и не пуст. Укажи другой: HARNESS_DIR=/путь" \
        "Directory $dir exists and is not empty. Choose another one: HARNESS_DIR=/path"
    exit 1
  else
    git clone --quiet "$repo" "$dir"
  fi

  set -- --lang "$lang"
  [ -z "${HARNESS_NAME:-}" ]  || set -- "$@" --name "$HARNESS_NAME"
  [ -z "${HARNESS_EMAIL:-}" ] || set -- "$@" --email "$HARNESS_EMAIL"
  if [ -n "${HARNESS_NAME:-}" ] && [ -n "${HARNESS_EMAIL:-}" ]; then
    set -- "$@" --yes
  elif ! { : < /dev/tty; } 2>/dev/null; then
    # No terminal to ask: take the author from the global git settings or stop with a hint.
    set -- "$@" --yes
  fi
  if ! "$dir/bin/harness" init "$@"; then
    say "harness скачан, но не настроен. Заверши настройку: $dir/bin/harness init" \
        "harness is downloaded but not set up. Finish the setup: $dir/bin/harness init"
    exit 1
  fi

  for tool in claude gh docker; do
    command -v "$tool" >/dev/null 2>&1 || say "  заметка: $tool не найден — см. README, раздел «Требования»" "  note: $tool was not found — see README, section \"Requirements\""
  done
  echo
  say "Готово. Запусти: cd $dir && claude" "Done. Start: cd $dir && claude"
}

main "$@"
