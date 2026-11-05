# Loop thread brief

You are executing one burn-tokens loop in a new top-level T3 thread. Work only in the assigned repository and mode. The coordinator supplies the target, invocation ID, its thread ID, current limits, prior results, and the resolved skill paths. Read the supplied burn-tokens skill for its scope and repository availability rules, but do not invoke its coordinator workflow, create another loop thread, or schedule future work.

## Before work

- Repeat the burn-tokens repository availability checks and acquire its repository claim before inspecting implementation files. Count other worktrees and other agents' pending work as competing activity. If unavailable, report the reason and finish without doing repository work.
- Read the repository's applicable `AGENTS.md`, relevant product documentation, and required language and workflow skills. Use [projects-docs](../../projects-docs/SKILL.md) for project documentation. Honor repository requirements and preserve production data and protocol compatibility.
- Establish the existing build and verification commands. Record the starting commit and clean status. A failed required baseline check blocks work in that area; report it rather than repairing unrelated paths.
- State the chosen feature or review scope and update the plan before non-trivial implementation. If a required product decision is unresolved, follow the applicable one-question-at-a-time clarification rule. Do not invent required state or configuration values.

## Feature mode

Choose one useful feature within the assigned app's established purpose. Prefer documented requests and concrete gaps in existing user workflows. Describe its user benefit, expected behavior, and a bounded implementation. Avoid speculative integrations or new paid services without authorization.

Implement in small, reviewable increments using existing shared behavior. Complete the real user workflow, including relevant persistence, cancellation, error recovery, accessibility, and localization. Verify behavior with the project's appropriate checks and inspect rendered UI when the work requires it. Before touching a simulator or emulator, use [simlock](../../simlock/SKILL.md) and the available T3 device workflow.

Use [review](../../review/SKILL.md) for the final change or feature review. Fix verified findings and recheck affected behavior. Commit completed independent changes with [git-commit](../../git-commit/SKILL.md). Keep the feature and its fixes together according to that skill.

## Bug-fix and review modes

Use [review](../../review/SKILL.md) in full-project mode. Follow its review, fix, verify, commit, and resume loop until its stopping rule applies, a real blocker occurs, or the supplied limit is reached. Review findings must have concrete evidence and impact. AppWrapper, AITranscribeBackend, and CoreUtils authorize bug fixes and worthwhile review improvements, including refactoring, without new feature development.

Use that skill's independent review procedure and required review models. Give snapshot-only reviewers the relevant text and prohibit repository access and edits so they do not become competing repository agents. Report unavailable review perspectives as verification limits.

## Finish

- Recheck ownership before changes, verification, and commits. Stop if competing activity appears. Do not touch a busy dependency or consuming app to finish a cross-repository change; report the dependency or choose a different self-contained task.
- Preserve unrelated files and existing external configuration. Do not push, deploy, publish, change production services, or edit global instructions or skills under this loop's authorization.
- On a required decision, failed verification, or lost ownership, stop the affected loop. Preserve unfinished changes and report their exact status. Do not commit a failed or unverified fix.
- Release only this loop's repository claim after repository work and any child work have stopped. Finish with the feature or findings addressed, commit hashes, checks and outcomes, remaining changes, deferred findings and decisions, and whether the review completed a clean pass. Do not start the next loop.
