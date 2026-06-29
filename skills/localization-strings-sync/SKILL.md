---
name: localization-strings-sync
description: Use genstrings and syncstrings to regenerate an English Localizable.strings baseline, mirror keys into sibling locale files, and verify key parity.
compatibility: opencode
metadata:
  audience: maintainers
  workflow: localization
---

## What I do

- Run `genstrings` to regenerate the English `Localizable.strings` baseline from Swift sources.
- Run `syncstrings` after `genstrings` so sibling `*.lproj/*.strings` files get the same key set.
- Preserve existing translated target values, translate `TODO` placeholders left by `syncstrings`, and remove whole entries only when their keys no longer exist in English.
- Verify every target locale matches the expected key set before handing off.

## When to use me

Use this when Swift localized strings changed, an English `Localizable.strings` baseline needs regenerating, or one locale's `.strings` key set needs to be propagated to sibling locale files.

## Tools

- Use `genstrings` from PATH.
- Use `syncstrings` from PATH.
- If either command is missing, stop and report that the localization tools are not installed correctly.

## Workflow

1. Identify the Swift source root to scan and the localization root that contains `en.lproj` plus sibling locale folders.
2. Regenerate the English baseline with `genstrings <source-root> > <localization-root>/en.lproj/Localizable.strings`.
3. Inspect the English baseline diff so unexpected key churn is caught before syncing target locales.
4. Run `syncstrings <localization-root> en` to update sibling locale files.
5. Translate `TODO` placeholders left by `syncstrings`, matching each locale's existing terminology and tone.
6. Run `syncstrings <localization-root> en` a second time; it should report zero updated files.

## Guardrails

- Do not manually add `TODO` placeholders or remove stale keys in target locales when `syncstrings` can do it.
- Do not change existing non-`TODO` target translations that still correspond to English keys; `syncstrings` preserves those raw values.
- Do not leave `TODO` placeholders as the final state when translation is in scope; translate them and call out any translations that need native-speaker review.
- Prefer scripted verification over manual eyeballing.

## Verification

- Re-run `syncstrings <localization-root> en` and require an idempotent result with zero updated files.
- Search all locale files for added and removed keys when reviewing a specific change.
- Read the resulting diff to confirm English was regenerated first and target locales only received key-set synchronization.
