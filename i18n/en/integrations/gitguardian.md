# GitGuardian

Secret scanning in code and history. The integration is enabled if `harness.json` has the key `integrations.gitguardian`.

- Authorization: `$GITGUARDIAN_TOKEN`. The `ggshield` CLI expects the variable `GITGUARDIAN_API_KEY`, so pass the token into it for the duration of the call.
- CLI installation: `pipx install ggshield`. With `brew install ggshield` on old macOS versions, the dependencies build from source for hours.
- API base: `https://api.gitguardian.com/v1`, header `Authorization: Token $GITGUARDIAN_TOKEN`.
- Documentation: https://docs.gitguardian.com/ggshield-docs/reference/overview

## Usage

```bash
gg() { GITGUARDIAN_API_KEY="$GITGUARDIAN_TOKEN" ggshield "$@"; }

gg secret scan pre-commit            # what is staged (run in the repository directory)
gg secret scan path -r <dir>         # files on disk
gg secret scan commit-range <base>..HEAD
gg api-status
```

## Rules

- Check the index before every commit (this is a step of the `commit` skill).
- If a secret is found, do not commit. Tell the owner the file and line without quoting the value itself. If the secret has already reached the history, it must be revoked at the service: cleaning the history is not enough.
- Do not add findings to exclusions (`ggshield secret ignore`, `.gitguardian.yaml`) without the owner's consent.
