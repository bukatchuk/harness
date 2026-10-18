#!/usr/bin/env bash
# End-to-end check of the CLI in a throwaway copy: setup, language switch, registry, removal, reset, public build.
# Usage: tests/smoke.sh   (touches nothing outside a temporary directory)
set -u

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/harness-smoke.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT
BOX="$TMP/harness"
H="$BOX/bin/harness"
FAILED=0
# Matched by UTF-8 lead bytes: a character range depends on the locale.
CYR="$(printf '[\320\321][\200-\277]')"
export HARNESS_LANG=en
# The sandbox gets its own git settings file and must not inherit the author pinned for the real harness.
unset GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
export GIT_CONFIG_GLOBAL="$TMP/gitconfig" GIT_CONFIG_NOSYSTEM=1
printf '[user]\n\tname = Sandbox Author\n\temail = sandbox@example.com\n[init]\n\tdefaultBranch = main\n' > "$GIT_CONFIG_GLOBAL"

check() { # check "<what>" <command…>
  local what="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "  ok    $what"; else echo "  FAIL  $what"; FAILED=$((FAILED + 1)); fi
}
refuse() { # the command must fail
  local what="$1"; shift
  if "$@" >/dev/null 2>&1; then echo "  FAIL  $what"; FAILED=$((FAILED + 1)); else echo "  ok    $what"; fi
}

# A copy of the core only: tracked files and new files that are not ignored, without the owner's data.
mkdir -p "$BOX"
(cd "$SRC" && git ls-files -co --exclude-standard) | while IFS= read -r f; do
  case "$f" in harness.json|registry/*) continue ;; esac
  [ -f "$SRC/$f" ] || continue
  mkdir -p "$BOX/$(dirname "$f")" && cp -p "$SRC/$f" "$BOX/$f"
done
git -C "$BOX" init --quiet
git -C "$BOX" add -A && git -C "$BOX" commit --quiet -m "sandbox"

echo "Setup"
check "init writes harness.json"            "$H" init --name "Sandbox Author" --email "sandbox@example.com" --lang en --yes
check "owner is stored"                     test "$(jq -r .owner.email "$BOX/harness.json")" = "sandbox@example.com"
check "commit author is pinned"             test "$(jq -r .env.GIT_AUTHOR_NAME "$BOX/.claude/settings.local.json")" = "Sandbox Author"
check "rules are deployed"                  test -f "$BOX/.claude/rules/git.md"
check "skills are deployed"                 test -f "$BOX/.claude/skills/harness-reset/SKILL.md"
check "empty registries are created"        test "$(jq '.repos | length' "$BOX/registry/repos.json")" = 0
refuse "init rejects a malformed email"     "$H" init --name X --email not-an-email --yes

echo "Language"
echo "my own rule" > "$BOX/.claude/rules/my-own.md"
check "switch to ru"                        "$H" lang ru
check "ru rules are Cyrillic"               env LC_ALL=C grep -q "$CYR" "$BOX/.claude/CLAUDE.md"
check "switch back to en"                   "$H" lang en
refuse "en rules have no Cyrillic"          env LC_ALL=C grep -q "$CYR" "$BOX/.claude/rules/git.md"
check "the user's own rule survives"        test -f "$BOX/.claude/rules/my-own.md"
refuse "unknown language is rejected"       "$H" lang de
check "doctor passes"                       "$H" doctor

echo "Registry"
for r in a b; do
  git init --quiet --bare "$TMP/remote-$r.git"
  git clone --quiet "$TMP/remote-$r.git" "$TMP/seed-$r" 2>/dev/null
  echo "$r" > "$TMP/seed-$r/README.md"
  git -C "$TMP/seed-$r" add README.md && git -C "$TMP/seed-$r" commit --quiet -m "init" && git -C "$TMP/seed-$r" push --quiet origin HEAD:main
done
jq -n --arg a "$TMP/remote-a.git" --arg b "$TMP/remote-b.git" \
  '{repos: [{name: "alpha", url: $a, branch: "main"}, {name: "bravo", url: $b, branch: "main"}]}' > "$BOX/registry/repos.json"
jq -n '{servers: [{name: "east", host: "east.example.com", port: 22, user: "deploy", env: "lab"}, {name: "west", host: "west.example.com", port: 22, user: "deploy", env: "lab"}]}' > "$BOX/registry/servers.json"
jq -n '{services: [{name: "site", scope: "service", repo: "alpha", servers: ["east", "west"]}, {name: "proxy", scope: "service", repo: "bravo", servers: ["east"]}]}' > "$BOX/registry/services.json"
check "sync clones both repositories"       "$H" sync
check "clone exists"                        test -d "$BOX/repos/alpha/.git"
check "status prints a table"               sh -c "'$H' status | grep -q 'REPOSITORY.*BRANCH'"
check "servers prints a table"              sh -c "'$H' servers | grep -q 'east.example.com'"
check "map filters by server"               sh -c "'$H' map west | grep -q site"

echo "Empty repository"
git init --quiet --bare "$TMP/remote-c.git"
cp "$BOX/registry/repos.json" "$TMP/repos.json"
jq --arg c "$TMP/remote-c.git" '.repos += [{name: "charlie", url: $c, branch: "main"}]' "$TMP/repos.json" > "$BOX/registry/repos.json"
check "sync clones an empty repository"     "$H" sync charlie
check "its HEAD points at the registry branch" test "$(git -C "$BOX/repos/charlie" symbolic-ref --short HEAD)" = main
check "status shows it as empty"            sh -c "'$H' status | grep -q 'charlie.*(empty)'"
git clone --quiet "$TMP/remote-c.git" "$TMP/seed-c" 2>/dev/null
echo c > "$TMP/seed-c/README.md"
git -C "$TMP/seed-c" add README.md && git -C "$TMP/seed-c" commit --quiet -m "init" && git -C "$TMP/seed-c" push --quiet origin HEAD:main
check "sync picks up the first commit"      "$H" sync charlie
check "the branch tracks origin"            test "$(git -C "$BOX/repos/charlie" rev-parse --abbrev-ref '@{u}')" = origin/main
check "the file is checked out"             test -f "$BOX/repos/charlie/README.md"
rm -rf "$BOX/repos/charlie"; cp "$TMP/repos.json" "$BOX/registry/repos.json"

echo "Removal"
refuse "server-remove refuses a linked server"   "$H" server-remove east
check  "server-remove --unlink"                  "$H" server-remove east --unlink
check  "link with other servers is kept"         test "$(jq -c '.services[] | select(.name == "site") | .servers' "$BOX/registry/services.json")" = '["west"]'
check  "link left without servers is removed"    test "$(jq '[.services[] | select(.name == "proxy")] | length' "$BOX/registry/services.json")" = 0
check  "service-remove"                          "$H" service-remove site
refuse "service-remove of an unknown link"       "$H" service-remove site
refuse "repo-remove rejects a path as a name"    "$H" repo-remove ../alpha
echo "unsaved" > "$BOX/repos/alpha/work.txt"
check  "repo-remove --delete-clone runs"         "$H" repo-remove alpha --delete-clone
check  "repository left the registry"            test "$(jq '[.repos[] | select(.name == "alpha")] | length' "$BOX/registry/repos.json")" = 0
check  "clone with unsaved work is kept"         test -f "$BOX/repos/alpha/work.txt"
check  "a backup was written"                    sh -c "ls '$BOX'/.harness-backup/*/repos.json"

echo "Reset"
check  "reset without --yes only prints a plan"  "$H" reset
check  "nothing changed without --yes"           test "$(jq '.repos | length' "$BOX/registry/repos.json")" = 1
check  "reset --yes --delete-clones"             "$H" reset --yes --delete-clones
check  "registries are empty"                    test "$(jq -s 'map(to_entries[0].value | length) | add' "$BOX"/registry/*.json)" = 0
check  "clean clone is deleted"                  test ! -e "$BOX/repos/bravo"
check  "settings survive the reset"              test "$(jq -r .lang "$BOX/harness.json")" = en

echo "Integrity and public build"
check  "selfcheck passes"                        "$H" selfcheck
rm -f "$BOX/harness.json"; rm -rf "$BOX/registry"
check  "release-build --preview passes"          "$H" release-build --preview
V="$(cat "$BOX/VERSION")"
check  "the build has no install data"           sh -c "! ls '$BOX/dist/harness-v$V/harness.json' '$BOX/dist/harness-v$V/registry'"
check  "the build ignores user data"             grep -q '^/harness.json$' "$BOX/dist/harness-v$V/.gitignore"
check  "the archive is written"                  test -f "$BOX/dist/harness-v$V.tar.gz"
printf 'contact: someone@%s\n' 'corp.internal.test' > "$BOX/NOTES.md"
refuse "a planted email fails the build"         "$H" release-build --preview
rm -f "$BOX/NOTES.md"
mkdir -p "$BOX/registry" && echo '{"servers": [{"name": "planted", "host": "db7.planted-host.test", "port": 22, "user": "x"}]}' > "$BOX/registry/servers.json"
printf 'ssh to db7.planted-host.test\n' > "$BOX/NOTES.md"
refuse "a planted registry host fails the build" "$H" release-build --preview

echo
if [ "$FAILED" -eq 0 ]; then echo "smoke: all checks passed"; else echo "smoke: failed checks: $FAILED"; fi
exit "$FAILED"
