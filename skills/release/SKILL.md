---
name: release
description: Prepare an app release by verifying production, selecting its version/build, committing a release marker, and maintaining one cumulative Linear issue for all changes not yet in production. Use when the user asks to release an app or invokes this skill for a feature or bug-fix release.
---

# Release

Each new release request produces a new build. For a target explicitly not intended for production, keep the current marketing version and increment only the build. Otherwise, keep an existing unreleased marketing version unless a bug-fix release is being expanded into a feature release. Maintain one active cumulative Linear release issue until the release reaches production. Its notes cover all changes since production, including earlier unreleased versions. Inspect and report the current state before making release changes.

## Inspect and report the current state

- Read the repository instructions and relevant project documentation. Inspect the worktree without editing. If pending app changes might belong in the release but their inclusion is unclear, ask one focused question and wait.
- Read the app's actual version, build, bundle identifier, and platform. For Xcode, identify the app target and its version settings across configurations; test-target versions are separate.
- Use the authenticated `asc` CLI as described below to verify the publicly available version and its associated build. Also inspect newer uploaded versions and their review, release, and TestFlight states. Approval, an upload, or TestFlight availability does not establish that a version is in production.
- If App Store Connect access is unavailable, query Apple's live public App Store lookup by the app's bundle identifier and relevant storefront. Identify the platform and storefront checked. Report the public version and release date, and disclose that the lookup does not expose its build or private release states. Do not substitute Git markers or Linear statuses for evidence of public availability.
- Establish whether the app has ever been in production, including historical releases. A missing public lookup result or unavailable store access does not establish that it has never shipped. If it has never been in production, ask whether this target build is intended to go to production and wait, unless the user has already explicitly answered for this target. A yes keeps the legal-page workflow unchanged; a no uses build-only versioning and skips the entire legal-page section below. Apps with any prior production release always keep that section, even when the target build is unreleased. Preserve the answer when resuming the same target; ask again for a new target while the app has never shipped. Production intent does not authorize publishing.
- Enumerate release commits on the current branch's first-parent history whose entire subject matches `^[0-9]+\.[0-9]+\.[0-9]+ \([0-9]+\)$`. Match the production version/build to its release commit. When only the public version is available, use a Git build only if that version maps unambiguously to one release marker and no other evidence conflicts; state that Git supplied the build. If multiple builds share that version, require App Store Connect evidence or a user-confirmed build and commit. Never assume the newest same-version marker is production.
- Resolve the app's existing Linear project and owning team. Inspect its release issues and correlate them with Git and the store. Identify the existing active issue covering the unreleased changes, even when its title names an earlier version or build; reuse that issue rather than creating another issue for the new target. List all known versions/builds after the production boundary, with their Git, store, and Linear states distinguished. Include local releases that were never uploaded or whose Linear issues were canceled when their changes remain in the target, but do not reuse canceled issues as the active release issue. If the destination or history boundary is ambiguous, ask before proceeding.
- Complete the CoreUtils and localization checks below before release changes. Include their results in the current-state report.
- Before updating files, committing, or changing Linear, tell the user what is in production, all known versions/builds not in production and their states, the current app configuration, changes after the latest release marker, CoreUtils freshness and localization results, and any uncertainty or unavailable access. Include the sources checked, the proposed target when known, and whether legal-page work is required or explicitly skipped. If production history or the applicable history boundary cannot be resolved, report what is known, ask one focused question, and stop before release changes.

## Verify CoreUtils and localization

These are release prerequisites. Inspect the exact app sources and dependency revision being released; for a resumed release, use its recorded release snapshot rather than later worktree changes.

- Read the app's CoreUtils dependency requirement and resolved revision. Verify the latest authoritative upstream revision using the configured repository and branch, for example `git -C ../CoreUtils ls-remote origin "refs/heads/<configured-branch>"` after confirming that origin matches the dependency repository. Do not treat local HEAD or a cached remote-tracking ref as proof of freshness. For a version-based requirement, verify the latest published version allowed by that requirement; ask if the intended update policy is ambiguous. Require the app's resolved CoreUtils dependency to be current. Report an outdated or unverifiable dependency and stop before version changes, commits, or Linear writes.
- Use `../CoreUtils` to inspect the shared library. Verify that the sources and localization resources checked match the revision the app will ship. Uncommitted local translations cannot establish that the resolved remote dependency is localized. If the checkout differs, inspect an isolated snapshot of the resolved revision or report the mismatch and stop; do not reset or overwrite another worktree.
- Run the project's installed `genstrings` command for both production source trees, capturing output in a temporary directory. This is the custom extractor available on PATH, not Xcode's different `xcrun genstrings` command. Resolve the app's actual production source root and keep generated output outside tracked localization resources:

  ```sh
  genstrings "<app-source-root>" > "<temporary-directory>/app.strings"
  genstrings "../CoreUtils/Sources" > "<temporary-directory>/coreutils.strings"
  ```

- Check extraction succeeded and inspect diagnostics and generated output; the extractor can print errors without a failing exit code. Compare each extracted key against the shipped localization resources for every language supported by the app, including the corresponding CoreUtils resources. Check missing keys, empty values, and untranslated placeholders. Do not classify valid proper names or shared technical terms as missing translations merely because they match the source language.
- Key extraction alone does not prove localization completeness. Inspect user-facing text that bypasses the project's localization calls and any dynamic keys the extractor cannot discover. Do not report a successful extraction as a successful translation check.
- If either the app or CoreUtils is not fully localized, report the affected repository, languages, files, and missing or untranslated keys, then stop. If a required check cannot be completed, report the blocker and stop. Do not automatically translate strings, update the dependency, commit, or push CoreUtils as part of this preflight. Resume the release only after the blockers are resolved and these checks pass.

## Query App Store Connect with asc

The installed client uses the `AdamMacBook` authentication profile stored in macOS Keychain. Select it explicitly with `--profile AdamMacBook`; subsequent queries do not need the original downloaded `.p8` file. Do not embed credentials in the skill or read private key contents into tool output. If the client or profile is unavailable, report the failure and follow the public-lookup rules above rather than silently selecting another account.

Validate authentication, then resolve the app by its actual bundle identifier. Replace the placeholders with the resolved app ID and platform, such as `IOS` or `MAC_OS`. Require an unambiguous matching app before querying its release state.

```sh
asc --profile AdamMacBook auth status --validate
asc --profile AdamMacBook apps list --bundle-id "<bundle-id>" --paginate --output json
asc --profile AdamMacBook versions list --app "<app-id>" --platform "<platform>" \
  --include build,appStoreVersionPhasedRelease --paginate --output json
asc --profile AdamMacBook builds list --app "<app-id>" --platform "<platform>" \
  --include preReleaseVersion,buildBetaDetail --processing-state all --paginate --output json
```

- Fetch all pages and states so pending versions, failed uploads, and expired builds remain visible. Do not limit the inspection to the latest upload or active TestFlight builds.
- Read the marketing version from each app store version's `attributes.versionString`. Treat `appVersionState == READY_FOR_DISTRIBUTION` as released; use the legacy `appStoreState == READY_FOR_SALE` only when `appVersionState` is absent. Historical versions can retain these states, so select the newest released version for the target platform and check the public storefront if current availability is uncertain. Report any phased release from the included `appStoreVersionPhasedRelease` resource.
- Obtain the production build from that version's `relationships.build.data` reference. Match its type and ID to the resource in `included` and read the build's `attributes.version`. Never substitute the highest uploaded build number. If the relationship or included resource is missing, resolve it through App Store Connect or stop with the missing evidence.
- For uploaded builds, resolve `preReleaseVersion` to get their marketing version and platform. Inspect `processingState`, `expired`, and the included `buildBetaDetail` internal/external states to distinguish processing, internal testing, external submission, and expiration. Build expiration describes TestFlight availability; it does not mean the production app has expired. Correlate these results with the app store version records to distinguish beta and production review states.
- These commands authorize read-only inspection. Uploading, submitting for review, changing TestFlight distribution, or releasing an app still requires a separate user request.

## Determine the release

- For an app confirmed never to have been in production, record `Not yet in production` instead of a production version/build. Use an initial history boundary established in project documentation or explicitly confirmed by the user in place of the production commit throughout this workflow, including cumulative notes, included releases, and Linear verification. Record that boundary and its source in the issue description so a resumed release can recover it. Ask where that history should begin if it is unresolved; never invent a production marker. Keep the existing unreleased marketing version and increment the build for a new request. Comparisons against a production version apply only when one exists. If there is no previous release marker, report that explicitly and use the new target as the first included release.
- Distinguish a new release from a request to resume the same unfinished release. For a resume, retain its target version/build instead of calculating another bump. Recheck production; if production advanced, refresh the cumulative history boundary and report the revised state before making changes. If the release commit already exists, end the notes at that commit and skip the version update and commit steps. If the target is already in production, report that it has shipped; additional changes require a new version. If the unfinished target cannot be recovered from task context and Git, ask before proceeding.
- Record the latest local release marker, the verified production release commit or established initial history boundary, and the earliest unreleased version/build after that boundary before making a new marker. The latest local marker establishes the previous prepared build. The production commit is the exclusive start of the cumulative notes, even when several local release markers follow it. If a required history boundary is unresolved, ask where that history should begin.
- For a new release request, increment the current build number by one. If the user explicitly says the target is not intended for production, keep the current marketing version unchanged regardless of whether the changes are features or bug fixes, even when that version is already in production. Do not ask for a release kind solely to choose a version in this case. A resume still retains its existing version/build.
- Otherwise, the user supplies the release kind. If the current marketing version is already in production, a feature release increments the minor version and resets the patch to zero, while a bug-fix release increments the patch. Keep the major version unchanged.
- For targets intended for production, if the current marketing version is still unreleased, keep it for the next build. For an app with a production release, upgrade an unreleased bug-fix version to the next minor version with patch zero only when the scope expands to a feature release. Determine that minor version from the verified production version. Do not increment the minor version again for another build of an already prepared feature release, and do not downgrade that feature version for subsequent bug fixes. For example, another feature build of unreleased `2.1.0 (30)` is `2.1.0 (31)`; expanding an unreleased `2.0.4` bug-fix release into a feature release can change it to `2.1.0`.
- A marketing version already published to production is immutable for subsequent production releases. For targets intended for production, never prepare additional changes under that version, even with a higher build number, and require the target marketing version to be numerically greater than production. For all targets, require the marketing version to be no lower than the previous prepared marketing version and a strictly greater build number for each new release request. An explicit version/build takes precedence only when these rules permit it. Unless the target is explicitly not intended for production, ask one focused question for a new release request if neither the release kind nor a full version/build was supplied. Resolve conflicting version information with the user rather than guessing.

## Prepare the release notes

Read all commits after the verified production commit through the current app changes being released, or through the existing target release commit when resuming. Squash the notes into the final combined behavior across every intervening unreleased version, accounting for reversions and follow-up fixes. Inspect commit bodies, changed files, and relevant documentation when subjects alone do not explain the result. Earlier Linear issues are supporting context, not the history boundary.

The issue title is exactly:

```text
version (build) - short description since first-unreleased-version (first-unreleased-build)
```

Use the actual target version/build on the left and the earliest unreleased version/build included in the cumulative release after `since`. Include the build on both sides. This is the first included release after the production commit, even when its issue was canceled; if no earlier unreleased marker exists, use the new target itself. Keep the verified production version/build in the description as the history baseline, not after `since` in the title. Describe the combined main changes in plain language. The issue description records the production baseline and all included release versions before the summary and test list:

```markdown
Production:

production-version (production-build), source and production commit

Included releases:

- version (build)
- another unreleased version (build)

Summary:

A concise summary of all changes since production.

To Test:

- [ ] Affected feature
- [ ] Another affected feature
```

Summarize user-visible improvements and material fixes rather than reproducing the commit log. List each affected feature once as an unchecked Markdown task under `To Test:`. Preserve a checked state only while its test result still applies to the target release. Compare code and dependency changes since the feature's last verified tested build or commit; uncheck it when changed behavior or affected shared logic requires retesting, unless verified testing already covers those changes. Keep unaffected features checked and existing unchecked items unchecked. Name individual games or challenges when they need separate testing. Keep the list at feature level instead of enumerating every behavior, edge case, or implementation detail. Include features affected by dependency or internal changes when the history establishes that impact. Do not turn formatting, documentation, or test-only commits into product features or claim unperformed tests passed.

## Update the app's website legal pages

Skip this entire section only when the app has never been in production and the user explicitly says this target build is not intended for production. Report that legal-page work was skipped and why; do not claim the pages were verified. All other prepared releases must include a review of the app's terms of use and privacy policy in `/Users/adamekka/Coding/riviacorp.com`. Use the exact target build's source, resolved dependencies, and backend behavior, including builds not yet in production. On a resumed release, use its recorded snapshot rather than later worktree changes.

Read the website's repository instructions and `docs/README.md` using the `projects-docs` skill. Update the affected legal pages when the build changes their accuracy, including permissions, data collection, external services, storage/deletion, subscriptions, user content, and feature limitations. Preserve existing public policy URLs. Resolve material unknowns with the user rather than inventing practices or legal commitments. Update document dates only when their text changes, and maintain any existing build-verification record even when no legal wording changes.

Run the website's relevant build and link checks, review the final text, and commit its changes separately from the app release marker. Do not include unrelated website changes. Report the website commit and the build it covers, or explicitly report that the existing pages remain accurate. Website deployment follows the website's own instructions and the release request's publishing authorization; a local update is not evidence that the public pages have changed. Report any remaining publication blocker.

## Commit and maintain the release issue

1. Update the app's version/build in its canonical configuration and all applicable app configurations. Preserve unrelated target settings and production data.
2. Load the `git-commit` skill and perform the configured checks relevant to the committed changes. Inspect the final diff and resolve failures within scope before committing. Honor the repository's review requirements.
3. Use the `review` skill for a review round before committing and updating Linear, for both production-intended and non-production builds. Review the exact target snapshot and cumulative changes, version/build settings, dependency and localization checks, release notes and test coverage, and legal-page work when required. Fix verified findings within the authorized scope and rerun affected checks; keep the preflight blockers and publishing permissions unchanged. Stop and report unresolved findings or required decisions instead of claiming the release is ready. For a resume with an existing release commit, review that recorded snapshot without silently changing it or skipping the review.
4. Commit only the release changes with the exact subject `version (build)`, for example `2.1.0 (30)`. This release marker intentionally overrides the usual Conventional Commit subject format so future releases can find the history boundary. Preserve the `git-commit` skill's verified model-author trailer requirement.
5. Maintain one active cumulative Linear release issue in the resolved app project and team. Search all release issues for an existing active issue covering changes not yet in production, not just an issue whose title matches the new target. Update that original issue's target title, included releases, cumulative summary, and test list. Apply the retesting rule above to its checked items; preserve assignment, status, priority, and unrelated labels. Merge overlapping feature tests instead of duplicating them. Create a new issue only when no active issue covers the unreleased changes. The release request authorizes creating or updating this cumulative issue. Leave canceled and historical issues unchanged. When correcting an accidentally created duplicate, consolidate its unique content into the original issue and delete the obsolete duplicate when the user requests deletion. Apply these defaults to a newly created issue unless the user explicitly overrides them:
   - Status: resolve `Ready for Testing` in the app's team. If it is unavailable, ask instead of choosing another status.
   - Assignee: resolve and assign the authenticated user, `me`.
   - Priority: High, Linear priority `2`.
   - Labels: inspect the team's available active issue labels and infer applicable labels from the release kind and actual changes. Use existing labels and respect exclusive label groups. When correcting an existing release issue, preserve unrelated labels.
6. Read the issue back to verify its project, target and earliest unreleased version/build in the title, verified production baseline in the description, included versions, complete cumulative description, feature checkboxes, status, assignee, priority, and labels. Verify any requested obsolete-issue deletion separately. Report the production and target versions/builds, covered unreleased versions, commit hash, issue link, review and verification results, and legal-page completion or the explicit skip reason.

If an operation fails or has an uncertain outcome, inspect the actual Git/Linear state before retrying. Resume the same release without incrementing again or duplicating a commit or issue. If the commit succeeded but Linear failed, preserve the commit and report the remaining issue-update blocker. A later independent release request creates a new build and follows the marketing-version rules above. Pushing, tagging, archiving, and publishing require their own request.
