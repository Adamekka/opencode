# Global Preferences

- Treat this file as a living preference profile and keep it updated frequently.
- When the user states a stable cross-project preference, update global instructions immediately.
- Keep project-specific rules in project config files, not in global instructions.
- Prefer robust, explicit systems over convenience shortcuts.
- Prefer compile-time enforcement when possible.
- If compile-time enforcement is not possible, fail fast during testing (assertion), never silently default.
- Never crash in production code paths; avoid `preconditionFailure`/`fatalError` for runtime data handling.
- Avoid hidden fallback behavior and implicit semantics.
- Avoid optional parameters where `nil` carries implicit semantic meaning.
- Default arguments are fine when the default is explicit and unambiguous.
- Avoid optional-driven API semantics where explicit alternatives exist.

## Swift
- Prefer clear `MARK` grouping; avoid random extension placement.
- Keep localization calls in the existing style (`"literal".localized(...)` on the same line as the literal).
- Run formatter from repo root with `swiftformat .`.
- Do not run formatting early unless requested; run at agreed checkpoints.
