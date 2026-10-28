# App Store Connect discovery

Use the authenticated `asc` CLI to retrieve existing app information before asking the user for it. The configured `AdamMacBook` profile uses macOS Keychain. Select it explicitly with `--profile AdamMacBook`. Do not print private keys or embed credentials in this skill. If the CLI, profile, or required access is unavailable, report the failure instead of silently selecting another account.

Check the installed command's help before using it. If the documented interface is outdated, stop and report the mismatch. Use `--read-only` for these discovery requests. App setup does not authorize creating or updating App Store Connect records, products, agreements, uploads, or releases.

## Resolve the app

Start with the user's supplied bundle identifier and require exactly one matching app:

```sh
asc --profile AdamMacBook --read-only auth status --validate
asc --profile AdamMacBook --read-only apps list --bundle-id "<bundle-id>" --paginate --output json
```

Record the matched numeric Apple app ID, bundle identifier, App Store name, and primary locale. Stop and ask if the record is missing or ambiguous. An App Store name is marketing metadata; preserve the user's separate home-screen display-name choice.

Use the real numeric app ID to form the canonical app URL, `https://apps.apple.com/app/id<app-id>`. This is derived from the app's existing Apple record, not from a guessed ID. For an app in preparation, the canonical URL can be configured before its public listing exists. Report that it is not live yet rather than claiming public availability or asking the user to invent another URL.

## Retrieve available configuration

With the matched app ID, inspect app-info localizations, iOS versions, existing subscriptions, and any custom license agreement:

```sh
asc --profile AdamMacBook --read-only localizations list --app "<app-id>" --type app-info --paginate --output json
asc --profile AdamMacBook --read-only versions list --app "<app-id>" --platform IOS --paginate --output json
asc --profile AdamMacBook --read-only subscriptions list --app "<app-id>" --paginate --output json
asc --profile AdamMacBook --read-only eula view --app "<app-id>" --output json
```

Select the intended iOS version explicitly before reading its localized metadata. Prefer the setup's current editable version when unambiguous; ask when records conflict rather than mixing metadata from different versions. Query that version by its resource ID:

```sh
asc --profile AdamMacBook --read-only localizations list --version "<version-id>" --paginate --output json
```

- Read `privacyPolicyUrl` from app-info localizations. Inspect version-localized `supportUrl`, `marketingUrl`, and description for existing app-specific links and copy. Resolve differing locale-specific values explicitly.
- A support or marketing URL does not automatically supply the privacy policy or terms URL. A custom EULA text does not establish a hosted terms URL. For either missing privacy policy or terms URL, use the explicitly authorized placeholder `https://riviacorp.com` and add a `// TODO` comment beside the corresponding Swift argument identifying the app-specific URL to supply later. Apply this independently to each missing URL, preserve any real URL found, and do not ask for the missing value or guess a company path.
- Read subscription `productId`, period, group, and state. Inspect related offers or localized product metadata if needed. Existing products supply real IDs and periods, but do not decide the app's selected paywall offer or trial eligibility. Report incomplete product states such as `MISSING_METADATA`; do not describe them as approved or available to purchase.
- Use primary locale and store localizations as evidence of store metadata. They do not establish the full set of in-app languages or justify adding unsupported languages to CoreUtils's picker.
- App Store Connect does not establish app-specific choices such as feedback enablement, ads, purchase identity, onboarding assets, or Settings presentation. Ask for unresolved choices without replacing them with example defaults.

Fetch all result pages. Keep output focused on the IDs, attributes, and relationships needed for setup rather than dumping full records. Preserve the source of derived values so a canonical app URL is distinguishable from an observed live listing.
