---
name: docs
description: When reading or writing project documentation, editing AGENTS.md, or recording durable project requirements and decisions.
---

# Docs

Keep project documentation in `docs/`, organized by feature in Markdown files.

## Reading

- Start with `docs/README.md` when present. Use its links and targeted searches to find the relevant feature documentation; read only what the task needs.
- Check existing documentation outside `docs/` when the project has not migrated. Reading documentation does not authorize creating files or reorganizing it.
- Follow the project's established source of truth, including external specifications. Ask about material contradictions instead of silently choosing a different decision.
- When documentation is stale, contradictory, duplicated, poorly organized or hard to use, say so explicitly to the user. Point to concrete problems and recommend a scoped cleanup, even when cleanup is outside the current task.

## Writing

- Create `docs/` when writing project documentation if it does not exist. Use descriptive feature names, such as `docs/campaigns.md` and `docs/keyword-research.md`.
- Update the existing feature file instead of adding another document for the same behavior. Split a large feature into a feature subdirectory when its distinct topics need separate files.
- Maintain `docs/README.md` as a concise index with links and short descriptions. Keep detailed requirements in their feature files.
- Give shared rules and formulas one home and link to them from feature documentation. Record feature-specific exceptions explicitly.
- Keep required entry points such as root `AGENTS.md` in their discoverable locations. Keep agent workflow instructions there and link to `docs/` for detailed product behavior. Preserve tool-required skill files, licenses and third-party documentation in their required locations.
- Document current agreed behavior. Preserve exact formulas, scope, failure states and evidence requirements; do not invent decisions or describe planned behavior as implemented.

## Migration

- Reorganize existing documentation when the user requests it. A scoped documentation edit does not authorize migrating unrelated files.
- Preserve unique requirements and decision provenance when consolidating. Remove duplicate text only after checking that the retained version covers its meaning and exceptions.
- Update links, relative paths and references that depend on moved files. Verify documentation coverage and local links before removing the original files.
- Preserve the project's authority and approval rules. A documentation migration does not authorize changing product behavior or external specifications.
