#!/bin/sh
set -eu
echo ::group::Adding $folder_name tool cache folder to path
safe_folder_name=$(printf '%s' "$folder_name" | tr -d '\n\r')
echo "$RUNNER_TOOL_CACHE/$safe_folder_name" >> "$GITHUB_PATH"
echo ::endgroup::
