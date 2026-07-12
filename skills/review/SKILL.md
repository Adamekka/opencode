---
name: review
description: When user asks for review.
---

# Review Skill

## Scope

- Start by inspecting the working tree: status, staged diff, unstaged diff, and diff size.
- If there is a lot of uncommitted code, assume the user is working on a feature and review the feature represented by those changes. Read surrounding code as needed to understand behavior and project conventions, but keep findings tied to the feature scope unless the user asks for a broader review.
- If there are only a few changed lines or no uncommitted changes, treat the scope as the whole program. Review architecture, project structure, and representative critical paths instead of only the tiny diff.
- When implementing fixes from a whole-program review, put each independent fix or tightly related group of fixes on a separate branch based on the original review base so the fixes can be reviewed independently.
- Respect any explicit scope from the user over the default scope rules above.

## Review Focus

- Security: authentication, authorization, secrets, injection, XSS, CSRF, SSRF, path traversal, unsafe deserialization, insecure crypto, permission boundaries, dependency and supply-chain risk, and sensitive data exposure.
- Bugs and correctness: edge cases, data loss, invalid state transitions, concurrency, lifecycle, persistence, migrations, API contracts, error handling, nullability, localization, time, resource cleanup, and test coverage gaps.
- Technical debt: unnecessary complexity, fragile abstractions, duplicated logic, unclear ownership, hard-to-test code, hidden fallback behavior, implicit semantics, over-broad interfaces, dead code introduced by the change, naming drift, and maintainability risks.
- Project fit: follow the repository's existing structure, language idioms, naming, test patterns, configuration style, and dependency boundaries. Flag code that solves the problem but does not fit the project's conventions.

## Method

- Build enough context before judging: read project instructions, load relevant language skills, inspect changed files, and sample nearby established patterns.
- For feature reviews, infer intended behavior from changed tests, docs, call sites, and surrounding code. If the intent is still ambiguous, list the ambiguity as an open question instead of guessing.
- Prefer concrete, actionable findings over broad advice. Tie each finding to a real consequence and a practical fix.
- Treat technical debt and convention drift as first-class review findings. Do not omit them just because there are also security or correctness concerns.
- Do not invent issues to fill categories. If no meaningful technical-debt findings exist, say that explicitly.

## Output

- Put findings first, ordered by severity. Include file and line references when available.
- Assign every finding a unique sequential number, starting at 1, and include that number in its heading or label.
- For each finding, state the issue, why it matters, and the smallest practical fix.
- Include open questions or assumptions after findings.
- Keep summaries brief and secondary to findings.
- If no findings are discovered, say so directly and mention residual risks or areas not verified.
