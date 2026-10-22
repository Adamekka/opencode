---
name: review
description: Review code and product changes. Use for requested reviews and final reviews of non-trivial implementation work.
---

# Review

## Review scope

- Honor the requested scope. For a diff review, trace affected callers and shared implementations as needed without turning it into a whole-project audit. Respect requests limited to a particular concern.
- In a general review, actively examine every applicable dimension below. Technical debt and product-quality problems are first-class findings even when the code works. Do not suppress them because correctness or security findings also exist.

## What to look for

- Correctness, security, performance, and tests that leave a concrete risk uncovered.
- Technical debt and architecture that create unnecessary coupling, indirection, complexity, or maintenance work. Explain the concrete problem and recommend a better design with its tradeoffs. Recommend removing or rewriting a feature when that is the better remedy.
- Convention drift from applicable instructions or established project patterns. Cite the convention and the conflicting implementation rather than presenting personal taste as a requirement.
- UI problems in visual hierarchy, layout, readability, consistency, and controls. Inspect the rendered interface when available; distinguish observed problems from concerns inferred from source.
- UX problems in task flows, discoverability, interaction feedback, loading and empty states, error recovery, and avoidable friction.
- Developer experience (DX) problems in APIs, diagnostics, configuration, builds, and tests that make ordinary development confusing or fragile.
- Accessibility (AX) barriers involving keyboard access, focus, accessible names and semantics, assistive technology, contrast, or text scaling. Explain the affected interaction and who it excludes.
- Duplicated formulas, behavior, or logic that should use an existing shared implementation or justify extracting one. Identify the repeated locations and the shared responsibility. Similar-looking code alone does not justify an abstraction.

## Evidence and judgment

- Support each finding with a specific location, concrete impact, and an actionable recommendation. A reproducible bug is not required; maintenance cost, convention drift, user friction, and accessibility barriers are valid impacts.
- Call out AI slop plainly when it causes concrete defects or needless complexity. Name the defect and why it matters; do not infer AI authorship from style alone.
- Verify assumptions against the implementation and applicable requirements. Do not invent findings to fill categories. State material limits on what was inspected or could be verified, especially for UI, UX, and AX.
- For every code review and final review of non-trivial implementation work, use [call-another-model](../call-another-model/SKILL.md) to obtain independent perspectives from all configured external review models. Include the applicable review dimensions in their prompt and verify every candidate finding directly before reporting or editing.

## Output

- Assign every finding a unique sequential number, starting at 1, and include that number in its heading or label.
- For each finding, state its category, priority based on impact, specific file/line references or UI location, concrete impact, and recommended improvement. Group repeated instances of the same underlying issue.
- For each finding, show implementation difficulty as `Low`, `Medium`, or `High`, considering the change's scope, risk, dependencies, and verification effort.
