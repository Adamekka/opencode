# CoreUtils integration

## Read the live integration

Inspect CoreUtils at the revision fetched for its Git package requirement, using the resolved SwiftPM checkout or a temporary Git clone for preflight inspection. In that checkout, start with `AGENTS.md` and `docs/README.md`. Read the linked startup and app-logging requirements and any feedback or purchase documentation needed by the selected configuration. No sibling CoreUtils checkout is required.

Inspect the public declarations for `AppWrapper`, `Accountable`, `AccountStore`, `SettingsConfig`, `SettingsViewInternal`, `PaywallConfig`, `PaywallContext`, `PaywallOffer`, `PaywallSource`, `OnboardingFlow`, `OnboardingStep`, `OnboardingAudience`, `OnboardingNavigator`, and the startup configuration types. Read the app-owned onboarding and paywall section of `docs/onboarding.md`. Locate declarations with `rg` rather than relying on remembered signatures. Read the fetched checkout's `Package.swift` for the exported product and toolchain requirements. Use the same revision for inspection and the app's resolved dependency.

Read the [bundled integration examples](coreutils-examples.md) for startup, Account, Settings, and app configuration. They contain the extracted patterns and do not require another app repository. Compare their API calls with the live declarations before editing the app. If they differ because information is outdated, stop and report the mismatch instead of porting the examples silently.

Use [localization and logging](localization-and-logging.md) for app resources, the shared language picker, typed log declarations, and the call sites used by the bundled examples.

## Required app choices

Use values already supplied for this app and perform [App Store Connect discovery](app-store-connect.md) with `asc` before asking for values available there. Ask only for unresolved choices, one at a time, before generating configuration:

- The real App Store URL for `SettingsConfig`. Use available app-specific privacy policy and terms URLs; for a missing one, follow the placeholder rule in [the skill](../SKILL.md).
- Whether in-app feedback is enabled. This controls notification integration and signing configuration.
- The default app color and explicit App Color and App Lock choices. Enabled features require distinct stable storage keys and a Free or Premium access policy. App Lock also requires the app's Face ID usage description.
- Explicit KVS, archive and CloudKit backup choices. Pass an enabled app-lifetime manager for each adopted backup type, or `.disabled`. AppWrapper owns registration and lifecycle; Settings derives availability from the registered managers.
- Purchase identity and monetization choices. Obtain real offer IDs and the intended default product ID. StoreKit supplies renewal periods, prices and trial eligibility. Token products also require their actual grant amounts and names.
- The onboarding flow: the ordered pages, each page's audience (`.everyone` or `.freeUsers`), and where the paywall step sits. Obtain the approved design, copy and assets for every page and for the paywall, including any per-`PaywallSource` copy. Ask for missing designs instead of inventing them.
- Any splash styling needed by the startup flow. The shared splash requires an `Icon` image asset containing this app's approved icon.
- Whether ATT and advertising are used. Use `.disabled` for the advertising consent provider only when ads are explicitly disabled.
- Settings presentation if the app has no chosen route for it yet.

Do not use empty offers or invent a default product. CoreUtils requires a nonempty offer list with unique product IDs and a default product ID from that list. If the user needs a flow the live API cannot represent, explain the mismatch and ask how to proceed rather than inventing products or modifying CoreUtils as part of app setup.

## Add the Git package

Add `https://github.com/RiviaCorp/CoreUtils` as a remote Swift package dependency of the Xcode project and link its `CoreUtils` library product to the app target. Link its separate `CoreCloudKit` product only when the app uses its CloudKit helpers. For a fresh project, use the `main` branch requirement. Preserve an existing explicitly selected version, branch, or revision unless the user asks to change it. For a `.pbxproj`, wire the `XCRemoteSwiftPackageReference` with its repository URL and requirement, `XCSwiftPackageProductDependency`, target `packageProductDependencies`, and Frameworks build phase. Let SwiftPM fetch the repository with Git and record the resolved revision in the app's `Package.resolved`.

Reuse an existing matching remote reference or replace a local CoreUtils reference without creating a second dependency. Do not use `XCLocalSwiftPackageReference` or a filesystem package path for CoreUtils. Add package products to test targets only when their imports require them. Keep dependencies limited to this integration.

## Account lifetime

- Create an app-owned `@Observable final class Account: Accountable`, importing the modules required by its actual declarations.
- Compose the shared `AccountStore` and provide the chosen purchase identity. Let CoreUtils own persisted purchase state and shared services.
- Implement `tokens(for:)` from the app's product model. For an explicitly subscription-only app, an assertion followed by `return 0` can satisfy the protocol's unreachable token path. Include a why comment explaining that the app has no consumable products.
- Keep initialization free of duplicated shared startup. A deliberate empty initializer needs a why comment explaining that `AppWrapper` starts the shared account lifecycle.
- Own one account for the lifetime of the SwiftUI `App`, for example with `@State private var account: Account = .init()`. Pass that instance to `AppWrapper`; do not construct an account in `body` or create a second one for Settings.

## AppWrapper and configuration

- Wrap the real root content in `AppWrapper` inside the app's `WindowGroup`. Pass the app-lifetime account and explicit `settingsConfig` using the live initializer.
- Supply all other required startup arguments from the agreed app choices. Follow CoreUtils's docs for any required Info.plist values or configuration; preserve required startup diagnostics instead of inventing fallback values.
- Use the AppWrapper initializer that takes `onboarding`, `onboardingPage`, `paywallConfig` and `paywall`. Do not use `onboardingViews`, `trialPageConfig`, `OnboardingViewType`, `OnboardingView`, `TrialPageConfig` or `TrialPage`. Supply the flow and paywall configuration through the closures so values computed there follow language changes.
- Implement each onboarding page as an app view that calls `OnboardingNavigator.advance()` to continue. Implement one app paywall view that reads `PaywallContext`. CoreUtils owns progress, Premium skipping, StoreKit loading, purchase, restore, and the Close and Restore toolbar items.
- Apps own the layout, fit, Dynamic Type, artwork, copy and accessibility of every page and the paywall. The paywall handles the loading, failed (with retry) and ready states, shows "no payment now" copy only when `selectedOfferHasFreeTrial` is true, and disables plan selection and Continue while `isPurchasing` is true. It must not hide the navigation bar or toolbar, because that hides Close and Restore; tint them with `.paywallToolbarTint(_:)` when the design needs it.
- Use the content closure's advertising-consent result if ads are configured. Do not ignore it in an app that requests ads.
- Leave shared account startup, logger linking, purchase refresh, saved appearance, and language updates in `AppWrapper`.

When `feedbackEnabled` is true, follow CoreUtils's feedback documentation. Attach `FeedbackApplicationDelegate` with `@UIApplicationDelegateAdaptor`, pass it through `notifications: .enabled(...)`, and configure Push Notifications plus the required APNs environment from the actual signing choices. Set the Info.plist `APNSEnvironment` value from the same `APNS_ENVIRONMENT` build setting the push entitlement uses; CoreUtils fails at startup without it. Preserve an existing delegate's responsibilities and required superclass calls. When feedback is explicitly disabled, omit the `notifications` argument, as CoreUtils's feedback documentation directs, and omit feedback-only capabilities.

Do not add a delegate whose only purpose is to return `true` from launch. The shared startup does not require one when no selected feature uses a delegate.

## Settings

- Implement an app `SettingsView` that reads the same `Account` from the environment and composes `SettingsViewInternal<Account>`.
- Supply the app's sections, developer sections, and back-control choice using the initializer without `trialPageConfig`. Settings, App Theme and App Lock then present the paywall AppWrapper received. Include the account license row shown in the bundled example; add app-specific rows only for agreed behavior.
- Get `SettingsConfig` and feedback runtime through `AppWrapper`'s environment.
- Connect Settings to an actual tab, toolbar action, or navigation destination according to the agreed presentation. A Settings view file without a route does not complete the integration.
- When adding standalone previews, supply their account and `.settingsConfig(...)` explicitly. Keep preview-only data out of production configuration.
