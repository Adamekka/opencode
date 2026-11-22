---
name: burn-tokens
description: Use ONLY when explicitly invoked to run sustained loops across AITranscribe with AITranscribeBackend, Alarm, web-browser, WifiAnalyzer, AppPlatform, and CoreUtils, with a fresh T3 thread for each loop. GPT models run bug-fix loops; Claude models run feature loops.
disable-model-invocation: true
---

# Burn tokens

Turn spare token capacity into useful, verified application changes. This skill runs only when explicitly invoked. Creating or editing the skill does not start its loops.

## Targets

Repositories always live in `~/Coding`. Resolve the existing `~/Coding/<repository>` checkout for each target. Report and skip missing or ambiguous repositories; do not create, clone, or substitute repositories.

| Target | GPT runs | Claude runs |
| --- | --- | --- |
| AITranscribe + AITranscribeBackend | Bug fixes | Features |
| Alarm | Bug fixes | Features |
| web-browser | Bug fixes | Features |
| WifiAnalyzer | Bug fixes | Features |
| AppPlatform | Review and improvements | Skipped |
| CoreUtils | Review and improvements | Skipped |

## Run mode

The coordinator's model family sets the mode for the whole invocation, and loop threads inherit that model.

- **GPT run:** start only bug-fix and review-and-improvement loops, never feature loops. Every review in the run uses the review skill with only its GPT reviewer.
- **Claude run:** start only feature loops, never bug-fix or review-and-fix loops. Each feature's final review uses the review skill with both its Claude and GPT reviewers.

If the coordinator's model is neither GPT nor Claude, stop and report that the run mode is undefined.

AITranscribe and AITranscribeBackend form one paired target: every loop on it owns both repositories. Its review-and-fix loops cover both repositories, and its feature loops choose features for the AITranscribe app only. A feature loop expands the backend only when its app feature needs that, and never develops a standalone backend feature. Availability checks, claims, and the coordinator's claim watcher apply to each repository of the pair, and the pair is available only when both repositories are. The loop thread starts in the AITranscribe checkout and works in the AITranscribeBackend checkout by its resolved path.

Use [review](../review/SKILL.md) for every bug-fix or review-and-fix loop. Also use it for the final review of each feature. Select its reviewers by run mode. AppPlatform and CoreUtils permit bug fixes and worthwhile review improvements, including refactoring, without new feature development.

## Repository availability

Apply these checks before launching a loop. The loop thread must repeat them before inspecting implementation files or running repository commands beyond availability checks.

1. Resolve the checkout's real path, Git common directory, and repository identity. Treat other worktrees, symlinks, and separately registered checkouts of the same repository as the same target.
2. Inspect the available agent/session inventory. In T3, paginate `t3_project_list` to map projects, and `t3_thread_list` with `allProjects: true` and `includeSubagents: true` to find activity. Match projects by canonical path and repository identity, not just title. Include preparing, queued, starting, running, and waiting threads. Read ambiguous threads to establish their checkout and any pending work. Check available session/process ownership metadata for agents outside T3 as well.
3. Skip the entire target if another agent has active or pending work in any of its repositories, even in another worktree or on different files. Another loop's repository claim or an ownership lock also makes it unavailable. On repeat checks, recognize only this loop's matching ownership token as its own claim. A clean Git status or absence of a claim does not establish that the repository is idle. If activity cannot be established reliably, skip it and report the uncertainty.
4. Exclude only this invocation's coordinator, which performs orchestration without repository work, and the loop thread currently performing the check. All other agents, including other loops from this invocation, count as competing activity.
5. Require a clean checkout before starting. Skip existing staged, unstaged, or untracked changes rather than adopting, stashing, or discarding them.

After passing the checks, the loop thread must claim each repository of its target with an atomic `mkdir` of `burn-tokens.lock` inside that repository's resolved Git common directory. Claim a paired target's repositories in alphabetical order, and if any claim fails, release the claims already taken. Record its thread ID, invocation ID, and a unique ownership token inside each claim directory. This coordinates burn-tokens invocations across worktrees; it does not replace the agent inventory checks. If creation fails or a claim already exists, skip the target. Do not steal or expire another claim based on its age.

Recheck activity after acquiring the claim and before editing, running verification, and committing. If a competing agent appears, stop repository work, preserve all changes, and report the collision. On completion or interruption, remove only claims whose ownership token matches this loop. Never clear another agent's lock. An interrupted claim with uncertain ownership requires investigation rather than automatic removal.

## Coordinator

The invoking thread coordinates work. It does not implement changes itself.

1. Honor any repository selection, priorities, time limit, token budget, or loop count supplied with the invocation. Count in-flight loops toward a loop limit and pass an absolute deadline to workers for a time limit. Divide an explicit token budget among concurrent loops only when the runtime can enforce or measure it. If a requested limit cannot be enforced or measured, stop and report the limitation rather than proceeding without it. A run requires a loop count, time limit, or enforceable token budget. Without one, ask the user for a limit before launching anything. Do not invent a token budget or claim access to the user's remaining subscription quota.
2. Track each target's last loop, result, commits, verification, deferred decisions, and reason for skipping. Rotate among available targets so a single app does not monopolize the run. In a GPT run, run full-project review-and-fix loops on a target until a review finds nothing worthwhile, then treat that target as exhausted. In a Claude run, run only feature loops on the four app targets.
3. Select an available target and resolve its T3 project by the exact checkout path. For the paired target, use the AITranscribe checkout. If the existing checkout is not registered, register that folder using `t3_project_create` with an explicit `workspaceRoot` and `createWorkspaceRootIfMissing: false`.
4. Start a **new top-level T3 thread for every loop** using `t3_thread_launch`. Pass the target `projectId` and `workspaceStrategy: { type: "root" }` so the thread starts in the correct `~/Coding` repository. Use one retained `clientRequestId` for a launch and any uncertain retry. Inherit the current model and execution permissions. Do not reuse an old loop thread, use a delegate as its replacement, or create worktrees to bypass a busy repository.
5. Give the new thread a self-contained brief containing the target, run mode, loop mode, review reviewers, invocation ID, coordinator thread ID, remaining limits, relevant prior results, and the contents of [loop-thread.md](references/loop-thread.md). Include the resolved paths to this skill and the review skill. The new thread executes its assigned loop without recursively invoking the coordinator or launching another loop.
6. After launching, end the run immediately when it will launch no more loops: the loop count is used up by launched loops, or no target can take another loop. Loop threads enforce their own deadline, release their own claims, and report in their own threads, so the coordinator does not wait for them.
7. Wait only when a later launch is still possible, such as a loop count larger than the available targets or a time limit with time left. Then wait on a claim watcher instead of polling:
   - Start a background Bash command (`run_in_background`, `timeout: 3600000`). Every 60 seconds it checks the `burn-tokens.lock` directory in the Git common directory of each repository with an in-flight loop. It exits only when one of those claims is missing, because a missing claim means the loop finished or never started. Skip a repository's check until 10 minutes after its loop launched, so the loop has time to claim it. A newly appearing claim never wakes the coordinator. Write each path out explicitly, because zsh does not word-split unquoted variables.
   - Register the command with `t3_background_wait` so this thread shows as waiting, then end your turn. If `t3_background_wait` is unavailable, run the same watcher in the foreground with the longest allowed timeout instead.
   - Do not call `t3_thread_wait` repeatedly, read loop progress, or create timers.
   - On a claim wake, read only the finished loop's final result, launch the next loop if the limits allow, and then apply step 6 again. On a timeout wake, re-arm without reading threads. At most once an hour, make one `t3_thread_list` call to catch loops that stopped without releasing their claim.

   A loop waiting for a user answer is still in flight. The user answers it in that loop's thread, so it does not wake the coordinator.
8. Different idle repositories may run concurrently when capacity allows. Never have two loops in flight for the same repository, including a repository that belongs to the paired target. Check availability again before each launch, including repeat loops.

## Loop scope

- A feature loop selects and completes one coherent feature in an eligible app, including its review and fixes. Selection should follow documented product direction, known user needs, and gaps in existing workflows. Explain the user benefit and chosen scope before editing. Preserve applicable feature-selection and clarification requirements; defer work that needs an unresolved product decision rather than inventing behavior.
- A bug-fix or review-and-fix loop invokes the review skill in full-project mode within the target's authorized scope. Follow its review, fix, verify, commit, and resume procedure and its stopping rule. Do not replace it with a separate review checklist. Respect invocation limits and repository ownership throughout the pass.
- A feature loop's final review covers its own change, so do not schedule a follow-up review loop after it. AppPlatform and CoreUtils remain limited to their table entries.

## Stopping and reporting

Continue while eligible repositories have worthwhile work. Spending tokens is the opportunity, not a reason to invent defects, add filler features, churn code, or repeat clean reviews of unchanged code.

Stop launching at the user's limit or stop request, when every target is busy, blocked, unavailable, or exhausted, or when a complete rotation produces no worthwhile work that can proceed. In a GPT run, a review with no worthwhile findings completes that target, which waits until relevant code or requirements change. Do not poll busy repositories or manufacture work to keep the run alive.

Reaching a loop count or time limit only stops new launches. Loops already running finish on their own or stop at their deadline. On an explicit user stop request, safely stop the loop threads started by this invocation and their delegates, preserve unfinished changes, and release their claims only after their work has stopped. Use `t3_thread_interrupt` for these top-level loop threads and `task_cancel` for their delegates. Do not interrupt unrelated agents. Do not create recurring schedules under this invocation, and stop the claim watcher before the final handoff.

Report each created thread's returned link with its target and mode, and skipped repositories with reasons. For loops that finished while the coordinator was still running, also report commits and verification, remaining changes and blockers, and distinguish a clean completed review from an incomplete or unverified pass.
