<!-- markdownlint-disable -->

# Hardening Report: AnimMouse--tool-cache/v1.2.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **AnimMouse--tool-cache/v1.2.0** was hardened automatically. 2 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

In `scripts/add-to-path/Unix-like.sh`, the value of `$folder_name` — which is set from `inputs.folder_name` (an attacker-controlled input) via the `env:` block in `action.yaml` — is written directly to `$GITHUB_PATH` on line 4 without the required sanitization step (`printf '%s' "$folder_name" | tr -d '\n\r'`). An attacker can inject newlines into `inputs.folder_name` to write arbitrary entries into `$GITHUB_PATH`, enabling PATH hijacking. The offending line is: `echo $RUNNER_TOOL_CACHE/$folder_name >> $GITHUB_PATH`

Locations:

- `scripts/add-to-path/Unix-like.sh:4`

### script-injection (severity: high)

Rule (b) violation: `$folder_name` (sourced from `inputs.folder_name` via `env:` in action.yaml) is expanded unquoted in multiple shell commands across two scripts. Unquoted expansions allow shell metacharacter injection (word splitting, glob expansion, `;`, `|`, `&`, `$(...)`, etc.) from attacker-controlled input.

In `scripts/install/Unix-like.sh`:
- Line 4: `echo ::group::Installing $folder_name to tool cache` (unquoted)
- Line 5: `mkdir -p $RUNNER_TOOL_CACHE/$folder_name` (unquoted)
- Line 6: `mv $RUNNER_TEMP/$folder_name/* $RUNNER_TOOL_CACHE/$folder_name` (unquoted)

In `scripts/add-to-path/Unix-like.sh`:
- Line 3: `echo ::group::Adding $folder_name tool cache folder to path` (unquoted)
- Line 4: `echo $RUNNER_TOOL_CACHE/$folder_name >> $GITHUB_PATH` (unquoted)

All occurrences should use `"$folder_name"` (double-quoted).

Locations:

- `scripts/install/Unix-like.sh:4`
- `scripts/install/Unix-like.sh:5`
- `scripts/install/Unix-like.sh:6`
- `scripts/add-to-path/Unix-like.sh:3`
- `scripts/add-to-path/Unix-like.sh:4`

## Iteration Notes

### Iteration 1

**Fixes applied:** github-env-injection, script-injection

**Notes:**

Fixed both findings in the two Unix-like shell scripts:

1. scripts/add-to-path/Unix-like.sh:
   - Added newline sanitization: `safe_folder_name=$(printf '%s' "$folder_name" | tr -d '\n\r')` before writing to $GITHUB_PATH (fixes github-env-injection)
   - Used `$safe_folder_name` when writing to $GITHUB_PATH
   - Double-quoted all variable expansions including $folder_name, $RUNNER_TOOL_CACHE, $GITHUB_PATH (fixes script-injection)

2. scripts/install/Unix-like.sh:
   - Double-quoted all occurrences of $folder_name and related path variables ($RUNNER_TOOL_CACHE, $RUNNER_TEMP) to prevent word splitting and glob injection (fixes script-injection)
   - The glob `/*` after the quoted path is intentional and correct for expanding directory contents

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed scripts/add-to-path/Windows.ps1: added `$safe_folder_name = $env:folder_name -replace '[\r\n]', ''` to strip newlines/carriage returns from the attacker-controlled `folder_name` input before writing it to `$GITHUB_PATH`. The sanitized variable is now used in the `Add-Content` call instead of the raw `$env:folder_name`. This mirrors the existing sanitization in the Unix-like counterpart script.

