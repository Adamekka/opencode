---
name: swift
description: Use when editing Swift files, configuring Swift projects, or discussing Swift implementation style.
---

# Swift Preferences

- Every Swift type should live in its own file.
- Organize Swift code by feature; within each feature, group files into `Views`, `ViewModels`, `Managers`, and `Models` folders as needed, and do not create those folders when they would be empty.
- When iterating over all cases of an enum, always use `CaseIterable` with `allCases`; never hardcode an array of cases.
- Prefer clear `MARK` grouping; avoid random extension placement.
- Prefer `MARK` sections in the main type file over splitting behavior into `Type+Feature.swift` extension files, unless there is a strong reason to split.
- Keep localization calls in the existing style (`"literal".localized(...)` on the same line as the literal).
- When Swift code imports `CoreUtils`, inspect the sibling dependency at `../CoreUtils` for the referenced implementation.
- When fixing intentional empty closure/block lint violations, use a comment placeholder instead of a dummy statement.
- After finishing a Swift task, run `swiftformat .` and `swiftlint` from repo root.
- Do not run formatting/linting early unless requested; run at task completion checkpoints.
