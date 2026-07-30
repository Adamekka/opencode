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
- Declare and initialize variables using direct-list initialization in the form `auto var{Type{}}`. Use parenthesized construction inside the outer list when braces would select an `initializer_list` constructor and change the intended semantics, such as `auto values{std::vector<char>(count)}` for a count-sized vector.
- Always include a trailing comma in multiline array initializers.

# C Preferences

- Always use safe alternatives to C functions

# C++ Preferences

- Always declare `main` as `auto main() -> int`.
- Declare every class and struct `final`; omit `final` only when the type is intentionally designed to be inherited from.
- Always use trailing return types: `auto foo() -> int32_t` not `int foo()`.
- Use `[[nodiscard]]` broadly on functions and constructors whose ignored result is likely a mistake, including error/status results, ownership-bearing values, computed values, and factory functions. Never apply `[[nodiscard]]` to a type declaration. Omit it when discarding the result is an intentional and common use case.
- Include project-local headers with quotes, not angle brackets.
- Always name function parameters, including parameters in declarations and callbacks, except copy/move constructor and copy/move assignment parameters. Mark intentionally unused named parameters `[[maybe_unused]]` when needed.
- Make single-argument constructors `explicit`, except enum-wrapper constructors intended to provide an implicit conversion from their wrapped enum.
- When a declaration is both `constexpr` and `explicit`, order the specifiers as `constexpr explicit`.
- Always use `this->` when accessing members where valid.
- Prefer in-class member initializers for fixed default values. Do not add redundant `{}` initializers to members that their normal construction, aggregate initialization, or constructor initializer list already initializes in place. Assign members in the constructor body only when neither initializer form can express the required initialization.
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
- Pass non-resource-owning, trivially copyable value types no larger than two pointers (`sizeof(T) <= 2 * sizeof(void*)`) by value. Apply this only when the parameter's declared type guarantees the size bound; generic or extensible APIs that can accept larger types may borrow by `const` reference. Keep resource-owning wrappers noncopyable, borrow them by `const` reference, and add move operations only when ownership transfer is required.
- Prefer `emplace`/`emplace_back` over `insert`/`push_back` when constructing elements in-place.
- Use `constexpr` for values and functions that can be evaluated at compile time but may also be used at runtime. Use `consteval` only when every call must be evaluated at compile time and runtime calls should be rejected. Do not apply either specifier to runtime-only operations. Keep definitions of public `constexpr` functions reachable from their call sites, normally by defining them in the header.
- Omit top-level `const` from by-value parameters in function declarations that are not definitions because it has no effect on the function signature. Add `const` to by-value parameters in function definitions, including definitions in headers, where the parameter is not reassigned. When a function has a separate declaration and definition, omit `const` from the declaration and include it in the definition.
