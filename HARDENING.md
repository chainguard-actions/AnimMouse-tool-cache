<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--tool-cache/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--tool-cache/v1** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In scripts/add-to-path/Unix-like.sh (called by action.yaml), the variable $folder_name — which is set from inputs.folder_name via the env: block — is written directly to $GITHUB_PATH without the required sanitization step (printf '%s' "$folder_name" | tr -d '\n\r'). An attacker-controlled input containing newline characters could inject arbitrary entries into GITHUB_PATH. The offending line is: `echo $RUNNER_TOOL_CACHE/$folder_name >> $GITHUB_PATH`

Locations:

- `scripts/add-to-path/Unix-like.sh:4`
- `action.yaml:21`

### script-injection (severity: high)

Rule (b): Multiple shell scripts expand $folder_name (sourced from inputs.folder_name via env:) and other runner env vars without double-quoting, allowing shell metacharacter injection if the value contains spaces, globs, or other special characters.

In scripts/add-to-path/Unix-like.sh:
  - `echo ::group::Adding $folder_name tool cache folder to path` (unquoted)
  - `echo $RUNNER_TOOL_CACHE/$folder_name >> $GITHUB_PATH` (unquoted)

In scripts/install/Unix-like.sh:
  - `echo ::group::Installing $folder_name to tool cache` (unquoted)
  - `mkdir -p $RUNNER_TOOL_CACHE/$folder_name` (unquoted)
  - `mv $RUNNER_TEMP/$folder_name/* $RUNNER_TOOL_CACHE/$folder_name` (unquoted)

All occurrences of $folder_name should be double-quoted as "$folder_name".

Locations:

- `scripts/add-to-path/Unix-like.sh:3`
- `scripts/add-to-path/Unix-like.sh:4`
- `scripts/install/Unix-like.sh:4`
- `scripts/install/Unix-like.sh:5`
- `scripts/install/Unix-like.sh:6`

### unpinned-uses (severity: high)

The workflow file .github/workflows/test.yaml references actions using mutable tags and branch names instead of pinned full-length SHA digests, making the workflow vulnerable to supply-chain attacks if those refs are moved:
  - `uses: actions/cache/restore@v5` (mutable tag)
  - `uses: AnimMouse/tool-cache@main` (mutable branch)
  - `uses: actions/cache/save@v5` (mutable tag)
All three should be pinned to a full 40-character commit SHA (e.g. `actions/cache/restore@<sha> # v5`).

Locations:

- `.github/workflows/test.yaml:24`
- `.github/workflows/test.yaml:50`
- `.github/workflows/test.yaml:57`

### missing-permissions (severity: medium)

The workflow file .github/workflows/test.yaml has no top-level `permissions:` key and the single job `test` also has no job-level `permissions:` key. Without explicit permissions, the workflow inherits the repository default (typically write-all for private repos or read-all for public repos), granting broader access than necessary. A minimal `permissions: {}` or specific scopes (e.g. `contents: read`) should be declared.

Locations:

- `.github/workflows/test.yaml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all four findings:
1. github-env-injection: scripts/add-to-path/Unix-like.sh now sanitizes folder_name with `printf '%s' "$folder_name" | tr -d '\n\r'` before writing to GITHUB_PATH.
2. script-injection: Double-quoted all unquoted variable expansions in both scripts/add-to-path/Unix-like.sh and scripts/install/Unix-like.sh.
3. unpinned-uses: Pinned all three action references in .github/workflows/test.yaml to full 40-character commit SHAs (actions/cache/restore and actions/cache/save both to caa296126883cff596d87d8935842f9db880ef25, AnimMouse/tool-cache to c58dc704bd326aa5d6f995afe80ac0486ec59c5e).
4. missing-permissions: Added `permissions: {}` at the top level of .github/workflows/test.yaml.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed scripts/add-to-path/Windows.ps1 to sanitize the folder_name value before writing to $GITHUB_PATH. Added `$safe_folder_name = $env:folder_name -replace '[\r\n]', ''` and used `$safe_folder_name` in the Add-Content call instead of the raw `$env:folder_name`. This mirrors the sanitization already present in the Unix-like counterpart (Unix-like.sh uses `printf '%s' "$folder_name" | tr -d '\n\r'`), preventing newline injection into GITHUB_PATH.

