---
name: rust
description: When Rust.
---

# Rust Preferences

- Every Rust type should live in its own file.
- In binary Rust projects, prefer `pub` over `pub(crate)` when both accomplish the same thing; use `pub(crate)` only when the narrower visibility meaningfully helps.
