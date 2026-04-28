#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

input="$(read_stdin)"
timestamp="$(jq -r '.timestamp // 0' <<<"$input")"
iso_timestamp="$(epoch_ms_to_iso "$timestamp")"
result_type="$(jq -r '.toolResult.resultType // "unknown"' <<<"$input")"

append_jsonl "tool-results.jsonl" "$(jq -c --arg at "$iso_timestamp" '{event:"postToolUse", at:$at, toolName:(.toolName // "unknown"), resultType:(.toolResult.resultType // "unknown"), textResultForLlm:(.toolResult.textResultForLlm // null)}' <<<"$input")"

if [[ "$result_type" == "failure" ]]; then
  append_jsonl "tool-failures.jsonl" "$(jq -c --arg at "$iso_timestamp" '{event:"postToolUseFailure", at:$at, toolName:(.toolName // "unknown"), toolArgs:(.toolArgs // null), toolResult:(.toolResult // {})}' <<<"$input")"
fi