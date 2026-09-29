---
name: nix
description: When editing Nix files.
---

# Nix

## Formatting And Linting

- Format each file in place with `nixfmt FILE`.
- Check each file's formatting without modifying it with `nixfmt --check FILE`.

## Sorting

- Alphabetically sort attribute names, option names, imports, package lists, module lists, overlays, environment variables, formatter/linter configuration, and any other sortable structure without changing behavior. Apply this to nested structures too.
- Preserve semantic order when changing it would alter behavior, such as ordered shell commands, firewall rules, overlays with dependency order, or lists where earlier entries intentionally override later entries.
- When semantic order prevents alphabetical sorting, keep the existing order and mention the reason before handing off.
