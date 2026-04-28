#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

input="$(read_stdin)"
timestamp="$(jq -r '.timestamp // 0' <<<"$input")"
iso_timestamp="$(epoch_ms_to_iso "$timestamp")"

append_jsonl "prompts.jsonl" "$(jq -c --arg at "$iso_timestamp" '{event:"userPromptSubmitted", at:$at, cwd:(.cwd // null), prompt:(.prompt // "")}' <<<"$input")"