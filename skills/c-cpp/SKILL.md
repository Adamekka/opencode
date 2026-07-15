---
name: c-cpp
description: When C/C++.
---

# Shared Preferences

- Prefer Clang toolchains when the project supports them.
- Use sized integer types (`int32_t`, `uint8_t`, etc.) for explicit integer type declarations instead of `int`, `long`, `unsigned`, etc. The standard `main` return type is an exception. When a local integer exists only to supply an argument whose API declaration already fixes the required integer type, allow `auto` to infer it instead of adding a sized conversion solely to control deduction.
- Prefer `const` wherever possible, including local variables, references, pointers, and non-mutating member functions.
- For raw C-style pointers, use the strongest valid const qualification for both the pointee and pointer, such as `const Type* const var`, whenever neither is modified.
- Always use `auto` wherever the type can be inferred.
- Declare and initialize variables using direct-list initialization in the form `auto var{Type{}}`.
- Always include a trailing comma in multiline array initializers.

# C Preferences

- Always use safe alternatives to C functions

# C++ Preferences

- Always declare `main` as `auto main() -> int`.
- Declare every class and struct `final`; omit `final` only when the type is intentionally designed to be inherited from.
- Always use trailing return types: `auto foo() -> int32_t` not `int foo()`.
- Include project-local headers with quotes, not angle brackets.
- Always name function parameters, including parameters in declarations and callbacks, except copy/move constructor and copy/move assignment parameters. Mark intentionally unused named parameters `[[maybe_unused]]` when needed.
- Make single-argument constructors `explicit`, except enum-wrapper constructors intended to provide an implicit conversion from their wrapped enum.
- Always use `this->` when accessing members where valid.
- Prefer in-class member initializers. When that is not possible, use the constructor initializer list; assign members in the constructor body only when neither initializer form can express the required initialization.
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
- Pass small copyable value types by value. Keep resource-owning wrappers noncopyable, borrow them by `const` reference, and add move operations only when ownership transfer is required.
- Prefer `emplace`/`emplace_back` over `insert`/`push_back` when constructing elements in-place.
- Use `constexpr` for values and functions that can be evaluated at compile time but may also be used at runtime. Use `consteval` only when every call must be evaluated at compile time and runtime calls should be rejected. Do not apply either specifier to runtime-only operations. Keep definitions of public `constexpr` functions reachable from their call sites, normally by defining them in the header.
- Add `const` to value parameters in `.cpp` definitions where the parameter is not reassigned inside the function body. Do not put `const` on by-value parameters in header declarations (it has no effect on the function signature).
