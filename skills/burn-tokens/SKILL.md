---
name: burn-tokens
description: Use ONLY when explicitly invoked to run sustained feature and review loops across AITranscribe, Alarm, web-browser, WifiAnalyzer, AppWrapper, AITranscribeBackend, and CoreUtils, with a fresh T3 thread for each loop.
---

# Burn tokens

Turn spare token capacity into useful, verified application changes. This skill runs only when explicitly invoked. Creating or editing the skill does not start its loops.

## Targets

Repositories always live in `~/Coding`. Resolve the existing `~/Coding/<repository>` checkout for each target. Report and skip missing or ambiguous repositories; do not create, clone, or substitute repositories.

| Repository | Loops |
| --- | --- |
| AITranscribe | Features and bug fixes |
| Alarm | Features and bug fixes |
| web-browser | Features and bug fixes |
| WifiAnalyzer | Features and bug fixes |
| AppWrapper | Review and improvements |
| AITranscribeBackend | Review and improvements |
| CoreUtils | Review and improvements |

Use [review](../review/SKILL.md) for every bug-fix or review-and-fix loop. Also use it for the final review of each feature. AppWrapper, AITranscribeBackend, and CoreUtils permit bug fixes and worthwhile review improvements, including refactoring, without new feature development.

## Repository availability

Apply these checks before launching a loop. The loop thread must repeat them before inspecting implementation files or running repository commands beyond availability checks.

1. Resolve the checkout's real path, Git common directory, and repository identity. Treat other worktrees, symlinks, and separately registered checkouts of the same repository as the same target.
2. Inspect the available agent/session inventory. In T3, paginate `t3_project_list` to map projects, and `t3_thread_list` with `allProjects: true` and `includeSubagents: true` to find activity. Match projects by canonical path and repository identity, not just title. Include preparing, queued, starting, running, and waiting threads. Read ambiguous threads to establish their checkout and any pending work. Check available session/process ownership metadata for agents outside T3 as well.
3. Skip the entire repository if another agent has active or pending work there, even in another worktree or on different files. Another loop's repository claim or an ownership lock also makes it unavailable. On repeat checks, recognize only this loop's matching ownership token as its own claim. A clean Git status or absence of a claim does not establish that the repository is idle. If activity cannot be established reliably, skip it and report the uncertainty.
4. Exclude only this invocation's coordinator, which performs orchestration without repository work, and the loop thread currently performing the check. Snapshot-only reviewers requested by that loop may analyze supplied text without accessing the checkout. All other agents, including other loops from this invocation, count as competing activity.
5. Require a clean checkout before starting. Skip existing staged, unstaged, or untracked changes rather than adopting, stashing, or discarding them.

After passing the checks, the loop thread must claim the repository with an atomic `mkdir` of `burn-tokens.lock` inside its resolved Git common directory. Record its thread ID, invocation ID, and a unique ownership token inside the directory. This coordinates burn-tokens invocations across worktrees; it does not replace the agent inventory checks. If creation fails or a claim already exists, skip the repository. Do not steal or expire another claim based on its age.

Recheck activity after acquiring the claim and before editing, running verification, and committing. If a competing agent appears, stop repository work, preserve all changes, and report the collision. On completion or interruption, remove only a claim whose ownership token matches this loop. Never clear another agent's lock. An interrupted claim with uncertain ownership requires investigation rather than automatic removal.

## Coordinator

The invoking thread coordinates work. It does not implement changes itself.

1. Honor any repository selection, priorities, time limit, token budget, or loop count supplied with the invocation. Count in-flight loops toward a loop limit and pass an absolute deadline to workers for a time limit. Divide an explicit token budget among concurrent loops only when the runtime can enforce or measure it. If a requested limit cannot be enforced or measured, stop and report the limitation rather than proceeding without it. Without a limit, keep doing worthwhile work until the stopping conditions below apply. Do not invent a token budget or claim access to the user's remaining subscription quota.
2. Track each target's last loop, result, commits, verification, deferred decisions, and reason for skipping. Rotate among available targets so a single app does not monopolize the run. Alternate feature and review loops on the four apps, prioritizing known serious defects.
3. Select an available target and resolve its T3 project by the exact checkout path. If the existing checkout is not registered, register that folder using `t3_project_create` with an explicit `workspaceRoot` and `createWorkspaceRootIfMissing: false`.
4. Start a **new top-level T3 thread for every loop** using `t3_thread_launch`. Pass the target `projectId` and `workspaceStrategy: { type: "root" }` so the thread starts in the correct `~/Coding` repository. Use one retained `clientRequestId` for a launch and any uncertain retry. Inherit the current model and execution permissions. Do not reuse an old loop thread, use a delegate as its replacement, or create worktrees to bypass a busy repository.
5. Give the new thread a self-contained brief containing the target and mode, invocation ID, coordinator thread ID, remaining limits, relevant prior results, and the contents of [loop-thread.md](references/loop-thread.md). Include the resolved paths to this skill and the review skill. The new thread executes its assigned loop without recursively invoking the coordinator or launching another loop.
6. Follow the launch with `t3_thread_read` or `t3_thread_wait`, and follow the tools' continuation instructions. A finished turn with pending questions or child work is still in flight. Resolve required user decisions using the applicable clarification rules; do not assume an answer. Before selecting further work for that repository, read the final result and confirm all work has settled and the claim has been released.
7. Different idle repositories may run concurrently when capacity allows. Never have two loops in flight for the same repository. Check availability again before each launch, including repeat loops.

## Loop scope

- A feature loop selects and completes one coherent feature in an eligible app, including its review and fixes. Selection should follow documented product direction, known user needs, and gaps in existing workflows. Explain the user benefit and chosen scope before editing. Preserve applicable feature-selection and clarification requirements; defer work that needs an unresolved product decision rather than inventing behavior.
- A bug-fix or review-and-fix loop invokes the review skill in full-project mode within the target's authorized scope. Follow its review, fix, verify, commit, and resume procedure and its stopping rule. Do not replace it with a separate review checklist. Respect invocation limits and repository ownership throughout the pass.
- After a completed feature loop, schedule a review loop when worthwhile. After a review loop, use newly established app gaps to choose a feature loop. AppWrapper, AITranscribeBackend, and CoreUtils remain limited to their table entries.

## Stopping and reporting

Continue while eligible repositories have worthwhile work. Spending tokens is the opportunity, not a reason to invent defects, add filler features, churn code, or repeat clean reviews of unchanged code.

Stop at the user's limit or stop request, when every target is busy, blocked, unavailable, or exhausted, or when a complete rotation produces no worthwhile work that can proceed. A review with no worthwhile findings completes that review target until relevant code or requirements change; the four apps may still have feature work. Do not poll busy repositories or manufacture work to keep the run alive.

At a limit or stop request, start no new loops. Safely stop any loop threads started by this invocation and their delegates, preserve unfinished changes, and release their claims only after their work has stopped. Use `t3_thread_interrupt` for these top-level loop threads and `task_cancel` for their delegates. Do not interrupt unrelated agents. Do not create recurring schedules under this invocation. Before the final handoff, settle or stop the loops; a tool-directed yield that will resume orchestration is not a final handoff.

Report completed work by repository with commits and verification, remaining changes and blockers, skipped repositories with reasons, and each created thread's returned link. Distinguish a clean completed review from an incomplete or unverified pass.
