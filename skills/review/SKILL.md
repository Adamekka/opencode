---
name: review
description: Review changes, features, or full projects and fix verified findings. Use for requested reviews and final reviews of non-trivial implementation work.
---

# Review

## Review scope

- Honor the requested scope. For a diff review, trace affected callers and shared implementations as needed without turning it into a whole-project audit. Respect requests limited to a particular concern.
- Fix verified findings directly. Ask only when a user decision is needed.
- Treat behavior-preserving refactoring opportunities as valid findings even when current behavior is correct. Suggest them within the requested review scope and implement them only within the user's authorized implementation scope.
- In either mode, actively examine every applicable dimension below within the requested scope.

## Review modes

### Change or feature review

- Review the requested change, feature, diff, or other bounded scope, fix all verified findings, and verify the fixes. The full project stopping rule does not apply.

### Full project review

1. Review the project. As soon as a finding is verified and worth fixing under the stopping rule below, stop reviewing further and fix it before looking for another issue.
2. Verify the fix, then commit it using [git-commit](../git-commit/SKILL.md). Keep the commit limited to that finding and exclude unrelated worktree changes.
3. Resume the project review. Repeat the review, fix, verify, and commit loop until a complete pass finds no remaining findings worth fixing.

- If a fix or commit is blocked by a required decision, approval, or failed verification, stop the loop and report the blocker. Do not claim the project review is complete.

### Full project stopping rule

- For full project reviews only, weigh each finding's likelihood and impact against the fix's effort and regression risk. Defer fixes whose expected benefit does not justify that cost, such as a one-in-a-million edge case with negligible impact. Rare failures with serious consequences may still be worth fixing; do not invent numerical odds without evidence.
- Continue the current review pass past deferred findings so a low-value edge case does not hide other issues. Once only findings below this threshold remain, stop fixing and report that only low-value findings remain, listing them and why they are not worth fixing. Distinguish this outcome from a review with no findings.

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
- For refactoring suggestions, explain the concrete cost of the current design, the expected benefit of the proposed change, and its tradeoffs and regression risk. Avoid refactorings justified only by personal taste or speculative future needs.
- Call out AI slop plainly when it causes concrete defects or needless complexity. Name the defect and why it matters; do not infer AI authorship from style alone.
- Verify assumptions against the implementation and applicable requirements. Do not invent findings to fill categories. State material limits on what was inspected or could be verified, especially for UI, UX, and AX.
- For every code review and final review of non-trivial implementation work, use [call-another-model](../call-another-model/SKILL.md) to obtain independent perspectives from all configured external review models. Include the applicable review dimensions in their prompt and verify every candidate finding directly before reporting or editing.

## Output

- Assign every finding a unique sequential number, starting at 1, and include that number in its heading or label.
- Explicitly label refactoring suggestions and distinguish them from defect fixes.
- For each finding, state its category, priority based on impact, specific file/line references or UI location, concrete impact, and implemented fix or remaining recommended improvement. Group repeated instances of the same underlying issue.
- For each finding, show implementation difficulty as `Low`, `Medium`, or `High`, considering the change's scope, risk, dependencies, and verification effort.
- Report verification results and any remaining blockers. For a full project review, also include deferred findings, the fix commits, and whether a complete pass found no remaining findings worth fixing.
