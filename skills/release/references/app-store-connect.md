# Query App Store Connect with asc

Use the machine's default `asc` credential and do not pass `--profile`; profile names are machine-specific. Pass `--read-only` so the client refuses any mutating request. Do not embed credentials in the skill or read private key contents into tool output. If the client is missing or no default credential validates, report the failure and follow the public App Store lookup rules in [the release skill](../SKILL.md) rather than selecting another credential.

Validate authentication, then resolve the app by its actual bundle identifier. Replace the placeholders with the resolved app ID and platform, such as `IOS` or `MAC_OS`. Require an unambiguous matching app before querying its release state.

```sh
asc --read-only auth status --validate
asc --read-only apps list --bundle-id "<bundle-id>" --paginate --output json
asc --read-only versions list --app "<app-id>" --platform "<platform>" \
  --include build,appStoreVersionPhasedRelease --paginate --output json
asc --read-only builds list --app "<app-id>" --platform "<platform>" \
  --include preReleaseVersion,buildBetaDetail --processing-state all --paginate --output json
asc --read-only review submissions list --app "<app-id>" --platform "<platform>" \
  --include appStoreVersionForReview,items --paginate --output json
```

- Fetch all pages and states so pending versions, failed uploads, and expired builds remain visible. Do not limit the inspection to the latest upload or active TestFlight builds.
- Read the marketing version from each app store version's `attributes.versionString`. Treat `appVersionState == READY_FOR_DISTRIBUTION` as released; use the legacy `appStoreState == READY_FOR_SALE` only when `appVersionState` is absent. Historical versions can retain these states, so select the newest released version for the target platform and check the public storefront if current availability is uncertain. Report any phased release from the included `appStoreVersionPhasedRelease` resource.
- Obtain the production build from that version's `relationships.build.data` reference. Match its type and ID to the resource in `included` and read the build's `attributes.version`. Never substitute the highest uploaded build number. If the relationship or included resource is missing, resolve it through App Store Connect or stop with the missing evidence.
- For uploaded builds, resolve `preReleaseVersion` to get their marketing version and platform. Inspect `processingState`, `expired`, and the included `buildBetaDetail` internal/external states to distinguish processing, internal testing, external submission, and expiration. Build expiration describes TestFlight availability; it does not mean the production app has expired. Correlate these results with the app store version records to distinguish beta and production review states.
- Find the most recent submission by `submittedDate` that contains an app version for the target platform. Submitted builds count even if Apple rejects them or the developer withdraws them after submission. Exclude unsent drafts, TestFlight beta review, and submissions for other items only.
- Resolve `appStoreVersionForReview` or the app-version item. If the item is missing from the included data, inspect it with `asc --read-only review items list --submission "<submission-id>" --include appStoreVersion --paginate --output json`. Match the app version and build to the version and build records above. If the submitted build is missing or the attached build changed since submission, require dated submission evidence or user confirmation of the submitted build and Git marker. A public storefront can establish the shipped version. Ask for the latest submission details if private history is unavailable or inconclusive.
- These commands authorize read-only inspection. Uploading, submitting for review, changing TestFlight distribution, or releasing an app still requires a separate user request.
