# Query App Store Connect with asc

The installed client uses the `AdamMacBook` authentication profile stored in macOS Keychain. Select it explicitly with `--profile AdamMacBook`, and pass `--read-only` so the client refuses any mutating request; subsequent queries do not need the original downloaded `.p8` file. Do not embed credentials in the skill or read private key contents into tool output. If the client or profile is unavailable, report the failure and follow the public App Store lookup rules in [the release skill](../SKILL.md) rather than silently selecting another account.

Validate authentication, then resolve the app by its actual bundle identifier. Replace the placeholders with the resolved app ID and platform, such as `IOS` or `MAC_OS`. Require an unambiguous matching app before querying its release state.

```sh
asc --profile AdamMacBook --read-only auth status --validate
asc --profile AdamMacBook --read-only apps list --bundle-id "<bundle-id>" --paginate --output json
asc --profile AdamMacBook --read-only versions list --app "<app-id>" --platform "<platform>" \
  --include build,appStoreVersionPhasedRelease --paginate --output json
asc --profile AdamMacBook --read-only builds list --app "<app-id>" --platform "<platform>" \
  --include preReleaseVersion,buildBetaDetail --processing-state all --paginate --output json
```

- Fetch all pages and states so pending versions, failed uploads, and expired builds remain visible. Do not limit the inspection to the latest upload or active TestFlight builds.
- Read the marketing version from each app store version's `attributes.versionString`. Treat `appVersionState == READY_FOR_DISTRIBUTION` as released; use the legacy `appStoreState == READY_FOR_SALE` only when `appVersionState` is absent. Historical versions can retain these states, so select the newest released version for the target platform and check the public storefront if current availability is uncertain. Report any phased release from the included `appStoreVersionPhasedRelease` resource.
- Obtain the production build from that version's `relationships.build.data` reference. Match its type and ID to the resource in `included` and read the build's `attributes.version`. Never substitute the highest uploaded build number. If the relationship or included resource is missing, resolve it through App Store Connect or stop with the missing evidence.
- For uploaded builds, resolve `preReleaseVersion` to get their marketing version and platform. Inspect `processingState`, `expired`, and the included `buildBetaDetail` internal/external states to distinguish processing, internal testing, external submission, and expiration. Build expiration describes TestFlight availability; it does not mean the production app has expired. Correlate these results with the app store version records to distinguish beta and production review states.
- These commands authorize read-only inspection. Uploading, submitting for review, changing TestFlight distribution, or releasing an app still requires a separate user request.
