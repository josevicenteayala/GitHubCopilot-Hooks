#!/usr/bin/env bash
set -euo pipefail

HOOKS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$HOOKS_ROOT/logs"
TMP_DIR="$HOOKS_ROOT/tmp"

mkdir -p "$LOG_DIR" "$TMP_DIR"

read_stdin() {
  cat
}

epoch_ms_to_iso() {
  local timestamp_ms="${1:-0}"

  if [[ "$timestamp_ms" =~ ^[0-9]+$ ]]; then
    date -u -d "@$((timestamp_ms / 1000))" +"%Y-%m-%dT%H:%M:%SZ"
    return 0
  fi

  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

tool_args_field() {
  local tool_args_json="$1"
  local field_name="$2"

  jq -r --arg field_name "$field_name" '.[$field_name] // empty' <<<"$tool_args_json" 2>/dev/null || true
}

append_jsonl() {
  local file_name="$1"
  local payload="$2"

  printf '%s\n' "$payload" >> "$LOG_DIR/$file_name"
}

format_json_file() {
  local file_path="$1"
  local indent="${2:-2}"
  local tmp_file

  if [[ -z "$file_path" ]]; then
    echo "format_json_file: file path is required" >&2
    return 1
  fi

  if [[ ! -f "$file_path" ]]; then
    echo "format_json_file: file not found: $file_path" >&2
    return 1
  fi

  tmp_file="$(mktemp)"

  if jq --indent "$indent" '.' "$file_path" >"$tmp_file"; then
    mv "$tmp_file" "$file_path"
    return 0
  fi

  rm -f "$tmp_file"
  return 1
}