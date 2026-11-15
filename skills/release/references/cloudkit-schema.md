# Verify CloudKit schema deployment to production

This is a read-only release prerequisite for every target that uses CloudKit, including non-production builds. Inspect the exact target sources, resolved dependencies, and configuration; for a resumed release, use its recorded release snapshot. If the target does not use CloudKit, report `Not applicable`.

- Resolve every CloudKit container used by the target and its owning Apple Developer team. App Store availability, TestFlight availability, and production entitlements do not prove that its required schema is deployed.
- Use Apple's [cktool](https://developer.apple.com/icloud/ck-tool/) to export each container's live production schema to a temporary directory. Schema exports require a CloudKit management token, separate from App Store Connect credentials; use the token stored in macOS Keychain and never print or embed it in files or commands:

  ```sh
  xcrun cktool export-schema --team-id "<team-id>" \
    --container-id "<container-id>" --environment production \
    --output-file "<temporary-directory>/production.ckdb"
  ```

- Compare production with the schema required by the target build, using its authoritative checked-in schema when available. Otherwise, export the development schema with the same command and `--environment development` to a separate file, and correlate it with the target's data model and CloudKit operations. Development may contain future changes, and production may retain older fields, so compare required record types, field types, indexes, and permissions rather than requiring identical exports. For Core Data or SwiftData, verify the required development schema was initialized for the target model; matching incomplete exports cannot establish deployment.
- Report `Deployed` for a container only when all schema requirements of the target are present in production. Report `Missing changes` with the missing or incompatible definitions when they are absent, or `Unverifiable` when the required schema, container/team, tooling, or access cannot be established. A nonempty production schema alone is insufficient. This check verifies schema deployment, not the presence of user records or a successful sync.
- Stop before version changes, commits, or Linear writes if any required container has missing changes or cannot be verified. Report the blocker and recheck after it is resolved. Do not deploy, import, reset, or modify schema or records as part of this check; deployment requires a separate user request.
