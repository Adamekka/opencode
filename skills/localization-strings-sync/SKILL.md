---
name: localization-strings-sync
description: Mirror uncommitted changes from a source Localizable.strings file into sibling locale files and verify key parity.
compatibility: opencode
metadata:
  audience: maintainers
  workflow: localization
---

## What I do

- Review the uncommitted diff for a source `Localizable.strings` file, usually the base or English locale.
- Apply added and removed keys to sibling `*.lproj/Localizable.strings` files.
- Keep entries aligned with the surrounding sort order and existing formatting.
- Verify every target locale matches the expected key set before handing off.

## When to use me

Use this when one locale's `Localizable.strings` file changed and the same key set needs to be propagated to the other locales.

## Workflow

1. Inspect the diff for the source localization file only.
2. List the added, removed, and renamed keys before editing any target files.
3. Read the neighboring lines in each target file so inserted keys land in the right position.
4. Add translated values for new keys, matching the locale's existing terminology and tone.
5. Remove keys that were deleted from the source locale.
6. Preserve unrelated edits and translations already present in the target files.
7. Verify each added key exists exactly once in every target locale and each removed key is gone.
8. Review the diff and report any translations that may need native-speaker follow-up.

## Guardrails

- Do not rewrite whole localization files when small targeted edits are enough.
- Do not change the source locale unless the user asked for it.
- Do not silently fall back to placeholder behavior for uncertain translations; call it out if confidence is low.
- Prefer scripted verification over manual eyeballing.

## Verification

- Search all locale files for the added and removed keys.
- Read the resulting diff to confirm only the intended entries changed.
