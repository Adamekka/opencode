# Linear release issue

Keep Linear release issues focused on versions, user-visible changes, and feature tests. Use only the four description sections below. Production and included releases contain only versions/builds, `Not yet in production`, or a brief test-only designation. Keep source-verification details, authentication/profile/key/account identifiers, local paths and commands, Git hashes, dependency revisions, automated check results or waivers, legal-workflow decisions, authorization details, and reviewer commentary out of issue descriptions, comments, and attachments. Report relevant preparation results to the user in conversation instead. Do not add a `Release scope and checks` section or equivalent.

The issue title is exactly:

```text
version (build) - short description since first-unreleased-version (first-unreleased-build)
```

Use the actual target version/build on the left and the earliest unreleased version/build included in the cumulative release after `since`. Include the build on both sides. This is the first included release after the production commit, even when its issue was canceled; if no earlier unreleased marker exists, use the new target itself. Keep the verified production version/build in the description as the history baseline, not after `since` in the title. Describe the combined main changes in plain language. The issue description records the production baseline and all included release versions before the summary and test list:

```markdown
Production:

production-version (production-build)

Included releases:

- version (build)
- another unreleased version (build)

Summary:

A concise summary of all changes since production.

To Test:

- [ ] **Affected feature**
  - **earlier-build:** earlier included change
  - **target-build:** specific change
- [ ] **Another affected feature**
  - **target-build:** specific change
```

Summarize user-visible improvements and material fixes rather than reproducing the commit log. List each affected feature once as a Markdown task under `To Test:`. New items start unchecked; preserve existing results according to the rules below. Name individual games or challenges when they need separate testing. Keep the list at feature level instead of enumerating every behavior, edge case, or implementation detail. Include features affected by dependency or internal changes when the history establishes that impact. Do not turn formatting, documentation, or test-only commits into product features or claim unperformed tests passed.

Put the bold feature name on the checkbox line. Under it, use one indented plain bullet per build, with a bold build number and a concise description of what changed. Keep builds in chronological order and each build on its own line, without inline parentheses or semicolons. Build-detail bullets are not checkboxes. Map changes to their actual release snapshots rather than assigning all cumulative changes to the latest build. Keep relevant changes from earlier included builds and combine superseded changes into the final behavior. Backfill missing annotations for both checked and unchecked items when maintaining an existing cumulative issue. Preserve checkbox states and match existing items by feature name, ignoring annotations and Markdown emphasis. Annotation edits are wording changes, not checkbox additions, removals, or state changes; report them separately in chat.

## Preserve verified feature tests

- Always use the latest prepared release before the target as the testing baseline for previously checked features, separately from the production history used for cumulative notes. For a new release, use the latest local release marker recorded before creating the target marker. For a resumed release, use the marker immediately before the target marker, not the target itself. Treat existing checked items as verified through that baseline; do not ask the user to confirm it. Earlier unreleased changes already covered by that testing do not invalidate its results.
- Compare code and resolved dependency changes after that testing baseline with the exact target snapshot. Uncheck a completed feature only when a concrete change to its behavior, layout, accessible interaction, or affected shared logic requires retesting and verified testing does not already cover that change. A changed file, dependency revision, or inclusion in cumulative notes is not sufficient by itself; identify which tested expectation no longer applies.
- Translation or copy changes alone belong under localization testing, not a reset of every screen's functional checks. Reopen an additional feature only when the text change specifically affects its operation, tested layout, or accessible interaction. Formatting, documentation, test-only changes, and version/build metadata do not invalidate functional test results.
- Keep unaffected features checked and existing unchecked items unchecked. Merge overlapping tests rather than adding another item for a feature already covered by the checklist.
