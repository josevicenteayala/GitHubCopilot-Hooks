#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

input="$(read_stdin)"
timestamp="$(jq -r '.timestamp // 0' <<<"$input")"
iso_timestamp="$(epoch_ms_to_iso "$timestamp")"
tool_name="$(jq -r '.toolName // "unknown"' <<<"$input")"
tool_args_json="$(jq -r '.toolArgs // "{}"' <<<"$input")"
command_text="$(tool_args_field "$tool_args_json" command)"

append_jsonl "tool-requests.jsonl" "$(jq -c --arg at "$iso_timestamp" --arg toolName "$tool_name" --arg command "$command_text" '{event:"preToolUse", at:$at, toolName:$toolName, command:($command | if . == "" then null else . end), rawToolArgs:(.toolArgs // null)}' <<<"$input")"

if [[ "$tool_name" == "bash" ]] && grep -Eqi '(^|[^A-Za-z])(sudo|mkfs|shutdown|reboot)([^A-Za-z]|$)|rm[[:space:]]+-rf[[:space:]]+/|dd[[:space:]]+if=' <<<"$command_text"; then
  jq -nc \
    --arg reason "Blocked by example preToolUse policy: destructive shell command pattern detected." \
    '{permissionDecision:"deny", permissionDecisionReason:$reason}'
  exit 0
fi