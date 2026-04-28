#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

input="$(read_stdin)"
timestamp="$(jq -r '.timestamp // 0' <<<"$input")"
iso_timestamp="$(epoch_ms_to_iso "$timestamp")"

append_jsonl "audit.jsonl" "$(jq -c --arg at "$iso_timestamp" '{event:"sessionStart", at:$at, source:(.source // "unknown"), cwd:(.cwd // null), initialPrompt:(.initialPrompt // null)}' <<<"$input")"

jq -n \
  --arg startedAt "$iso_timestamp" \
  --arg source "$(jq -r '.source // "unknown"' <<<"$input")" \
  --arg cwd "$(jq -r '.cwd // ""' <<<"$input")" \
  --arg initialPrompt "$(jq -r '.initialPrompt // ""' <<<"$input")" \
  '{startedAt:$startedAt, source:$source, cwd:$cwd, initialPrompt:($initialPrompt | if . == "" then null else . end)}' \
  > "$TMP_DIR/session-context.json"