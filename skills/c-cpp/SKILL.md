---
name: c-cpp
description: Use when editing C or C++ files, configuring C/C++ tooling, or discussing C/C++ implementation style.
---

# C and C++ Preferences

- Prefer Clang toolchains for C and C++ projects when the project supports them.
- Always use trailing return types: `auto foo() -> int32_t` not `int foo()`.
- Always use sized integer types (`int32_t`, `uint8_t`, etc.); never use `int`, `long`, `unsigned`, etc.
- For C++, use `this->` when accessing members where valid.
- Prefer constructor initializer lists whenever members or base classes can be initialized there.
- Prefer `std::unique_ptr` over raw `new`; only use raw `new` when ownership is immediately transferred to a framework that manages lifetime itself (e.g. Qt parent-child widget ownership).
- For C++, prefer `emplace`/`emplace_back` over `insert`/`push_back` when constructing elements in-place.
- For C++, prefer `const` wherever possible, including local variables, references, pointers, and non-mutating member functions.
- Add `const` to value parameters in `.cpp` definitions where the parameter is not reassigned inside the function body. Do not put `const` on by-value parameters in header declarations (it has no effect on the function signature).
