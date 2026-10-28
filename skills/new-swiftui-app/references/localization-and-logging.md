# Localization and logging

Check this guidance and its examples against the fetched CoreUtils revision and installed tools before editing the app. If any information is outdated, stop and report it. No reference app repository is required.

## Localization setup

- Ask for the development language and supported locale codes when not supplied. Confirm that the fetched CoreUtils language picker supports those codes; do not invent a display name or silently substitute a locale.
- Use `Localize_Swift` with the existing CoreUtils integration. Ensure the app can import the package's `Localize_Swift` product through its resolved dependencies. Do not add a second localization library.
- Configure Xcode's development region and known regions to match the agreed languages. Create `<locale>.lproj/Localizable.strings` under the app's resource root and include them in the app target's resources. Verify target membership or the corresponding synchronized-group inclusion. Do not assume files on disk are automatically bundled.
- Use the `.strings` extraction and synchronization workflow below. If a populated string catalog already owns the same table, resolve that format choice with the user before changing it; do not create competing `Localizable` tables.
- Keep `SWIFT_EMIT_LOC_STRINGS = YES` in all app configurations. The compiler setting does not replace extraction of the custom `.localized()` calls.
- Let AppWrapper and its localization manager own runtime language changes. Use the shared Settings language picker and keep localized onboarding and paywall values computed inside AppWrapper's configuration closures. Do not add another language manager or refresh account state when the language changes.

## Localized source

Import `Localize_Swift` where needed. Apply `.localized()` directly to quoted string literals, on the same line as each literal, so the extractor can find them. Localize complete sentences and labels, including accessibility labels and recoverable error messages. Keep product IDs, URLs, resource identifiers, and logging names unlocalized.

Use a localized format string for runtime values, rather than interpolating values into a localization key. These expressions illustrate the pattern; use the app's actual copy and values.

```swift
import Localize_Swift
import SwiftUI

Text("Settings".localized())
```

For a formatted sentence inside an existing view that has an integer `count`:

```swift
Text(String(format: "Remaining: %ld".localized(), count))
```

Supply locale-correct plural handling when the app's copy requires it; do not assume one plural form works for every count or language.

If a localized literal inside a function call exceeds the formatter's line limit, place `// swiftformat:options:next --maxwidth 1000` inside that call immediately before the string expression. Keep the literal and its `.localized()` call together.

## Extract and synchronize resources

Use the Swift-aware `genstrings` and `syncstrings` tools from PATH. Verify that `genstrings` is the custom Swift extractor, rather than Apple's tool with the same name. Their supported positional forms are `genstrings <swift-source-root>` and `syncstrings <localization-root> <base-locale>`.

1. Identify the app's Swift source root and the resource root containing its locale folders. Scan app sources, excluding fetched package checkouts, build products, and test-only copy.
2. Run `genstrings` on the source root and capture stdout to a temporary file. Require a successful exit and validate the resulting `.strings` syntax before replacing `<base-locale>.lproj/Localizable.strings`. This staging keeps extraction failures from truncating an existing baseline. Stop and report a failed extraction or an unexpectedly empty result.
3. Run `syncstrings` with the localization root and agreed base locale. It synchronizes sibling locale files to the baseline key set, preserves existing translations, marks missing translations as `TODO`, and removes keys absent from the baseline.
4. Translate generated `TODO` values for the selected locales, preserving format specifiers and existing terminology. Do not invent translations for unsupported locales. Report any translation requiring native-speaker review.
5. Validate `.strings` syntax and matching key sets. Run `syncstrings` again; it should report zero changed files. Verify that the built app contains the locale resources.

Generate keys through source extraction rather than editing key sets by hand. Keep package-owned translations in the package; this setup changes only app resources. Use the agreed baseline everywhere; `en` is an example, not an implicit fallback. This setup does not authorize a localization commit or edits to shared tooling.

## Logging setup

Read `docs/app-logging.md` and the `LogEvent`, `LogScreen`, and `Logger` declarations in the fetched CoreUtils checkout. AppWrapper starts and links the logger held by the app-lifetime Account. Use `account.logger`; do not create another logger or add per-view startup, readiness checks, upload queues, or logging adapters.

Create app-owned `Logging/LogEvent+<App>.swift` and `Logging/LogScreen+<App>.swift` files. Define events and screens used by actual app flows. Use `static let` for definitions without runtime values and static factories with typed arguments for payloads. Each definition owns its name, severity, and parameter encoding. Callers pass complete typed definitions instead of raw names or parameter dictionaries.

Logging names are stable, nonlocalized `snake_case` string literals with an explicit severity. Match the fetched API's name limits. Do not put user-authored text, secrets, error descriptions, or `userInfo` in remote payloads. Use the initializer's `error:` argument for the underlying failure; CoreUtils owns error identifiers and debug diagnostics.

The bundled root and Settings route use these definitions:

```swift
import CoreUtils

extension LogEvent {
    static let settingsOpened: Self = .init(name: "settings_opened", level: .info)
}
```

```swift
import CoreUtils

extension LogScreen {
    static let content: Self = .init(name: "content", level: .info)
    static let settings: Self = .init(name: "settings", level: .info)
}
```

For app-specific operations, this separate example shows typed payload and error factories. Add only the definitions needed by real callers, using the actual operation's names and domain values.

```swift
import CoreUtils

extension LogEvent {
    static func itemsLoaded(count: Int) -> Self {
        .init(name: "items_loaded", level: .info, parameters: ["item_count": .integer(Int64(count))])
    }

    static func itemsLoadFailed(error: any Error) -> Self {
        .init(name: "items_load_failed", level: .error, error: error)
    }
}
```

In views, read the existing account with `@Environment(Account.self)` and log screens from `.onAppear`. Log action events in their handlers and completion events only after successful operations. In catch blocks, pass the underlying error to the typed factory while preserving the app's recoverable error handling. Managers that need only logging receive this same Logger rather than the entire account. Honor Logger's actor isolation.

The [integration examples](coreutils-examples.md) log the root and Settings screens on appearance and `self.account.logger.log(.settingsOpened)` in the Settings action. Use domain-specific names for actual app screens when replacing the root content example. Avoid duplicate tracking of shared startup or purchase events already owned by CoreUtils. Leave preview suppression, persistence, service linking, retry behavior, and diagnostics in the shared implementation.

Verify the app's required bundle metadata and any startup configuration demanded by the fetched library. Keep required values required. In the running app, confirm the Settings event and screen reach the existing logger and that a logging runtime failure does not block the UI. Do not weaken the logger's explicit local-StoreKit or backend-verification failures to make setup appear successful.
