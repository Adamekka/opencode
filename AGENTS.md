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
