# GitHub Copilot Hooks Examples

This repository contains runnable examples for GitHub Copilot hooks stored under `.github/hooks/`.

The example set covers all of these hook types:

- `sessionStart`
- `sessionEnd`
- `userPromptSubmitted`
- `preToolUse`
- `postToolUse`
- `agentStop`
- `subagentStop`
- `errorOccurred`

## Files

- `.github/hooks/examples.json`: sample hook configuration file.
- `.github/hooks/scripts/`: bash implementations for each hook.
- `.github/hooks/logs/`: runtime audit logs created by the hooks.
- `.github/hooks/tmp/`: temporary files used during a session.

## What The Examples Do

- `sessionStart`: records a session-start audit event and creates a temporary session context file.
- `sessionEnd`: writes a session summary report and removes temporary files.
- `userPromptSubmitted`: appends the submitted prompt to a JSON Lines audit log.
- `preToolUse`: logs tool requests and blocks obviously dangerous shell commands.
- `postToolUse`: records tool outcomes and writes a separate failure log when a tool fails.
- `agentStop`: captures the final main-agent payload for later review.
- `subagentStop`: captures the final subagent payload before control returns to the parent.
- `errorOccurred`: extracts structured error details into an error log.

## Requirements

These examples target Unix-like environments and assume `bash` and `jq` are available.

## Usage

1. Keep the hook configuration in `.github/hooks/examples.json`.
2. Ensure the scripts are executable.
3. Start Copilot from the repository root so the relative paths resolve correctly.

Example validation commands:

```bash
jq . .github/hooks/examples.json
bash -n .github/hooks/scripts/*.sh
chmod +x .github/hooks/scripts/*.sh
```

For GitHub Copilot cloud agent, the hook configuration must exist on the repository default branch. For GitHub Copilot CLI, hooks are loaded from the current working directory.

## Notes

- The `agentStop` and `subagentStop` examples are intentionally payload-agnostic: they log the full JSON payload without assuming a fixed schema.
- The `preToolUse` example only denies a small set of clearly destructive shell command patterns. Treat it as a starting point for your own policy.
- Runtime logs under `.github/hooks/logs/` are ignored by Git.
