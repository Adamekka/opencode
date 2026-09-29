---
name: language-convention-check
description: Use ONLY when the user asks for a language convention check.
---

# Language Convention Check

## Purpose

Check every line of code in scope only for compliance with conventions explicitly written in the applicable language skills.

This is not a general code review. Do not report bugs, security issues, architecture concerns, performance problems, test gaps, or personal style preferences unless an applicable language skill explicitly defines the matter as a convention.

## Read-Only Boundary

- Use only read-only inspection tools and non-mutating version-control commands. Never modify repository files or generated artifacts, including through formatting or generation commands.
- Report findings and convention-definition problems to the user; do not fix them.

## Convention Sources

- Treat explicit conventions in those language skills as the only basis for confirmed violations. When no applicable convention resolves inconsistent code patterns, show those patterns and report the undefined preference instead of choosing one or calling either a violation.
- Repository instructions may determine scope and process, but they are not language conventions for this check unless the applicable language skill explicitly incorporates them.
- If no language skill exists for an in-scope language, tell the user that the language has no defined convention source and do not invent one.
- If conventions within one applicable language skill contradict each other, or applicable language skills contradict each other for the same code, report the contradiction and do not choose a side.

## Method

1. Use the exact scope provided by the user.
2. Inventory all authored code files and languages in scope, excluding vendored dependencies, generated code, build output, caches, and other non-authored code unless the user explicitly includes them.
3. Load every applicable language skill and extract its explicit, checkable conventions.
4. Check every in-scope code line against every applicable convention, reading structural context where a convention concerns files, types, modules, or project organization.
5. Report only violations supported by a quoted or precisely identified convention, plus missing or contradictory convention definitions.

## Output

- Present the complete report as a numbered list, with each finding, convention-definition problem, and coverage summary as its own numbered item.
- Put confirmed convention violations first, grouped by language and convention.
- For each violation, include the file and line, identify the violated convention, and briefly explain the mismatch.
- Then list contradictions in the applicable convention sources.
- Then list missing language skills or undefined preferences encountered during the check.
- State the selected scope and summarize coverage with the number of authored code files checked and any exclusions.
