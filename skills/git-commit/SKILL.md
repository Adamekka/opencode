---
name: git-commit
description: When git commit.
---

# Git Commit

- Before committing, run the project's configured formatter and linter on the code being committed. Fix formatting and lint issues within the requested scope, then verify both checks pass on the final changes before committing.
- If either check fails or cannot run, report the blocker and do not commit. If the project has no formatter or linter configured, state which check is unavailable rather than silently skipping it.
- Use concise Conventional Commit messages: `type(scope): summary` or `type: summary`.
- Put commit metadata in a final Git trailer block, separated from the subject or body by a blank line, with no prose after it. Order `Author` before `Linear-Issue` when both apply.
- For commits made by AI, add an `Author: <exact-model-id>` trailer. Use the verified full model ID, preserving its version and variant, for example `Author: gpt-6.1-sol`. Family names such as `GPT-6` and product names such as `Codex` are insufficient.
- When the committed work belongs to a known Linear issue, add a `Linear-Issue: <issue-id>` trailer, for example `Linear-Issue: RIV-374`. Use the hyphenated key so Git recognizes it as a trailer. Omit it when no issue applies; never invent an issue ID.
- Determine the model from authoritative metadata for the executing session and turn. In local Codex, use `CODEX_THREAD_ID` to locate the matching rollout JSONL under `${CODEX_HOME:-$HOME/.codex}/sessions/`, confirm `session_meta.payload.id` matches that thread ID, and read `payload.model` from the latest `turn_context` record. Read only the needed metadata, without printing conversation contents or credentials. In other agents, use their equivalent current-session model metadata.
- Do not infer the model from a generic self-description, the available-model catalog, a review model, or a global configuration default; per-session and per-turn overrides can differ.
- If the exact executing model cannot be verified, ask the user for it before committing rather than guessing or using a broad family name.
- Choose exactly one type from this alphabetized list:

| Type | Use for |
| --- | --- |
| `build` | Build system, compiler, packaging, or artifact changes |
| `ci` | Continuous integration and delivery configuration |
| `deps` | Dependency additions, removals, and version updates |
| `dev` | Local development tooling and developer workflows |
| `docs` | Prose and reference documentation changes |
| `example` | Code examples and sample project changes |
| `feat` | New user-facing or externally observable behavior |
| `fix` | Corrections to unintended behavior |
| `locale` | Localized strings and translation resource changes |
| `perf` | Measurable performance improvements without behavior changes |
| `refactor` | Internal restructuring without behavior changes |
| `test` | Test-only additions or corrections |

- Write the summary in lowercase imperative form, without a trailing period.
- Use the `ui` scope for user interface layout, styling, and presentation changes.
- Omit generic or redundant scopes such as `project`, `app`, or `code`.
