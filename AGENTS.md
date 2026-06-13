# Global Preferences

## Shared

- Treat this file as a living preference profile and keep it updated frequently.
- Always add a "why" comment when code does something non-obvious, e.g. a constant that always returns a fixed value, a deliberate no-op, or a workaround for an external constraint.
- When the user states a stable cross-project preference, update global instructions immediately.
- Keep project-specific rules in project config files, not in global instructions.
- Do not duplicate global preferences in project AGENTS files unless a project-specific override is intentional.
- When adding new preferences, put them in a dedicated section when possible instead of growing `Shared`.
- Prefer inline one-off handlers and simple local logic over extracting small helper functions.
- Prefer robust, explicit systems over convenience shortcuts.
- Prefer compile-time enforcement when possible.
- If compile-time enforcement is not possible, fail fast during testing (assertion), never silently default.
- Never crash in production code paths; avoid `preconditionFailure`/`fatalError` for runtime data handling.
- Avoid hidden fallback behavior and implicit semantics.
- Avoid optional parameters where `nil` carries implicit semantic meaning.
- Default arguments are fine when the default is explicit and unambiguous.
- Avoid optional-driven API semantics where explicit alternatives exist.
- For compiler/tooling diagnostics during prototyping, prefer strict warnings without `-Werror`; only escalate warnings to errors when explicitly requested.
- Bias toward caution over speed for non-trivial work; use judgment for trivial tasks.

## Defaults And Fallbacks

- Never use preview, sample, test, mock, fixture, or generated demo data as a default argument or implicit fallback in production APIs; require the caller to pass the real value explicitly and keep fixtures inside preview/test-only code.

## Clarification and Tradeoffs

- Default to asking one concise clarifying question when the next step would require choosing unstated behavior, architecture, UX, scope, or priorities.
- State assumptions explicitly before implementation when they affect behavior, architecture, or scope.
- Do not invent or initialize application state values to make behavior work; ask when a needed state value is missing unless the requested behavior defines an explicit fallback.
- If multiple plausible interpretations exist, ask or present options instead of silently choosing one.
- Do not hide uncertainty by making assumptions just to keep moving; proceed without asking only when the assumption is low-risk, reversible, and stated clearly.
- Surface meaningful tradeoffs and push back when a simpler or safer approach exists.
- If unclear information blocks correct implementation, stop and ask before editing.

## User-Facing Copy

- UI/product copy must read like production text for end users, never like a response to a developer, implementation note, roadmap entry, or vibecoding artifact.
- Before shipping UI strings, reject wording that exposes implementation intent, internal scope management, framework internals, scaffolding, temporary status, or project-management workflow.
- Do not ship phrases like "This feature intentionally...", "Keep the declared scope aligned...", "declared service types", "curated set", "manager is/manager collects/manager executes", "Network.framework did not...", "URLSession metrics", "App Store-safe public APIs", "Planned Workflow", "future regression", "the app now...", "now have their own...", "HomeKit-ish", "dev endpoints", "bounded pass", or "sample-window evidence".
- Avoid developer jargon in UI such as "heuristic", "heuristics", "heuristically", "view-scoped", "foundation", "scaffold", "implementation detail", and raw internal capability lists unless the product explicitly needs that technical detail.
- Prefer user-centered production wording such as "checks are running", "route details are unavailable", "estimated", "approximate", "common services", "repeated samples", and "details".
- If a UI string sounds like a commit message, technical caveat, future-developer instruction, or internal plan, remove it or rewrite it before considering the task complete.

## Shared Instances

- For singleton/shared dependencies (e.g. `UserDefaults.standard`, `Foo.shared`), do not inject, wrap, or alias them; access the canonical shared instance directly at the use site.

## Function Structure

- Prefer inline local logic over introducing new helper functions.
- Inline helpers that have only one caller; when structure still helps readability, prefer a local nested function inside the caller, e.g. `func outer() { func inner() { ... }; inner() }`.
- When a new function's role could be mistaken for an API entrypoint instead of a private helper, inline it unless reuse clearly justifies extraction.
- Do not add pass-through helpers or computed properties that only rename existing data or restate enum state without adding real semantic value; prefer direct use and direct comparisons at the call site, e.g. `foo.status == .pending` instead of a thin `isPending` wrapper.
- Do not add count-only helpers such as `fooCount { foos.count }`; use the collection and `.count` directly at the call site.

## State Modeling

- When a UI path should be impossible by construction, do not add a user-facing fallback branch just to satisfy control flow; model the presentation state explicitly and use `assertionFailure` at the invalid transition point so impossible states are caught during development.

## Editing Scope

- Touch only the files and lines needed to satisfy the request; do not refactor, reformat, or clean up adjacent code unless required.
- Match the existing style, naming, and structure even when a different style would be preferred.
- Remove imports, variables, functions, and files that your own changes made unused; leave pre-existing dead code alone unless asked.
- Every changed line should have a clear connection to the user's request.

## Diagnostic Scope

- When the user provides exactly one compiler, lint, test, CI, or file/line diagnostic, treat that diagnostic as the entire requested scope unless they explicitly ask to continue beyond it.
- Fix only the provided diagnostic. Do not fix additional unrelated diagnostics discovered during verification, even when the fix appears obvious.
- If verification reveals unrelated failures, report them as blockers or residual failures and stop without editing those code paths.
- Do not infer permission to fix follow-up errors from having run a broader build, lint, or test command.

## Planning

- For any non-trivial task (roughly 3+ steps or any architectural decision), enter plan mode before implementation.
- Write detailed specs up front, including implementation and verification approach, to reduce ambiguity.
- Define success criteria before implementation; turn vague requests into verifiable outcomes.
- For multi-step plans, include a verification check for each major step.
- Treat verification as part of the plan, not as a final cleanup step.
- If something goes sideways or the plan no longer matches the facts, stop immediately and re-plan before continuing.

## Subagents

- Use subagents liberally for exploration, research, focused analysis, and parallel investigation to keep the main context clean.
- Give each subagent one tack or question so its scope stays narrow and results stay easy to apply.
- For complex problems, prefer spending extra parallel analysis up front over muddling through in the main context.

## Task Management

- For non-trivial work, write a checkable plan to `/tmp/tasks/<project-name>/todo.md` before implementation starts.
- Sanity-check the plan before coding, keep `/tmp/tasks/<project-name>/todo.md` updated as items progress, and mark items complete as soon as they are done.
- Record short high-level progress notes and add a review/results section to `/tmp/tasks/<project-name>/todo.md` before declaring success.

## Solution Quality

- Keep changes as small and local as possible while still addressing the real root cause.
- Implement only the requested scope; do not add speculative features, configurability, or abstractions for one-off code.
- Prefer simplification that deletes indirection over adding new abstraction layers that mostly relocate branching without reducing total complexity.
- For non-trivial changes, pause and ask whether there is a more elegant solution before settling on the first workable approach.
- If a fix feels hacky, step back and implement the cleaner solution with the current understanding.
- Do not over-engineer simple, obvious fixes.
- Do not add defensive handling for states that should be impossible by construction; make the invariant explicit and catch violations in development or tests.

## Verification

- Never mark a task complete without proving the result works.
- Diff behavior against `main` or the prior implementation when that comparison is relevant.
- Run appropriate tests, inspect logs, and otherwise demonstrate correctness before handing off.
- When verification for a requested fix or implementation reveals unrelated build, test, or lint failures, do not fix them implicitly; ask the user what additional scope is allowed before editing unrelated code.
- Before presenting non-trivial work, ask whether the result would pass a staff-engineer review bar.

## Bug Fixing

- When given a bug report, failing CI signal, or broken test, investigate and fix it autonomously without routine hand-holding.
- Start from concrete evidence such as logs, errors, or failing tests, then trace to root cause.
- Prefer durable root-cause fixes over temporary patches.

## Language Preferences

- Load the relevant language skill before editing or discussing language-specific code. Keep durable language-specific preferences in `skills/`, not in this file.
