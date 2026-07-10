---
name: swift
description: When Swift.
---

# Swift Preferences

- Every Swift type should live in its own file.
- Prefer `struct` for Swift utility and value types unless identity, inheritance, or reference semantics are required.
- Organize Swift code by feature; within each feature, group files into `Views`, `ViewModels`, `Managers`, and `Models` folders as needed, and do not create those folders when they would be empty.
- When iterating over all cases of an enum, always use `CaseIterable` with `allCases`; never hardcode an array of cases.
- Prefer clear `MARK` grouping; avoid random extension placement unless it's used for visibility.
- Prefer `MARK` sections in the main type file over splitting behavior into `Type+Feature.swift` extension files, unless there is a strong reason to split.
- Keep localization calls in the existing style (`"literal".localized(...)` on the same line as the literal). When a localized string needs runtime values, use a full localized format string with `String(format: "literal %@".localized(...), value)` rather than string interpolation or concatenating localized fragments.
- In `@Observable` classes, when a property needs `UserDefaults`-backed storage, use `@ObservableUserDefault` instead of direct `UserDefaults` access.
- When Swift code imports `CoreUtils`, inspect the sibling dependency at `../CoreUtils` for the referenced implementation.
- When fixing intentional empty closure/block lint violations, use a comment placeholder instead of a dummy statement.
- Treat SwiftLint rules as strong defaults. When following a rule would make a specific correct implementation less clear or less safe, prefer the clearer code and disable that rule locally at the smallest practical scope; do not add awkward structure just to satisfy lint.
- For protocol witness methods, do not assume the implementation must repeat `async` or `throws` from the requirement. If the body does not `await` or throw, first try a synchronous and/or non-throwing witness instead of adding `async_without_await`, `unused_parameter`, or `unneeded_throws_rethrows` disables.
- After finishing a Swift task, run `swiftformat .` and `swiftlint` from repo root.
- Do not run formatting/linting early unless requested; run at task completion checkpoints.
