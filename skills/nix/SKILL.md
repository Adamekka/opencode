---
name: nix
description: Use when editing or discussing Nix, NixOS, Home Manager, flakes, Nix modules, overlays, package lists, or Nix formatting style.
---

# Nix

## Sorting

- Alphabetically sort everything that can be sorted without changing behavior.
- Keep attribute names, option names, imports, package lists, module lists, overlays, environment variables, and formatter/linter configuration sorted alphabetically.
- Sort nested structures too; do not stop at the top level.
- Preserve semantic order when changing it would alter behavior, such as ordered shell commands, firewall rules, overlays with dependency order, or lists where earlier entries intentionally override later entries.
- When semantic order prevents alphabetical sorting, keep the existing order and mention the reason before handing off.
- Add new items in their sorted position instead of appending and relying on a later cleanup pass.
