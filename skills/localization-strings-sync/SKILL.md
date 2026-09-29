---
name: localization-strings-sync
description: When user asks to sync localization strings.
---

Use `genstrings` and `syncstrings` from PATH.

## Workflow

1. Identify the Swift source root to scan and the localization root that contains `en.lproj` plus sibling locale folders.
2. Regenerate the English baseline with `genstrings <source-root> > <localization-root>/en.lproj/Localizable.strings`.
3. Run `syncstrings <localization-root> en` to give sibling locale files the English key set, removing whole entries only when their keys no longer exist in English.
4. Translate `TODO` placeholders left by `syncstrings`, matching each locale's existing terminology and tone.
5. Verify every target locale matches the English key set. Run `syncstrings <localization-root> en` a second time; it should report zero updated files.

## Guardrails

- Do not manually add `TODO` placeholders or remove stale keys in target locales when `syncstrings` can do it.
- Do not change existing non-`TODO` target translations that still correspond to English keys; `syncstrings` preserves those raw values.
- Call out translations that need native-speaker review.
