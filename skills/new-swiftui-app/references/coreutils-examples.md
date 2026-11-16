# CoreUtils integration examples

These examples are bundled with the skill. Check them against the CoreUtils declarations at the fetched Git revision before applying them. If any information is outdated, stop and report it.

The examples illustrate an explicitly chosen configuration with anonymous purchase identity, yearly and weekly subscriptions, the yearly offer selected initially, ads and feedback disabled, a welcome page followed by the paywall step, the same paywall copy at every entry point, blue as the default color, optional App Color and App Lock disabled, all backup types disabled, no onboarding callbacks or splash icon shadow, and Settings presented as a sheet. The page and paywall views show the required wiring and states; replace their layout with the app's approved design. These are example choices, not defaults for a new app. Confirm the app's choices and adapt its content and offer structure accordingly. A change in app requirements is separate from an outdated API; the latter requires stopping and reporting.

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

`Config/SettingsConfig.swift` contains the app URLs and explicit feedback, default-color, App Color and App Lock choices. This example shows the authorized privacy policy and terms placeholders for an app where those URLs are missing. Use real URLs whenever available. This configuration is passed to AppWrapper, which supplies it to Settings through the environment.

```swift
import CoreUtils
import Foundation

@MainActor let settingsConfig: SettingsConfig = .init(
    appStoreURL: .init(string: <#APP_STORE_URL_STRING_LITERAL#>)!,
    // TODO: Replace with this app's privacy policy URL.
    privacyURL: .init(string: "https://riviacorp.com")!,
    // TODO: Replace with this app's terms of service URL.
    termsURL: .init(string: "https://riviacorp.com")!,
    feedbackEnabled: false,
    defaultAppColor: .blue,
    appColor: .disabled,
    appLock: .disabled,
)
```

## Paywall configuration

`Config/PaywallConfig.swift` holds the purchase facts shared by the onboarding paywall step and every other paywall entry point. Use the app's actual subscription IDs. StoreKit supplies renewal periods, prices and introductory-offer eligibility. The default product ID must belong to this offer list. Subscription offers require an annual plan first and a weekly plan second; their StoreKit prices must make the annual plan the best value. Token offers also need localized token names, which makes this a computed `var` built when AppWrapper's closure runs.

```swift
import CoreUtils

@MainActor let paywallConfig: PaywallConfig = .init(
    offers: [
        .subscription(.init(
            id: <#YEARLY_SUBSCRIPTION_ID_STRING_LITERAL#>,
        )),
        .subscription(.init(
            id: <#WEEKLY_SUBSCRIPTION_ID_STRING_LITERAL#>,
        )),
    ],
    defaultProductID: <#YEARLY_SUBSCRIPTION_ID_STRING_LITERAL#>,
    tokenNameSingular: nil,
    tokenNamePlural: nil,
)
```

## Onboarding flow

`Config/OnboardingFlow.swift` names the app's pages and orders them around the paywall step. Expand the page enum and steps to match the agreed flow. Use `.freeUsers` for pages Premium users should skip.

```swift
import CoreUtils

// MARK: - OnboardingPage

enum OnboardingPage: Hashable {
    case welcome
}

@MainActor let onboardingFlow: OnboardingFlow<OnboardingPage> = .init(steps: [
    .page(.welcome, audience: .everyone),
    .paywall(paywallConfig),
])
```

## Onboarding pages

`Onboarding/Views/WelcomePage.swift` is one app-owned page. Each page receives a continue action that calls `OnboardingNavigator.advance()`. Supply approved app copy and an existing image asset, referenced through its generated asset symbol.

```swift
import Localize_Swift
import SwiftUI

struct WelcomePage: View {
    let next: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(.<#ONBOARDING_ASSET_SYMBOL#>)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true)
            Text(<#ONBOARDING_TITLE_STRING_LITERAL#>.localized())
                .font(.largeTitle.bold())
            Text(<#ONBOARDING_DESCRIPTION_STRING_LITERAL#>.localized())
                .foregroundStyle(.secondary)
            Spacer()
            Button("Continue".localized(), action: self.next)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
```

## Paywall design

`Paywall/Views/AppPaywall.swift` draws the paywall from `PaywallContext`. CoreUtils wraps it with Close and Restore, so it must not hide the navigation bar or toolbar. It covers every loading state, shows "no payment now" copy only for an eligible free trial, and disables selection and Continue during a purchase.

```swift
import CoreUtils
import Localize_Swift
import SwiftUI

struct AppPaywall: View {
    let context: PaywallContext

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(<#PAYWALL_TITLE_STRING_LITERAL#>.localized())
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                switch self.context.state {
                    case .loading:
                        ProgressView()

                    case let .failed(message):
                        Text(message)
                            .multilineTextAlignment(.center)
                        Button("Try Again".localized()) { self.context.retry() }

                    case let .ready(offers):
                        ForEach(offers) { offer in
                            let selected: Bool = offer.id == self.context.selectedProductID
                            Button {
                                self.context.select(offer.id)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(offer.displayPrice)
                                            .font(.headline)
                                        Text(offer.billingDescription)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if case let .bestValue(savingsPercentage, _, _) = offer.value {
                                        Text(String(format: "Save %ld%%".localized(), savingsPercentage))
                                            .font(.caption.bold())
                                    }
                                }
                                .padding()
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            selected ? Color.accentColor : .secondary,
                                            lineWidth: selected ? 2 : 1,
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(self.context.isPurchasing)
                            .accessibilityAddTraits(selected ? .isSelected : [])
                        }
                        if self.context.selectedOfferHasFreeTrial {
                            Text("No payment now".localized())
                        }
                        Button("Continue".localized()) { self.context.purchase() }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .disabled(self.context.isPurchasing)
                }
            }
            .padding()
        }
    }
}
```

## App entry point

The app owns one Account for its lifetime. AppWrapper supplies that same account, settings configuration, paywall and shared startup behavior to the content subtree. Its onboarding presents the app's pages and the paywall step.

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
                kvsBackup: .disabled,
                archiveBackup: .disabled,
                cloudKitBackup: .disabled,
                showATT: false,
                advertisingConsentProvider: .disabled,
                splashScreenConfig: .init(iconShadowConfig: nil),
                onboarding: { onboardingFlow },
                onboardingPage: { page, navigator in
                    switch page {
                        case .welcome:
                            WelcomePage { navigator.advance() }
                    }
                },
                paywallConfig: { paywallConfig },
                paywall: { _, context in
                    // This app shows the same paywall copy at every entry point, so it ignores the source.
                    AppPaywall(context: context)
                },
                onboardingStart: nil,
                onboardingEnd: nil,
                // Keep app content distinct from the onboarding and paywall closures.
                // swiftlint:disable:next trailing_closure
                content: { _ in
                    // Ads are explicitly disabled, so this content does not consume the consent result.
                    ContentView()
                },
            )
        }
    }
}
```

For feedback-enabled apps, follow the integration reference's delegate and APNs instructions, set `feedbackEnabled: true`, declare the delegate in the app struct, and pass `notifications: .enabled(notifications)` to `AppWrapper`:

```swift
@UIApplicationDelegateAdaptor(FeedbackApplicationDelegate.self)
private var notifications
```

## Settings screen

`Settings/Views/SettingsView.swift` reads the injected account and composes the shared Settings UI. Its paywall rows present the `AppPaywall` that AppWrapper received. This sheet presentation uses the shared Back control. For a tab, pass `showBack: false`.

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
