#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

input="$(read_stdin)"

append_jsonl "agent-stop.jsonl" "$(jq -c '{event:"agentStop", timestamp:(.timestamp // null), cwd:(.cwd // null), payload:.}' <<<"$input")"