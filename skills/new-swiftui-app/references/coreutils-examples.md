# CoreUtils integration examples

These examples are bundled with the skill. Check them against the CoreUtils declarations at the fetched Git revision before applying them. If any information is outdated, stop and report it.

The examples illustrate an explicitly chosen configuration with anonymous purchase identity, yearly and weekly subscriptions, the yearly offer selected initially, ads and feedback disabled, no onboarding callbacks or icon shadow, and Settings presented as a sheet. These are example choices, not defaults for a new app. Confirm the app's choices and adapt its content and offer structure accordingly. A change in app requirements is separate from an outdated API; the latter requires stopping and reporting.

Replace every `<#...#>` editor placeholder with the app's real values before building. String-literal placeholders require quoted Swift strings. These placeholders prevent missing required information from becoming runnable production configuration. Keep the app's existing root content and use its actual App type name.

Create the app's localized resources and the `LogEvent` and `LogScreen` definitions from [localization and logging](localization-and-logging.md). The Settings examples below use those definitions and the account's existing logger.

## Account

`Settings/ViewModels/Account.swift` owns app state and composes shared account behavior. This example has no app-specific usage limits or persistence.

```swift
import CoreUtils
import Observation

@Observable
final class Account: Accountable {
    let accountStore: AccountStore = .init()
    let purchaseIdentity: PurchaseIdentity = .anonymous

    init() {
        // AppWrapper starts the shared lifecycle after app-specific setup.
    }

    func tokens(for _: String) -> Int {
        // This subscription-only configuration has no consumable token products.
        assertionFailure("Consumable token products are not configured.")
        return 0
    }
}
```

## Settings configuration

`Config/SettingsConfig.swift` contains the real app URLs and the explicit feedback choice. This configuration is passed to AppWrapper, which supplies it to Settings through the environment.

```swift
import CoreUtils
import Foundation

@MainActor let settingsConfig: SettingsConfig = .init(
    appStoreURL: .init(string: <#APP_STORE_URL_STRING_LITERAL#>)!,
    privacyURL: .init(string: <#PRIVACY_URL_STRING_LITERAL#>)!,
    termsURL: .init(string: <#TERMS_URL_STRING_LITERAL#>)!,
    feedbackEnabled: false,
)
```

## Paywall configuration

`Config/TrialPageConfig.swift` computes localized content when accessed. Use the app's actual subscription IDs and renewal rates. The selected index must refer to an offer in this same array. This example compares the yearly subscription with the weekly subscription and does not assert any introductory trial eligibility.

```swift
import CoreUtils
import Localize_Swift

@MainActor var trialPageConfig: TrialPageConfig {
    .init(
        appName: <#APP_DISPLAY_NAME_STRING_LITERAL#>.localized(),
        iconShadowConfig: nil,
        title: <#PAYWALL_TITLE_STRING_LITERAL#>.localized(),
        features: [
            .init(icon: "checkmark", text: <#PREMIUM_FEATURE_STRING_LITERAL#>.localized()),
        ],
        userCount: nil,
        offers: [
            .subscription(.init(
                id: <#YEARLY_SUBSCRIPTION_ID_STRING_LITERAL#>,
                renewalRate: .yearly,
                bestOffer: .init(baseline: .weekly),
                recommended: false,
            )),
            .subscription(.init(
                id: <#WEEKLY_SUBSCRIPTION_ID_STRING_LITERAL#>,
                renewalRate: .weekly,
                bestOffer: nil,
                recommended: false,
            )),
        ],
        defaultOffer: 0,
        tokenNameSingular: nil,
        tokenNamePlural: nil,
    )
}
```

## Onboarding configuration

`Config/OnboardingViews.swift` computes localized pages when accessed and reuses the same paywall configuration. Supply approved app copy and an existing image asset. Expand or change the page list to match the agreed onboarding flow.

```swift
import CoreUtils
import Localize_Swift

@MainActor var onboardingViews: [OnboardingViewType] {
    [
        .imageWithDescription(.init(
            title: <#ONBOARDING_TITLE_STRING_LITERAL#>.localized(),
            desc: <#ONBOARDING_DESCRIPTION_STRING_LITERAL#>.localized(),
            image: <#ONBOARDING_ASSET_NAME_STRING_LITERAL#>,
        )),
        .toggle,
        .trialPage(trialPageConfig),
    ]
}
```

## App entry point

The app owns one Account for its lifetime. AppWrapper supplies that same account, settings configuration, and shared startup behavior to the content subtree. Its closures recreate localized onboarding and paywall values after a language change.

```swift
import CoreUtils
import SwiftUI

@main
struct <#APP_TYPE_NAME#>: App {
    @State private var account: Account = .init()

    var body: some Scene {
        WindowGroup {
            AppWrapper<Account, ContentView>(
                account: self.account,
                settingsConfig: settingsConfig,
                notifications: .disabled,
                showATT: false,
                advertisingConsentProvider: .disabled,
                splashScreenConfig: .init(iconShadowConfig: nil),
                onboardingViews: { onboardingViews },
                trialPageConfig: { trialPageConfig },
                onboardingStart: nil,
                onboardingEnd: nil,
            ) { _ in
                // Ads are explicitly disabled, so this content does not consume the consent result.
                ContentView()
            }
        }
    }
}
```

For feedback-enabled apps, follow the integration reference's delegate and APNs instructions, set `feedbackEnabled: true`, and pass `notifications: .enabled(notifications)` instead. Do not combine enabled feedback with the disabled notification example above.

## Settings screen

`Settings/Views/SettingsView.swift` reads the injected account and composes the shared Settings UI. This sheet presentation uses the shared Back control. For a tab, use the corresponding back-control choice.

```swift
import CoreUtils
import Localize_Swift
import SwiftUI

struct SettingsView: View {
    @Environment(Account.self) private var account: Account

    var body: some View {
        SettingsViewInternal<Account>(
            sections: [
                .init(name: "Account".localized(), rows: [
                    .license(self.account.license),
                ]),
            ],
            devSections: [],
            trialPageConfig: trialPageConfig,
            showBack: true,
        )
        .onAppear {
            self.account.logger.logScreen(.settings)
        }
    }
}
```

For a chosen sheet route, add the following state and presentation to the app's existing root view. Replace the content placeholder with its real content instead of generating a sample screen. The sheet inherits the account and configuration from AppWrapper.

```swift
import CoreUtils
import Localize_Swift
import SwiftUI

struct ContentView: View {
    @Environment(Account.self) private var account: Account
    @State private var showingSettings: Bool = false

    var body: some View {
        NavigationStack {
            <#APP_ROOT_CONTENT_VIEW_EXPRESSION#>
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Settings".localized(), systemImage: "gearshape") {
                            self.showingSettings = true
                            self.account.logger.log(.settingsOpened)
                        }
                    }
                }
        }
        .sheet(isPresented: self.$showingSettings) {
            SettingsView()
        }
        .onAppear {
            self.account.logger.logScreen(.content)
        }
    }
}
```
