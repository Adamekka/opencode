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

## Planning

- For any non-trivial task (roughly 3+ steps or any architectural decision), enter plan mode before implementation.
- Write detailed specs up front, including implementation and verification approach, to reduce ambiguity.
- Treat verification as part of the plan, not as a final cleanup step.
- If something goes sideways or the plan no longer matches the facts, stop immediately and re-plan before continuing.

## Subagents

- Use subagents liberally for exploration, research, focused analysis, and parallel investigation to keep the main context clean.
- Give each subagent one tack or question so its scope stays narrow and results stay easy to apply.
- For complex problems, prefer spending extra parallel analysis up front over muddling through in the main context.

## Task Management

- For non-trivial work, write a checkable plan to `tasks/todo.md` before implementation starts.
- Sanity-check the plan before coding, keep `tasks/todo.md` updated as items progress, and mark items complete as soon as they are done.
- Record short high-level progress notes and add a review/results section to `tasks/todo.md` before declaring success.

## Solution Quality

- Keep changes as small and local as possible while still addressing the real root cause.
- For non-trivial changes, pause and ask whether there is a more elegant solution before settling on the first workable approach.
- If a fix feels hacky, step back and implement the cleaner solution with the current understanding.
- Do not over-engineer simple, obvious fixes.

## Verification

- Never mark a task complete without proving the result works.
- Diff behavior against `main` or the prior implementation when that comparison is relevant.
- Run appropriate tests, inspect logs, and otherwise demonstrate correctness before handing off.
- Before presenting non-trivial work, ask whether the result would pass a staff-engineer review bar.

## Bug Fixing

- When given a bug report, failing CI signal, or broken test, investigate and fix it autonomously without routine hand-holding.
- Start from concrete evidence such as logs, errors, or failing tests, then trace to root cause.
- Prefer durable root-cause fixes over temporary patches.

## C and C++

- Prefer Clang toolchains for C and C++ projects when the project supports them.

## JavaScript and TypeScript

- Always use Bun for package manager and script commands.

## Rust

- Every Rust type should live in its own file.
- In binary Rust projects, prefer `pub` over `pub(crate)` when both accomplish the same thing; use `pub(crate)` only when the narrower visibility meaningfully helps.

## Swift

- Every Swift type should live in its own file.
- Prefer `Manager` over `ViewModel` in Swift type naming; this applies to type names, not folder names.
- When iterating over all cases of an enum, always use `CaseIterable` with `allCases`; never hardcode an array of cases.
- Prefer clear `MARK` grouping; avoid random extension placement.
- Prefer `MARK` sections in the main type file over splitting behavior into `Type+Feature.swift` extension files, unless there is a strong reason to split.
- Avoid hardcoding dependencies inside types (e.g. `private let defaults = UserDefaults.standard`); prefer receiving dependencies via initializers, environment, or explicit injection to keep types testable and behavior explicit.
- Keep localization calls in the existing style (`"literal".localized(...)` on the same line as the literal).
- When fixing intentional empty closure/block lint violations, use a comment placeholder instead of a dummy statement.
- After finishing a Swift task, run `swiftformat .` and `swiftlint` from repo root.
- Do not run formatting/linting early unless requested; run at task completion checkpoints.
