#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

input="$(read_stdin)"

append_jsonl "subagent-stop.jsonl" "$(jq -c '{event:"subagentStop", timestamp:(.timestamp // null), cwd:(.cwd // null), payload:.}' <<<"$input")"