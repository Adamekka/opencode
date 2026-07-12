---
name: c-cpp
description: When C/C++.
---

# Shared Preferences

- Prefer Clang toolchains when the project supports them.
- Always use sized integer types (`int32_t`, `uint8_t`, etc.); never use `int`, `long`, `unsigned`, etc.
- Prefer `const` wherever possible, including local variables, references, pointers, and non-mutating member functions.
- For raw C-style pointers, use the strongest valid const qualification for both the pointee and pointer, such as `const Type* const var`, whenever neither is modified.
- Always use `auto` wherever the type can be inferred.
- Declare and initialize variables using direct-list initialization in the form `auto var{Type{}}`.

# C Preferences

- Always use safe alternatives to C functions

# C++ Preferences

- Declare every class and struct `final`; omit `final` only when the type is intentionally designed to be inherited from.
- Always use trailing return types: `auto foo() -> int32_t` not `int foo()`.
- Always use `this->` when accessing members where valid.
- Always use initializer lists whenever members or base classes can be initialized there.
- Order class members as follows, omitting sections that do not apply:

  ```cpp
  public:
      // Variables

      // Constructor

      // Copy constructor
      // Move constructor

      // Destructor

      // Copy-assignment operator
      // Move-assignment operator

      // Methods

  private:
      // Variables

      // Methods
  ```

  Keep `public` before `private`, variables before methods within each visibility section, and preserve the blank-line grouping shown above between function categories.
- Prefer `std::unique_ptr` over raw `new`; only use raw `new` when ownership is immediately transferred to a framework that manages lifetime itself (e.g. Qt parent-child widget ownership).
- Prefer `emplace`/`emplace_back` over `insert`/`push_back` when constructing elements in-place.
- Always use `constexpr` and `consteval` where values and functions can be evaluated at compile time.
- Add `const` to value parameters in `.cpp` definitions where the parameter is not reassigned inside the function body. Do not put `const` on by-value parameters in header declarations (it has no effect on the function signature).
