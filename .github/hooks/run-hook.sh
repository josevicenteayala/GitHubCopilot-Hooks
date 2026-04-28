#!/usr/bin/env bash
# run-hook.sh — Dispatcher for manually invoking Copilot hook scripts.
#
# Usage:
#   ./run-hook.sh <hookName> [fixture-json-file]
#   echo '{"timestamp":0}' | ./run-hook.sh <hookName>
#
# Hook names (case-sensitive):
#   sessionStart, sessionEnd, userPromptSubmitted,
#   preToolUse, postToolUse, agentStop, subagentStop, errorOccurred
#
# If a fixture file is NOT provided and stdin is a TTY, the default fixture
# from fixtures/<kebab-hook-name>.json is used automatically.

set -euo pipefail

HOOKS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$HOOKS_ROOT/scripts"
FIXTURES_DIR="$HOOKS_ROOT/fixtures"

usage() {
  echo "Usage: $0 <hookName> [fixture-json-file]" >&2
  echo "" >&2
  echo "Hook names: sessionStart sessionEnd userPromptSubmitted preToolUse postToolUse agentStop subagentStop errorOccurred" >&2
  exit 1
}

# Map camelCase hook name -> script filename and fixture filename (kebab-case)
hook_to_script() {
  case "$1" in
    sessionStart)         echo "session-start.sh" ;;
    sessionEnd)           echo "session-end.sh" ;;
    userPromptSubmitted)  echo "user-prompt-submitted.sh" ;;
    preToolUse)           echo "pre-tool-use.sh" ;;
    postToolUse)          echo "post-tool-use.sh" ;;
    agentStop)            echo "agent-stop.sh" ;;
    subagentStop)         echo "subagent-stop.sh" ;;
    errorOccurred)        echo "error-occurred.sh" ;;
    *)
      echo "Unknown hook: $1" >&2
      usage
      ;;
  esac
}

hook_to_fixture() {
  case "$1" in
    sessionStart)         echo "session-start.json" ;;
    sessionEnd)           echo "session-end.json" ;;
    userPromptSubmitted)  echo "user-prompt-submitted.json" ;;
    preToolUse)           echo "pre-tool-use.json" ;;
    postToolUse)          echo "post-tool-use.json" ;;
    agentStop)            echo "agent-stop.json" ;;
    subagentStop)         echo "subagent-stop.json" ;;
    errorOccurred)        echo "error-occurred.json" ;;
  esac
}

[[ $# -lt 1 ]] && usage

HOOK_NAME="$1"
SCRIPT_FILE="$SCRIPTS_DIR/$(hook_to_script "$HOOK_NAME")"

if [[ ! -x "$SCRIPT_FILE" ]]; then
  echo "Script not found or not executable: $SCRIPT_FILE" >&2
  exit 1
fi

# Determine payload source: explicit file arg > piped stdin > default fixture
if [[ $# -ge 2 ]]; then
  PAYLOAD_FILE="$2"
  if [[ ! -f "$PAYLOAD_FILE" ]]; then
    echo "Fixture file not found: $PAYLOAD_FILE" >&2
    exit 1
  fi
  jq . "$PAYLOAD_FILE" | "$SCRIPT_FILE"
elif ! [[ -t 0 ]]; then
  # stdin is piped
  "$SCRIPT_FILE"
else
  FIXTURE_NAME="$(hook_to_fixture "$HOOK_NAME")"
  FIXTURE_FILE="$FIXTURES_DIR/$FIXTURE_NAME"
  if [[ ! -f "$FIXTURE_FILE" ]]; then
    echo "Default fixture not found: $FIXTURE_FILE" >&2
    exit 1
  fi
  echo "Using fixture: $FIXTURE_FILE" >&2
  jq . "$FIXTURE_FILE" | "$SCRIPT_FILE"
fi
