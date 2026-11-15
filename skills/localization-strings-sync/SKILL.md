---
name: localization-strings-sync
description: When user asks to sync localization strings.
disable-model-invocation: true
---

# Localization strings sync

Run the bundled `scripts/genstrings.swift` and `scripts/syncstrings.swift` from this skill's directory, written below as `<skill-dir>`, instead of commands from PATH. They are executable Swift scripts; `genstrings` on PATH may be Apple's unrelated tool.

## Workflow

1. Identify the Swift source root to scan and the localization root that contains `en.lproj` plus sibling locale folders.
2. Regenerate the English baseline with `<skill-dir>/scripts/genstrings.swift <source-root> > <localization-root>/en.lproj/Localizable.strings`.
3. Run `<skill-dir>/scripts/syncstrings.swift <localization-root> en` to give sibling locale files the English key set, removing whole entries only when their keys no longer exist in English.
4. Translate `TODO` placeholders left by `syncstrings`, matching each locale's existing terminology and tone.
5. Verify every target locale matches the English key set. Run `<skill-dir>/scripts/syncstrings.swift <localization-root> en` a second time; it should report zero updated files.
6. Commit the localization changes in the Git repository containing the localized strings using [git-commit](../git-commit/SKILL.md). Use the exact subject `locale`, which overrides that skill's Conventional Commit subject format, and keep its `Author` model trailer. Include only localization changes from this sync.

## Guardrails

- Do not manually add `TODO` placeholders or remove stale keys in target locales when `syncstrings` can do it.
- Do not change existing non-`TODO` target translations that still correspond to English keys; `syncstrings` preserves those raw values.
- Call out translations that need native-speaker review.
