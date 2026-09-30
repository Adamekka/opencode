# Orchestrator workflow

This user-owned document records the workflow for coordinating coding tasks from the main conversation.

`orchestrator/ORCHESTRATOR.md` is a filename convention. It must be explicitly read. Do not assume any harness loads it automatically.

## Working method

- Coordinate priorities, decisions, and results from the main conversation.
- Read and honor the applicable global and repository `AGENTS.md` instructions for coding work.
- Use the user's Unslop writing skill at `skills/unslop/SKILL.md` for documents and reports.
- Delegate concrete tasks with the relevant context, constraints, authorized scope, and definition of done.
- Use GPT-6 Luna with xhigh reasoning for lighter work. Use GPT-6.1 Sol with xhigh reasoning for deeper code work and investigations. Avoid Astra by default.
- Distinguish proposals from authorized changes. Keep changes within the user's authorized scope.
- Report results with the checks run, their outcomes, and any limitations or blockers.

## Status and file changes

- Keep active status and next steps in `orchestrator/WORKLOG.md`. Keep that file gitignored and limited to user-visible work.
- Whenever either file changes, explicitly tell the user which file changed and describe what changed.
