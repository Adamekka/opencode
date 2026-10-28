---
name: new-swiftui-app
description: Configure a fresh Xcode SwiftUI app for iOS with shared formatting and linting, Swift 6 concurrency, localization, logging, and CoreUtils fetched from Git. Use for initial app setup.
---

# New SwiftUI app

Configure an existing, newly created Xcode SwiftUI project. Apply the setup to the requested app and leave shared dependencies unchanged.

## Check for outdated information

Before editing the app, compare this skill's instructions and bundled examples with the CoreUtils APIs at the fetched Git revision, shared configs, and required tools. If any information is outdated, stop the setup and report what is outdated, the concrete mismatch, and what needs to change. Do not silently adapt examples, update dependencies or tools, or substitute another configuration to continue. Use evidence of a mismatch rather than age alone; the requested iOS 17 and Swift 6 baselines are intentional.

## Resolve app inputs

- Identify the app root, Xcode project, app target, configurations, and SwiftUI entry point. If the project does not exist or the target is ambiguous, ask before proceeding.
- Resolve `../config-files` relative to the app root. Inspect the actual files rather than assuming their contents. If it is missing, ask for its location instead of substituting bundled configs.
- Fetch CoreUtils from its Git repository as described in the integration reference. Inspect the fetched revision rather than requiring a sibling checkout. If fetching fails, stop and report the failure instead of substituting a local package.
- Ask for the bundle identifier unless the user has already supplied it for this app. Do not derive it from the project name or copy it from another app. Then use [App Store Connect discovery](references/app-store-connect.md) through `asc` to retrieve the app ID, available URLs, localized metadata, and configured products before requesting remaining inputs.
- Use the supplied home-screen display name. The App Store marketing name can differ; ask for the display name when it has not been provided rather than treating the store title as that choice.
- Read [CoreUtils integration](references/coreutils.md) and resolve its required app-specific configuration before wiring startup. Ask only for unresolved inputs, one focused question at a time, and wait for each answer. Never fill missing values with another app's URLs, product IDs, account choices, assets, or copy.
- If this app has no privacy policy or terms URL, use `https://riviacorp.com` for that missing URL and add a `// TODO` comment beside the Swift argument explaining which app-specific URL must replace it. This is the explicit placeholder policy for these two URLs; use real URLs when available.

## Copy shared configs

Copy these files into the app repository root, retaining their names and contents:

- `../config-files/swift/.swiftformat` to `.swiftformat`
- `../config-files/swift/.swiftlint.yml` to `.swiftlint.yml`

Read the live source files on every invocation. Do not maintain copies in this skill or weaken their rules to accommodate an older tool. If the installed tools cannot read the configs, stop and report the incompatible options and tool version.

## Configure Xcode

Apply the following values to every app build configuration, including Debug and Release. Account for project settings, target overrides, conditional settings, and `.xcconfig` files so the effective values match. Apply the language, concurrency, deployment, and platform settings to the app's test targets as well. Do not rewrite CoreUtils's own package settings.

| Setting | Value |
| --- | --- |
| `ENABLE_USER_SCRIPT_SANDBOXING` | `NO` |
| `SWIFT_VERSION` | `6.0` |
| `SWIFT_APPROACHABLE_CONCURRENCY` | `YES` |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` |
| `SWIFT_STRICT_CONCURRENCY` | `complete` |
| `SWIFT_EMIT_LOC_STRINGS` | `YES` |
| `IPHONEOS_DEPLOYMENT_TARGET` | `17.0` |
| `SUPPORTED_PLATFORMS` | `iphoneos iphonesimulator` |
| `SUPPORTS_MACCATALYST` | `NO` |
| `SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD` | `NO` |
| `SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD` | `NO` |
| `TARGETED_DEVICE_FAMILY` | `1,2` |
| `MARKETING_VERSION` | `0.0.0` |
| `CURRENT_PROJECT_VERSION` | `0` |
| `PRODUCT_BUNDLE_IDENTIFIER` | User-provided bundle identifier |
| `INFOPLIST_KEY_CFBundleDisplayName` | User-provided display name |
| `INFOPLIST_KEY_ITSAppUsesNonExemptEncryption` | `NO` |

For a manually maintained Info.plist, set `CFBundleDisplayName` and the Boolean `ITSAppUsesNonExemptEncryption = false` there instead of creating competing definitions. Ensure the built bundle's version and build resolve to `0.0.0` and `0` as well.

Remove macOS and visionOS destinations and conflicting platform-specific deployment settings from this app's project. If the template contains separate macOS or visionOS targets, remove those targets and their scheme references while retaining shared source files needed by iOS. Keep iPhone and iPad support. Leave signing identity and team choices as supplied by the project or user.

The build-setting names can be checked against [Apple's build settings reference](https://developer.apple.com/documentation/xcode/build-settings-reference).

## Add the Lint build phase

Add one Run Script phase named `Lint` to the app target, or update its existing Lint phase. Use `/bin/sh` and run from the app root so SwiftLint reads the copied config. The script below assumes `.xcodeproj` is at that root. For a nested project, adjust the `cd` path explicitly to reach the directory containing the copied configs.

```sh
# Xcode does not inherit Apple Silicon Homebrew's executable search path.
if [ "$(uname -m)" = arm64 ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

cd "${SRCROOT:?Xcode must provide SRCROOT}" || exit 1

if command -v swiftlint > /dev/null 2>&1; then
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
```

Match these phase options:

- For install builds only, unchecked. Set `runOnlyForDeploymentPostprocessing = 0` and use the normal all-actions `buildActionMask = 2147483647`.
- Based on dependency analysis, unchecked. Set `alwaysOutOfDate = 1` because lint must run on incremental builds too.
- Show environment variables in build log, checked. Set `showEnvVarsInLog = 1`.
- Use discovered dependency file, unchecked. Do not add a dependency file or artificial output paths to suppress execution.

Retain the explicit missing-tool warning. Do not add auto-fixing or promote lint warnings to errors.

## Integrate CoreUtils

Follow [CoreUtils integration](references/coreutils.md) and its [bundled examples](references/coreutils-examples.md) to add the Git-backed Swift package and wire the app-lifetime `Account`, `AppWrapper`, and a reachable Settings screen. The examples are stored in this skill; no reference app repository is needed. Check them against the declarations at the fetched CoreUtils revision and stop if they are outdated.

## Add localization and logging

Follow [localization and logging](references/localization-and-logging.md) for the app's localized resources, literal `.localized()` calls, typed event and screen definitions, and account-owned logger usage. Ask for the development language and supported locales when missing. Keep shared language updates and logger startup in AppWrapper.

## Initialize Git

Create `.gitignore` in the app repository root with these contents:

```gitignore
.DS_Store
xcuserdata/
```

If `.gitignore` already exists, preserve its existing rules and add only missing entries from this list.

Run `git init` in the app repository root. Preserve any existing repository history. Do not create a commit or remote unless requested.

## Verify

- Validate changed project and plist syntax, then use `xcodebuild -list` to confirm the project and scheme load.
- Inspect effective build settings for Debug and Release, plus any other configurations. Verify deployment, language, concurrency, platform support, identity, version, and sandboxing values.
- Resolve the Git-backed package and build the app for a generic iOS Simulator destination. Use a toolchain compatible with the fetched CoreUtils revision's `Package.swift` and the copied formatter config. Report toolchain or dependency-resolution failures without changing the requested setup to hide them.
- Verify that the built app's Info.plist contains the requested display name, bundle ID, versions, and Boolean encryption flag.
- When Swift files changed, run `swiftformat .` and `swiftlint` from the app root, then rebuild if formatting changed compiled source.
- Verify startup and access to Settings in a simulator using the environment's device workflow. Check that both use the same account and settings configuration.
- Verify that localized resources are bundled, their key sets match, and changing language updates content and Settings while preserving the account. Verify that opening Settings records the app's typed event and screen through the same account logger.
- Check the diff for duplicate package references or Lint phases and accidental edits to sibling repositories. Report what was configured and any verification blocker.
