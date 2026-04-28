HOOKS_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DISPATCHER := $(HOOKS_ROOT)run-hook.sh

.PHONY: session-start session-end user-prompt-submitted pre-tool-use post-tool-use \
        agent-stop subagent-stop error-occurred run-all

session-start:
	@$(DISPATCHER) sessionStart

session-end:
	@$(DISPATCHER) sessionEnd

user-prompt-submitted:
	@$(DISPATCHER) userPromptSubmitted

pre-tool-use:
	@$(DISPATCHER) preToolUse

post-tool-use:
	@$(DISPATCHER) postToolUse

agent-stop:
	@$(DISPATCHER) agentStop

subagent-stop:
	@$(DISPATCHER) subagentStop

error-occurred:
	@$(DISPATCHER) errorOccurred

## Run every hook in lifecycle order using its default fixture
run-all: session-start user-prompt-submitted pre-tool-use post-tool-use \
         agent-stop subagent-stop error-occurred session-end
	@echo "All hooks executed successfully."
