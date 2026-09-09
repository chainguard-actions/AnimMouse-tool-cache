<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--tool-cache/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--tool-cache/v1.2.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

The script writes an untrusted input value to $GITHUB_PATH without sanitization. In scripts/add-to-path/Unix-like.sh, the variable $folder_name is sourced from inputs.folder_name (set via env: in action.yaml) and written directly to $GITHUB_PATH: `echo $RUNNER_TOOL_CACHE/$folder_name >> $GITHUB_PATH`. An attacker-controlled folder_name containing newlines could inject arbitrary entries into GITHUB_PATH. The required sanitization step (`printf '%s' "$folder_name" | tr -d '\n\r'`) is missing before the write. Similarly, scripts/add-to-path/Windows.ps1 writes `$env:RUNNER_TOOL_CACHE\$env:folder_name` to $env:GITHUB_PATH via Add-Content without sanitization.

Locations:

- `scripts/add-to-path/Unix-like.sh:4`
- `scripts/add-to-path/Windows.ps1:4`

### unpinned-uses (severity: high)

The workflow file .github/workflows/test.yaml references actions by mutable tag or branch instead of a pinned full 40-character commit SHA, making the workflow vulnerable to supply-chain attacks if the referenced tag or branch is moved or compromised. Failing references: `uses: actions/cache/restore@v5` (line ~30), `uses: AnimMouse/tool-cache@main` (line ~52), `uses: actions/cache/save@v5` (line ~58). All should be pinned to a full SHA digest, e.g. `actions/cache/restore@<40-hex-sha> # v5`.

Locations:

- `.github/workflows/test.yaml:30`
- `.github/workflows/test.yaml:52`
- `.github/workflows/test.yaml:58`

### missing-permissions (severity: medium)

The workflow file .github/workflows/test.yaml has no top-level `permissions:` key and no job-level `permissions:` key on the `test` job. Without explicit permissions, the workflow inherits the repository's default token permissions (which may be write-all), violating the principle of least privilege. A `permissions:` block with only the required scopes (e.g. `contents: read`) should be added at the top level or on every job.

Locations:

- `.github/workflows/test.yaml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, unpinned-uses, missing-permissions

**Notes:**

1. scripts/add-to-path/Unix-like.sh: Added sanitization of folder_name using `printf '%s' "$folder_name" | tr -d '\n\r'` before writing to $GITHUB_PATH. 2. scripts/add-to-path/Windows.ps1: Added sanitization of folder_name using PowerShell's `-replace '[\r\n]', ''` before writing to $env:GITHUB_PATH. 3. .github/workflows/test.yaml: Pinned actions/cache/restore@v5 to SHA caa296126883cff596d87d8935842f9db880ef25, AnimMouse/tool-cache@main to SHA c58dc704bd326aa5d6f995afe80ac0486ec59c5e, and actions/cache/save@v5 to SHA caa296126883cff596d87d8935842f9db880ef25. Added top-level `permissions: contents: read` block.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Fixed unquoted expansions of $folder_name in hardened/action/scripts/install/Unix-like.sh. All three affected lines (4, 5, 6) now use double-quoted expansions: (1) `echo "::group::Installing $folder_name to tool cache"`, (2) `mkdir -p "$RUNNER_TOOL_CACHE/$folder_name"`, (3) `mv "$RUNNER_TEMP/$folder_name/"* "$RUNNER_TOOL_CACHE/$folder_name"`. The glob `*` on line 6 is kept outside the quotes so it still expands correctly under `shopt -s dotglob`, while `$folder_name` is protected inside the quoted prefix.

