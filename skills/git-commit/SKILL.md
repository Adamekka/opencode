---
name: git-commit
description: When git commit.
---

# Git Commit

- Use concise Conventional Commit messages: `type(scope): summary` or `type: summary`.
- Choose exactly one type from this alphabetized list:

| Type       | Use for                                                      | Example                                               |
| ---------- | ------------------------------------------------------------ | ----------------------------------------------------- |
| `build`    | Build system, compiler, packaging, or artifact changes       | `build(ios): include dSYMs in release archives`       |
| `ci`       | Continuous integration and delivery configuration            | `ci: pin checkout action to an immutable commit`      |
| `deps`     | Dependency additions, removals, and version updates          | `deps: update swift-syntax to 600.0.1`                |
| `dev`      | Local development tooling and developer workflows            | `dev: add a command to reset the local database`      |
| `docs`     | Prose and reference documentation changes                    | `docs(api): explain pagination cursor behavior`       |
| `example`  | Code examples and sample project changes                     | `example(api): add a paginated request sample`        |
| `feat`     | New user-facing or externally observable behavior            | `feat(auth): add passkey sign-in`                     |
| `fix`      | Corrections to unintended behavior                           | `fix(sync): retry uploads after token refresh`        |
| `perf`     | Measurable performance improvements without behavior changes | `perf(search): skip decoding unchanged index entries` |
| `refactor` | Internal restructuring without behavior changes              | `refactor(cache): consolidate eviction decisions`     |
| `test`     | Test-only additions or corrections                           | `test(parser): cover escaped delimiters`              |

- Write the summary in lowercase imperative form, without a trailing period.
- Describe the concrete change, not the activity performed. Prefer `fix(sync): retain queued uploads after relaunch` over `fix: update sync code`.
- Include a scope only when it adds useful domain or component context.
- Use the `ui` scope for user interface layout, styling, and presentation changes.
- Omit generic or redundant scopes such as `project`, `app`, or `code`.
