# Global Preferences

## Shared

- Always add a "why" comment when code does something non-obvious, e.g. a constant that always returns a fixed value, a deliberate no-op, or a workaround for an external constraint.
- Prefer inline one-off handlers and simple local logic over extracting small helper functions.
- Prefer robust, explicit systems over convenience shortcuts.
- Prefer compile-time enforcement when possible.
- When compile-time enforcement is not possible, use assertions to catch programmer-error invariant violations during development and testing; never silently default.
- Handle recoverable external input and runtime failures with an explicit modeled failure rather than intentionally terminating the process. Required startup configuration is separate and should fail fast with a clear diagnostic when missing.
- Avoid hidden fallback behavior and implicit semantics.
- Avoid optional parameters where `nil` carries implicit semantic meaning.
- Default arguments are fine when the default is explicit and unambiguous.
- Avoid optional-driven API semantics where explicit alternatives exist.
- For compiler/tooling diagnostics during prototyping, prefer strict warnings without `-Werror`; only escalate warnings to errors when explicitly requested.
- Bias toward caution over speed for non-trivial work; use judgment for trivial tasks.

## Instruction Maintenance

- Maintain this file as the user's cross-project preference profile and update it frequently.
- When the user states a stable cross-project preference, update global instructions immediately.
- Keep project-specific rules in project config files, not in global instructions.
- When the user provides durable, important project-specific information, record it in the project's local `AGENTS.md` so future agents can use it without asking the user again.
- Do not duplicate global preferences in project AGENTS files unless a project-specific override is intentional.
- When adding new preferences, put them in a dedicated section or a skill when possible instead of growing `Shared`.
- If an `AGENTS.md` rule is unclear, does not make sense, or conflicts with another rule, tell the user instead of silently accepting or adding it.

## Defaults And Fallbacks

- Never use preview, sample, test, mock, fixture, or generated demo data as a default argument or implicit fallback in production APIs; require the caller to pass the real value explicitly and keep fixtures inside preview/test-only code.
- Required environment/configuration values and secrets must stay required. Do not convert them to optionals, hidden fallbacks, or recoverable runtime branches to avoid a crash; if the app cannot work without the value, preserve an explicit fail-fast path so operators see misconfiguration immediately.

## Clarification and Tradeoffs

- For non-trivial work, discuss the problem, constraints, edge cases, and meaningful tradeoffs with the user before implementation.
- Ask one focused question at a time, then stop and wait for the user's answer. Use each answer to ask relevant follow-up questions until the important behavior and tradeoffs are resolved; do not treat one answer as permission to fill in the remaining decisions yourself.
- Do not begin implementation until the user explicitly approves the discussed direction or asks you to proceed. Summarizing the agreed direction and asking for approval is preferred when the discussion spans multiple decisions.
- These discovery rules override autonomy, persistence, planning, and implementation instructions whenever proceeding depends on the user's answers or approval.
- Ask one concise clarifying question when the next step requires choosing unstated behavior, architecture, UX, scope, priorities, or application state. If multiple interpretations are plausible, present them clearly instead of choosing silently.
- For vague action requests such as "fix tests", do not assume whether to change production code or tests; ask one concise question when either direction is plausible.
- Push back before making changes that would weaken code quality, lock tests to questionable behavior, or alter product behavior just to make tests pass.
- Before implementing, state assumptions explicitly when they affect behavior, architecture, UX, scope, or priorities.
- Do not invent or initialize application state values to make behavior work. Ask when a required state value is missing unless the requested behavior defines an explicit fallback. Proceed without asking only when an assumption is low-risk, reversible, and stated clearly.
- Do not guess current or external values such as latest versions, API shapes, or supported options; verify them against an authoritative source before using them.
- Surface meaningful tradeoffs, including simpler approaches, and push back when a safer or simpler path exists.
- If unclear information blocks correct implementation, explain what is unclear and stop before editing.

## Pushback

- Push back directly when a request would produce brittle, misleading, unsafe, unnecessarily complex, low-quality, or internally inconsistent results; do not silently comply just because the request is technically possible.
- Challenge flawed premises before acting: state what is wrong, why it matters, and what safer or simpler alternative you recommend.
- State substantive disagreement plainly. When a request conflicts with repository instructions, global preferences, product quality, tests, security, privacy, or maintainability, ask whether to accept the tradeoff only when the user appears to be making it deliberately.

## User-Facing Copy

- UI/product copy must read like production text for end users, never like a response to a developer, implementation note, roadmap entry, or vibecoding artifact.
- Before shipping UI strings, reject wording that exposes implementation intent, internal scope management, framework internals, scaffolding, temporary status, or project-management workflow.
- Avoid commit-message language, framework diagnostics, roadmap labels, informal implementation labels such as "HomeKit-ish", developer jargon such as "heuristic" or "scaffold", and raw internal capability lists unless users need that technical detail.
- Prefer user-centered wording that describes current status, availability, estimates, and details in the product's terminology.
- If a UI string sounds like a commit message, technical caveat, future-developer instruction, or internal plan, remove it or rewrite it before considering the task complete.

## Shared Instances

- For singleton/shared dependencies (e.g. `UserDefaults.standard`, `Foo.shared`), do not inject, wrap, or alias them; access the canonical shared instance directly at the use site.

## Dependency Injection

- Do not introduce dependency-injection patterns for a single dependency; call the concrete or shared dependency directly at the use site.
- Introduce dependency injection only when multiple dependencies or a concrete architectural need justify the pattern; otherwise choose the smaller, more direct implementation.
- For tests around a single seam, prefer the smallest explicit test-only seam over production-facing dependency-injection scaffolding.

## Function Structure

- If a helper has only one production caller, keep it inside that caller as a local nested function, e.g. `func outer() { func inner() { ... }; inner() }`, unless it is an explicit API/protocol/framework entrypoint.
- Do not promote one-caller helpers to type-level private functions for readability, organization, test convenience, naming, or to make a caller shorter.
- For one-caller local nested helpers, do not add parameters just to pass values that are immediately available at the call site; prefer a parameterless helper that captures or computes those values itself unless a parameter is needed to preserve semantics.
- Do not pass invariant or always-the-same arguments such as the current date/time into helpers; have the callee compute or capture that value directly unless the caller truly needs to choose a different value.
- Keep type-level functions separate only when required as an API/protocol/framework entrypoint, used by multiple real production call sites, recursive, or impossible to represent as a local nested function without changing semantics.
- Inline trivial pass-through helpers and computed properties that only rename, forward, count, or restate existing data. Prefer direct expressions such as `foo.status == .pending` and `foos.count`.

## State Modeling

- When a UI path should be impossible by construction, do not add a user-facing fallback branch just to satisfy control flow; model the presentation state explicitly and use `assertionFailure` at the invalid transition point so impossible states are caught during development.
- Enforce invariants on the mandatory path data must pass through, preferably during construction or mutation; do not expose optional validation helpers that callers can forget to invoke.

## Editing Scope

- Touch only the files and lines needed to satisfy the request; do not refactor, reformat, improve adjacent code/comments, or clean up nearby code unless required.
- Match the existing style, naming, and structure even when a different style would be preferred.
- Remove imports, variables, functions, and files that your own changes made unused; leave pre-existing dead code and cleanup opportunities alone unless asked, and mention unrelated issues instead of changing them.
- Every changed line should have a clear connection to the user's request.

## Git Workflow

- Always use rebase rather than merge when integrating or updating branches; do not create merge commits.
- During multi-fix implementation work, create small commits for completed independent fixes as work progresses so each change remains easy to review; never include unrelated worktree changes.
- For independent fixes in a multi-task request, prefer assigning subagents separate Git worktrees so they can implement and commit in parallel; integrate completed work with rebase or cherry-pick rather than merge commits.

## CI Supply Chain

- Pin GitHub Actions to immutable full commit SHAs rather than mutable version tags, and include the corresponding release version in a trailing comment so updates remain secure and readable.

## System Packages

- On macOS, install a required system package when it is needed to complete or verify a task; prefer the existing package manager and avoid unrelated package changes.

## Diagnostic Scope

- When the user provides exactly one compiler, lint, test, CI, or file/line diagnostic, treat that diagnostic as the entire requested scope unless they explicitly ask to continue beyond it.
- Fix only the provided diagnostic. Do not fix additional unrelated diagnostics discovered during verification, even when the fix appears obvious.
- If verification reveals unrelated failures, report them as blockers or residual failures and stop without editing those code paths.
- Do not infer permission to fix follow-up errors from having run a broader build, lint, or test command.

## Planning

- Before each implementation step, run a planning phase: identify multiple viable approaches, list each approach's advantages and disadvantages, recommend one when appropriate, and ask the user which approach to implement before editing.
- For any non-trivial task (roughly 3+ steps or any architectural decision), enter plan mode before implementation.
- State a brief plan before multi-step work, including assumptions and verification for each major step; use detailed specs when ambiguity or architecture warrants it.
- Define concrete success criteria before implementation; turn vague requests into verifiable outcomes before coding.
- Treat verification as part of the plan, not as a final cleanup step.
- If new facts invalidate the approved plan, stop immediately and re-plan before continuing.

## Subagents

- Use subagents liberally for exploration, research, focused analysis, and parallel investigation to keep the main context clean.
- Give each subagent one tack or question so its scope stays narrow and results stay easy to apply.
- For complex problems, prefer additional parallel analysis before implementation over incomplete sequential investigation.

## Reviews

- For every code review and final review of non-trivial implementation work, use the `call-another-model` skill to obtain independent perspectives from all configured external review models; verify every candidate finding directly before reporting or editing.

## Task Management

- For non-trivial work, write a checkable plan to `/tmp/tasks/<project-name>/todo.md` before implementation starts.
- Sanity-check the plan before coding, keep `/tmp/tasks/<project-name>/todo.md` updated as items progress, and mark items complete as soon as they are done.
- Record short high-level progress notes and add a review/results section to `/tmp/tasks/<project-name>/todo.md` before declaring success.

## Solution Quality

- Write the minimum code that solves the requested problem while still addressing the underlying cause.
- Implement only the requested scope; do not add speculative features, configurability, or abstractions for one-off code.
- Prefer simplification that deletes indirection over adding new abstraction layers that mostly relocate branching without reducing total complexity.
- For non-trivial changes, verify that each new abstraction is necessary and simplify avoidable indirection before continuing.
- If a fix relies on a brittle workaround, step back and implement the cleaner solution supported by the current understanding.
- Do not add defensive handling for states that should be impossible by construction; make the invariant explicit and catch violations in development or tests.

## Verification

- Never mark a task complete or hand it off without proving the result works against the defined success criteria.
- Diff behavior against `main` or the prior implementation when that comparison is relevant.
- Run appropriate tests, inspect logs, and otherwise demonstrate correctness before handing off; loop on requested-scope failures until verified.
- When verification for a requested fix or implementation reveals unrelated build, test, or lint failures, do not fix them implicitly; ask the user what additional scope is allowed before editing unrelated code.
- Before presenting non-trivial work, inspect the final diff for correctness, requested scope, unnecessary complexity, and adequate verification.

## Bug Fixing

- When given a bug report, failing CI signal, or broken test, investigate and fix it autonomously without routine hand-holding.
- Start from concrete evidence such as logs, errors, or failing tests, then trace to root cause.
- Prefer durable root-cause fixes over temporary patches.

## Language Preferences

- Load the relevant language skill before editing or discussing language-specific code. Keep durable language-specific preferences in `skills/`, not in this file.
