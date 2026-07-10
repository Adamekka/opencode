---
name: language-convention-check
description: Use ONLY when asks for language convention check.
---

# Language Convention Check

## Purpose

Check every line of code in scope only for compliance with conventions explicitly written in the applicable language skills.

This is not a general code review. Do not report bugs, security issues, architecture concerns, performance problems, test gaps, or personal style preferences unless an applicable language skill explicitly defines the matter as a convention.

## Read-Only Boundary

- Use only read-only inspection tools and non-mutating version-control commands.
- Never edit, format, generate, delete, rename, stage, commit, or otherwise modify repository files.
- Do not run commands that can rewrite source files or generated artifacts.
- Report findings and convention-definition problems to the user; do not fix them.

## Scope

- Respect an explicit user-provided scope over these defaults.
- Start by inspecting the working tree, including status, staged changes, unstaged changes, and diff size.
- If there is a lot of uncommitted code, focus the check on all uncommitted code files. Read unchanged surrounding code only when needed to determine whether an in-scope line follows a written convention.
- If there are no uncommitted changes, or only a few changed lines, check the whole repository rather than limiting the check to the small diff.
- Exclude vendored dependencies, generated code, build output, caches, and other non-authored code unless the user explicitly includes them.
- Inspect every line of authored code in the selected scope. Do not sample representative files or stop after finding initial violations.

## Convention Sources

- Identify every programming language present in the selected scope.
- Load the corresponding language skill for each identified language before evaluating its code.
- Treat explicit conventions in those language skills as the only basis for confirmed violations. Still identify inconsistent patterns in the code when no applicable convention defines which pattern is preferred; report those as undefined preferences rather than choosing a pattern or calling either one a violation.
- Repository instructions may determine scope and process, but they are not language conventions for this check unless the applicable language skill explicitly incorporates them.
- If no language skill exists for an in-scope language, tell the user that the language has no defined convention source and do not invent one.
- If an applicable language skill lacks a preference needed to resolve an observed inconsistency, show the conflicting patterns, report that the preference is not defined, and do not choose a preferred pattern.
- If conventions within one applicable language skill contradict each other, or applicable language skills contradict each other for the same code, report the contradiction and do not choose a side.

## Method

1. Determine the exact scope using the rules above.
2. Inventory all authored code files and languages in scope.
3. Load every applicable language skill and extract its explicit, checkable conventions.
4. Check every in-scope code line against every applicable convention, reading structural context where a convention concerns files, types, modules, or project organization.
5. Track coverage so no in-scope authored code file is skipped.
6. Report only violations supported by a quoted or precisely identified convention, plus missing or contradictory convention definitions.

## Output

- Put confirmed convention violations first, grouped by language and convention.
- For each violation, include the file and line, identify the violated convention, and briefly explain the mismatch.
- Then list contradictions in the applicable convention sources.
- Then list missing language skills or undefined preferences encountered during the check.
- State the selected scope and summarize coverage with the number of authored code files checked and any exclusions.
- If there are no confirmed violations, say so directly.
- Do not suggest unrelated improvements or silently expand the convention set.
