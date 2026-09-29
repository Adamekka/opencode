# Global Preferences

## Shared

- Always add a "why" comment when code does something non-obvious, e.g. a constant that always returns a fixed value, a deliberate no-op, or a workaround for an external constraint.
- Prefer inline one-off handlers and simple local logic over extracting small helper functions.
- Prefer compile-time enforcement when possible.
- When compile-time enforcement is not possible, use assertions to catch programmer-error invariant violations during development and testing; never silently default.
- Handle recoverable external input and runtime failures with an explicit modeled failure rather than intentionally terminating the process. Required startup configuration is separate and should fail fast with a clear diagnostic when missing.
- Avoid hidden fallback behavior and implicit semantics.
- Avoid optional parameters where `nil` carries implicit semantic meaning.
- Default arguments are fine when the default is explicit and unambiguous.
- Avoid optional-driven API semantics where explicit alternatives exist.
- For compiler/tooling diagnostics during prototyping, prefer strict warnings without `-Werror`; only escalate warnings to errors when explicitly requested.

## Instruction Maintenance

- Keep instructions focused on concrete preferences that change default model behavior. Omit generic reminders such as being thorough.
- Update the appropriate `AGENTS.md` when durable product goals, architectural principles, quality requirements, development responsibilities, or user preferences become clear.
- Keep instructions implementation-independent. Record enduring direction rather than transient status, completed feature lists, file locations, symbol names, or other details that will become stale as the implementation evolves.
- Do not use any `AGENTS.md` as a roadmap, changelog, architecture inventory, or substitute for code and user documentation.
- When the user states a stable cross-project preference, update global instructions immediately.
- Keep project-specific rules in project config files, not in global instructions.
- When the user provides durable, important project-specific information, record it in the project's local `AGENTS.md` so future agents can use it without asking the user again.
- Do not duplicate global preferences in project AGENTS files unless a project-specific override is intentional.
- When adding new preferences, put them in a dedicated section or a skill when possible instead of growing `Shared`.

## Defaults And Fallbacks

- Never use preview, sample, test, mock, fixture, or generated demo data as a default argument or implicit fallback in production APIs; require the caller to pass the real value explicitly and keep fixtures inside preview/test-only code.
- Required environment/configuration values and secrets must stay required. Do not convert them to optionals, hidden fallbacks, or recoverable runtime branches to avoid a crash; if the app cannot work without the value, preserve an explicit fail-fast path so operators see misconfiguration immediately.

## Clarification and Tradeoffs

- Ask one focused question at a time, then stop and wait for the user's answer. Use each answer to ask relevant follow-up questions until the important behavior and tradeoffs are resolved; do not treat one answer as permission to fill in the remaining decisions yourself.
- Do not begin implementation until the user explicitly approves the discussed direction or asks you to proceed. Summarizing the agreed direction and asking for approval is preferred when the discussion spans multiple decisions.
- These discovery rules override autonomy, persistence, planning, and implementation instructions whenever proceeding depends on the user's answers or approval.
- For vague action requests such as "fix tests", do not assume whether to change production code or tests; ask one concise question when either direction is plausible.
- Do not invent or initialize application state values to make behavior work. Ask when a required state value is missing unless the requested behavior defines an explicit fallback. Proceed without asking only when an assumption is low-risk, reversible, and stated clearly.

## User-Facing Copy

- Keep screens focused on content and actions. Avoid motivational taglines, redundant introductory headings, and filler empty-state titles; adjust layout and spacing when removing them.
- UI/product copy must read like production text for end users, never like a response to a developer, implementation note, roadmap entry, or vibecoding artifact.
- Avoid commit-message language, framework diagnostics, roadmap labels, informal implementation labels such as "HomeKit-ish", developer jargon such as "heuristic" or "scaffold", and raw internal capability lists unless users need that technical detail.

## Shared Instances

- For singleton/shared dependencies (e.g. `UserDefaults.standard`, `Foo.shared`), prefer accessing the canonical shared instance directly at the use site. Inject, wrap, or alias them only when a concrete testing, ownership, lifecycle, or behavioral requirement justifies it.

## Dependency Injection

- Introduce dependency injection when a concrete testing, ownership, lifecycle, or behavioral requirement justifies it, even for a single dependency. Dependency count alone does not justify the pattern; choose the smallest implementation that meets the requirement.
- For tests around a single seam, prefer the smallest explicit test-only seam over production-facing dependency-injection scaffolding.

## Function Structure

- Prefer keeping a helper with one production caller inside that caller as a local nested function when the language supports it and local placement keeps the behavior clear.
- Extract a one-caller helper when a concrete testing, ownership, lifecycle, or behavioral requirement, or a meaningful separation of responsibilities, justifies it. Do not extract helpers merely to shorten a caller or rename a trivial expression.
- For one-caller local nested helpers, do not add parameters just to pass values that are immediately available at the call site; prefer a parameterless helper that captures or computes those values itself unless a parameter is needed to preserve semantics.
- Prefer capturing invariant values over passing redundant arguments. Pass a value explicitly when the caller must control it for behavior or testing, including a timestamp captured once to keep an operation consistent.
- Inline trivial pass-through helpers and computed properties that only rename, forward, count, or restate existing data. Prefer direct expressions such as `foo.status == .pending` and `foos.count`.

## State Modeling

- When a UI path should be impossible by construction, do not add a user-facing fallback branch just to satisfy control flow; model the presentation state explicitly and use `assertionFailure` at the invalid transition point so impossible states are caught during development.
- Enforce invariants on the mandatory path data must pass through, preferably during construction or mutation; do not expose optional validation helpers that callers can forget to invoke.

## Editing Scope

- Touch only the files and lines needed to satisfy the request; do not refactor, reformat, improve adjacent code/comments, or clean up nearby code unless required.
- Remove imports, variables, functions, and files that your own changes made unused; leave pre-existing dead code and cleanup opportunities alone unless asked, and mention unrelated issues instead of changing them.

## Git Workflow

- Always use rebase rather than merge when integrating or updating branches; do not create merge commits.
- For automated dependency and version updates, use bot-created pull requests that rebase into the target branch only after required CI succeeds; never integrate untested updates automatically.
- When a request includes multiple independent pieces of work, split each completed piece into a separate commit as work progresses so each change remains easy to review; never include unrelated worktree changes.
- For independent fixes in a multi-task request, prefer assigning subagents separate Git worktrees so they can implement and commit in parallel; integrate completed work with rebase or cherry-pick rather than merge commits.

## CI Supply Chain

- Pin GitHub Actions to immutable full commit SHAs rather than mutable version tags, and include the corresponding release version in a trailing comment so updates remain secure and readable.

## System Packages

- On macOS, install a required system package when it is needed to complete or verify a task; prefer the existing package manager and avoid unrelated package changes.

## Diagnostic Scope

- When the user provides exactly one compiler, lint, test, CI, or file/line diagnostic, treat that diagnostic as the entire requested scope unless they explicitly ask to continue beyond it.
- If verification reveals unrelated failures, report them as blockers or residual failures and stop without editing those code paths.

## Error Presentation

- Present recoverable failures with concise, actionable, user-friendly messages in release builds.
- In debug builds, preserve the user-facing message and add the concrete underlying error details needed for development and physical-device diagnosis.
- Keep developer diagnostics out of release UI, and do not replace recoverable runtime failure handling with assertions.

## Planning

- Before each implementation step, run a planning phase: identify multiple viable approaches, list each approach's advantages and disadvantages, recommend one when appropriate, and ask the user which approach to implement before editing.
- For any non-trivial task (roughly 3+ steps or any architectural decision), enter plan mode before implementation.

## Reviews

- For every code review and final review of non-trivial implementation work, use the `call-another-model` skill to obtain independent perspectives from all configured external review models; verify every candidate finding directly before reporting or editing.

## Language Preferences

- Keep durable language-specific preferences in `skills/`, not in this file.
