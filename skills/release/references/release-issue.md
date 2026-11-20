# Linear release issue

Keep Linear release issues focused on versions, user-visible changes, and feature tests. Use only the four description sections below. The review baseline and included releases contain only versions/builds, `Not yet submitted to App Store Review`, or a brief test-only designation. Keep source-verification details, authentication/profile/key/account identifiers, local paths and commands, Git hashes, dependency revisions, automated check results or waivers, legal-workflow decisions, authorization details, and reviewer commentary out of issue descriptions, comments, and attachments. Report relevant preparation results to the user in conversation instead. Do not add a `Release scope and checks` section or equivalent.

The issue title is exactly:

```text
version (build) - short description since first-included-version (first-included-build)
```

Use the target on the left and the first included release after the review baseline on the right. Include the version and build on both sides, even when the earlier issue was canceled. Use the target on both sides if it is the only included release. Put the last submitted version/build in the description as the App Store Review baseline. Use `Not yet submitted to App Store Review` when there is no prior submission. Describe the combined changes in plain language.

```markdown
App Store Review baseline:

1.11.0 (22)

Included releases:

- 1.12.0 (23)
- 1.12.0 (24)

Summary:

- File imports pause when you leave the destination folder and resume when you return.
- If you quit before an import finishes, Files shows the unfinished items the next time you open the app.
- Subscription plans make the billed amount and period easier to find.

To Test:

- [ ] **File and gallery imports**
  - **Build 23**
    - Start importing several items. Leave the destination folder before the import finishes, then return. The import pauses while you're away and resumes without duplicates.
    - Quit during an import to a protected folder, then reopen the app. The report lists unfinished items by position and hides their names.
- [ ] **Subscription prices**
  - **Build 24**
    - Open the subscription screen with an account eligible for a trial. The billed amount and period are the most prominent price text on both plans.
```

Give each headline user-visible improvement or fix one short bullet in `Summary`. Lead with what changes for the user. Keep test setup and scenarios under `To Test`.

List each affected feature once as a Markdown task with the feature name in bold. Start new items unchecked and preserve existing results according to the rules below. Name individual games or challenges when they need separate testing. Include features affected by dependency or internal changes when the history establishes that impact. Do not turn formatting, documentation, or test-only commits into product features or claim unperformed tests passed.

Under each feature, put each relevant build on its own bold build line in chronological order. Give each scenario an indented plain bullet under that build. State any setup the tester needs, what to do, and the observable result that counts as a pass. Use the app's labels for controls and screens. Verify the expected result against the corresponding release snapshot or its requirements. If a required result is still unclear, raise it in chat. Before saving, read the checklist as a tester and make sure each scenario can be followed without guessing what should happen.

Map scenarios to the release snapshots that introduced the changes they cover. Keep relevant changes from earlier included builds and combine superseded changes into the final behavior. Backfill missing annotations for both checked and unchecked items when maintaining an existing cumulative issue. Preserve checkbox states and match existing items by feature name, ignoring annotations and Markdown emphasis. Report annotation edits separately from checkbox additions, removals, and state changes in chat.

## Preserve verified feature tests

- Always use the latest prepared release before the target as the testing baseline for previously checked features, separately from the App Store Review history used for cumulative notes. For a new release, use the latest local release marker recorded before creating the target marker. For a resumed release, use the marker immediately before the target marker, not the target itself. Treat existing checked items as verified through that baseline; do not ask the user to confirm it. Earlier changes already covered by that testing do not invalidate its results.
- Compare code and resolved dependency changes after that testing baseline with the exact target snapshot. Uncheck a completed feature only when a concrete change to its behavior, layout, accessible interaction, or affected shared logic requires retesting and verified testing does not already cover that change. A changed file, dependency revision, or inclusion in cumulative notes is not sufficient by itself; identify which tested expectation no longer applies.
- Translation or copy changes alone belong under localization testing, not a reset of every screen's functional checks. Reopen an additional feature only when the text change specifically affects its operation, tested layout, or accessible interaction. Formatting, documentation, test-only changes, and version/build metadata do not invalidate functional test results.
- Keep unaffected features checked and existing unchecked items unchecked when they remain in scope. Remove build annotations and feature tests that only cover changes through the review baseline. Keep a test when the target still changes that feature and merge overlapping tests.
