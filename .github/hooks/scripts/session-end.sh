#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/common.sh"

input="$(read_stdin)"
timestamp="$(jq -r '.timestamp // 0' <<<"$input")"
iso_timestamp="$(epoch_ms_to_iso "$timestamp")"
report_path="$LOG_DIR/session-report-$timestamp.json"

append_jsonl "audit.jsonl" "$(jq -c --arg at "$iso_timestamp" '{event:"sessionEnd", at:$at, reason:(.reason // "unknown"), cwd:(.cwd // null)}' <<<"$input")"

if [[ -f "$TMP_DIR/session-context.json" ]]; then
  jq -n \
    --slurpfile session "$TMP_DIR/session-context.json" \
    --argjson ended "$input" \
    '{session:($session[0] // {}), ended:$ended}' > "$report_path"
else
  jq -n --argjson ended "$input" '{session:{}, ended:$ended}' > "$report_path"
fi

find "$TMP_DIR" -mindepth 1 -delete