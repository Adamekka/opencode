# Global Preferences

## Shared

- Always add a "why" comment when code does something non-obvious, e.g. a constant that always returns a fixed value, a deliberate no-op, or a workaround for an external constraint.
- Prefer compile-time enforcement when possible. When it is not possible, use assertions to catch programmer-error invariant violations during development and testing; never silently default.
- Handle recoverable external input and runtime failures with an explicit modeled failure rather than intentionally terminating the process.
- Avoid hidden fallback behavior and implicit semantics, including optional parameters or optional-driven APIs where `nil` carries implicit meaning and an explicit alternative exists. Default arguments are fine when the default is explicit and unambiguous.
- For compiler/tooling diagnostics during prototyping, prefer strict warnings without `-Werror`; only escalate warnings to errors when explicitly requested.

## Instruction Maintenance

- Keep instructions focused on concrete preferences that change default model behavior. Omit generic reminders such as being thorough.
- Keep instructions implementation-independent. Record enduring direction rather than transient status, completed feature lists, file locations, symbol names, or other details that will become stale as the implementation evolves. Do not use any `AGENTS.md` as a roadmap, changelog, architecture inventory, or substitute for code and user documentation.
- Use the `projects-docs` skill before editing `AGENTS.md` or recording durable project requirements and decisions; follow its placement rules. `AGENTS.md` holds agent workflow instructions and user preferences. When the user provides durable, important project-specific information, record it through that skill so future agents can find it without asking the user again.
- When the user states a stable cross-project preference, propose a global instruction update immediately. Before editing global `AGENTS.md` or any skill, explain the proposed change, ask for explicit permission, and wait for the user's approval.
- Put each rule in its narrowest home: project-specific rules in project config files, durable language-specific preferences in a language skill, and new global preferences in a dedicated section or skill instead of `Shared`. Do not duplicate global preferences in project `AGENTS.md` files unless a project-specific override is intentional.

## Ambition and ideas

- Be bold with ideas. Explore ambitious, unconventional, or potentially unsafe approaches instead of dismissing them out of caution; assess concrete risks and ways to address them.
- Be willing to "boil the ocean" when a broad solution could produce a better outcome. Explain the scope and tradeoffs instead of automatically shrinking the ambition.
- Apply this ambition to ideas and proposals. Edits still follow Editing Scope until the user approves the broader scope.

## API Evolution

- Welcome source-level API breaks when the compiler exposes the required caller migrations; do not add compatibility shims solely to keep existing callers compiling.
- Preserve runtime compatibility for production apps, including when they adopt an update. Preserve existing persisted data and protocols shared by app versions; any migration must keep production compatible throughout rollout.

## Defaults And Fallbacks

- Never use preview, sample, test, mock, fixture, or generated demo data as a default argument or implicit fallback in production APIs; require the caller to pass the real value explicitly and keep fixtures inside preview/test-only code.
- Required environment/configuration values and secrets must stay required. Do not convert them to optionals, hidden fallbacks, or recoverable runtime branches to avoid a crash; if the app cannot work without the value, fail fast at startup with a clear diagnostic so operators see misconfiguration immediately.
- Make misconfiguration loud. At startup, validate that related settings are complete and consistent with each other, such as credentials covering every app and environment the system accepts, not just that each value is present. When a misconfiguration can only surface at runtime, such as an external service rejecting credentials, report the underlying cause at error level with identifying context, and stop retrying permanent failures. Never hide the cause behind a generic warning or an endless retry loop.

## Clarification and Tradeoffs

- Ask one focused question at a time, then stop and wait for the user's answer. Use each answer to ask relevant follow-up questions until the important behavior and tradeoffs are resolved.
- Apply requested edits directly in the working tree instead of creating proposed copies or asking for draft approval. Use Git for review and recovery.
- These discovery rules override autonomy, persistence, planning, and implementation instructions whenever proceeding depends on the user's answers.
- For vague action requests such as "fix tests", do not assume whether to change production code or tests; ask one concise question when either direction is plausible.
- Do not invent or initialize application state values to make behavior work. Ask when a required state value is missing unless the requested behavior defines an explicit fallback. Proceed without asking only when an assumption is low-risk, reversible, and stated clearly.

## Implementation Workflow

- Write AI-assisted code in small, reviewable increments so the user can understand the changes and retain control over the code.
- Use the `review` skill for every code review and final review of non-trivial implementation work.

## Subagents

- Use subagents freely and proactively to parallelize exploration, investigation, review, and independent implementation work without waiting for a separate user request.

## Feature Selection

- When asked to choose or implement the "next feature" from an issue, checklist, or roadmap, inspect the next candidate, identify it by name, and clarify its scope one question at a time.
- Treat "I checked it", "next one", "move on", and newly checked items as directions to inspect the next candidate.

## User-Facing Copy

- Make screens self-explanatory through clear labels, controls, and layout. Do not rely on explanatory paragraphs to make the UI understandable; assume users will not read them.
- Keep screens focused on content and actions. Avoid motivational taglines, redundant introductory headings, and filler empty-state titles; adjust layout and spacing when removing them.
- UI/product copy must read like production text for end users, never like a response to a developer, implementation note, roadmap entry, or vibecoding artifact.
- Avoid commit-message language, framework diagnostics, roadmap labels, informal implementation labels such as "HomeKit-ish", developer jargon such as "heuristic" or "scaffold", and raw internal capability lists unless users need that technical detail.

## Dependency Injection

- For singleton/shared dependencies (e.g. `UserDefaults.standard`, `Foo.shared`), prefer accessing the canonical shared instance directly at the use site.
- Inject, wrap, or alias a dependency only when a concrete testing, ownership, lifecycle, or behavioral requirement justifies it, even for a single dependency. Dependency count alone does not justify the pattern; choose the smallest implementation that meets the requirement.
- For tests around a single seam, prefer the smallest explicit test-only seam over production-facing dependency-injection scaffolding.

## Function Structure

- Prefer inline one-off handlers and simple local logic over extracting small helper functions.
- Prefer keeping a helper with one production caller inside that caller as a local nested function when the language supports it and local placement keeps the behavior clear.
- Extract a one-caller helper when a concrete testing, ownership, lifecycle, or behavioral requirement, or a meaningful separation of responsibilities, justifies it. Do not extract helpers merely to shorten a caller or rename a trivial expression.
- For one-caller local nested helpers, do not add parameters just to pass values that are immediately available at the call site; prefer a parameterless helper that captures or computes those values itself unless a parameter is needed to preserve semantics.
- Prefer capturing invariant values over passing redundant arguments. Pass a value explicitly when the caller must control it for behavior or testing, including a timestamp captured once to keep an operation consistent.
- Inline trivial pass-through helpers and computed properties that only rename, forward, count, or restate existing data. Prefer direct expressions such as `foo.status == .pending` and `foos.count`.

## State Modeling

- When a UI path should be impossible by construction, do not add a user-facing fallback branch just to satisfy control flow; model the presentation state explicitly and use a debug assertion, such as Swift's `assertionFailure`, at the invalid transition point so impossible states are caught during development.
- Enforce invariants on the mandatory path data must pass through, preferably during construction or mutation; do not expose optional validation helpers that callers can forget to invoke.

## Editing Scope

- Touch only the files and lines needed to satisfy the request; do not refactor, reformat, improve adjacent code/comments, or clean up nearby code unless required.
- Remove imports, variables, functions, and files that your own changes made unused; leave pre-existing dead code and cleanup opportunities alone unless asked, and mention unrelated issues instead of changing them.

## Reuse

- Every formula and shared feature behavior used in multiple places must have one shared implementation. Reuse existing code or extract shared logic before adding another use; do not reimplement it separately for each feature or screen.

## Git Workflow

- Amending unpushed commits is fine and does not require additional approval.
- Always use rebase rather than merge when integrating or updating branches; do not create merge commits.
- When a request includes multiple independent pieces of work, split each completed piece into a separate commit as work progresses so each change remains easy to review; never include unrelated worktree changes.
- For independent fixes in a multi-task request, prefer assigning subagents separate Git worktrees so they can implement and commit in parallel; integrate completed work with rebase or cherry-pick rather than merge commits.

## CI Supply Chain

- Pin GitHub Actions to immutable full commit SHAs rather than mutable version tags, and include the corresponding release version in a trailing comment so updates remain secure and readable.
- For automated dependency and version updates, use bot-created pull requests that rebase into the target branch only after required CI succeeds; never integrate untested updates automatically.

## System Packages

- On macOS, install a required system package when it is needed to complete or verify a task; prefer the existing package manager and avoid unrelated package changes.

## Diagnostic Scope

- When the user provides exactly one compiler, lint, test, CI, or file/line diagnostic, treat that diagnostic as the entire requested scope unless they explicitly ask to continue beyond it.
- If verification reveals unrelated failures, report them as blockers or residual failures and stop without editing those code paths.

## Error Presentation

- Present recoverable failures with concise, actionable, user-friendly messages in release builds.
- In debug builds, preserve the user-facing message and add the concrete underlying error details needed for development and physical-device diagnosis.
- Keep developer diagnostics out of release UI, and do not replace recoverable runtime failure handling with assertions.

## T3 Code

- Before ending a turn while a background Bash command or Monitor you started is still running and you are waiting on it, call `t3_background_wait` with its task ID. A `delegate_task` child's "end your turn" instruction covers only that child, not background shell tasks.
