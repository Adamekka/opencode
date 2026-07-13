---
name: nix
description: When editing Nix files.
---

# Nix

## Formatting And Linting

- Format files in place with `nixpkgs-fmt FILE...`.
- Check formatting without modifying files with `nixpkgs-fmt --check FILE...`; use `--explain` to show violated formatting rules.
- In a local NUR repository, lint an affected package from the repository root with `nixpkgs-lint --file . --package PACKAGE_ATTRIBUTE`.
- `--file .` evaluates the repository's root `default.nix`; `--package` selects an exported package attribute, not a source file.
- Lint all exported packages with `nixpkgs-lint --file .`; its package filter defaults to `*`.

## Sorting

- Alphabetically sort everything that can be sorted without changing behavior.
- Keep attribute names, option names, imports, package lists, module lists, overlays, environment variables, and formatter/linter configuration sorted alphabetically.
- Sort nested structures too; do not stop at the top level.
- Preserve semantic order when changing it would alter behavior, such as ordered shell commands, firewall rules, overlays with dependency order, or lists where earlier entries intentionally override later entries.
- When semantic order prevents alphabetical sorting, keep the existing order and mention the reason before handing off.
- Add new items in their sorted position instead of appending and relying on a later cleanup pass.
