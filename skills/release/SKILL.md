---
name: release
description: Prepare a new app release by bumping its version/build, committing a release marker, and creating a Linear issue with a summary and affected features to test. Use when the user asks to release an app or invokes this skill for a feature or bug-fix release.
---

# Release

Each new release request produces a new version and build. Complete the version change, release commit, and Linear issue for the current app.

## Determine the release

- Distinguish a new release from a request to resume the same unfinished release. For a resume, retain its target version/build and original history boundary instead of calculating another bump. If its release commit already exists, find the previous release marker starting at that commit's first parent, end the notes at the existing release commit, and skip the version update and commit steps. If the unfinished release's target cannot be recovered from the task context and Git, ask before proceeding.
- Read the repository instructions and relevant project documentation. Inspect the worktree before editing and keep unrelated changes out of the release commit. If pending app changes might belong in the release but their inclusion is unclear, ask one focused question and wait.
- Read the app's actual version and build configuration. For Xcode, identify the app target and its version settings across configurations; test-target versions are separate.
- Find the nearest release commit on the current branch's first-parent history whose entire subject matches `^[0-9]+\.[0-9]+\.[0-9]+ \([0-9]+\)$`. Record that commit before making a new release marker. It is the exclusive start of the release's commit range. If no such commit exists, ask where the release history should begin.
- The user supplies the release kind. A feature release increments the minor version and resets the patch to zero. A bug-fix release increments the patch. Keep the major version unchanged and increment the build number by one for either kind. Use the current app version/build as the starting point. An explicitly supplied version/build takes precedence. If neither the kind nor a full version/build was supplied, ask one focused question and wait.
- Require the new version/build to advance the previous release, with a strictly greater build number. Resolve inconsistent app configurations or conflicting version information with the user instead of guessing.
- Resolve the app's existing Linear project and its owning team through the available Linear tools and repository context. If the destination is ambiguous, ask before creating anything.

## Prepare the release notes

Read all commits after the previous release marker through the current app changes being released. Inspect commit bodies, changed files, and relevant documentation when subjects alone do not explain the result. Use the final combined behavior, accounting for reversions and follow-up fixes.

The issue title is exactly:

```text
version (build) - short description of this release
```

Use the actual version/build, such as `2.1.0 (30)`. Describe the main changes in plain language. The issue description has these sections:

```markdown
Summary:

A concise summary of the changes in this release.

To Test:

- [ ] Affected feature
- [ ] Another affected feature
```

Summarize user-visible improvements and material fixes rather than reproducing the commit log. List each affected feature once as an unchecked Markdown task under `To Test:`. Preserve existing checked states when correcting a release issue. Name individual games or challenges when they need separate testing. Keep the list at feature level instead of enumerating every behavior, edge case, or implementation detail. Include features affected by dependency or internal changes when the history establishes that impact. Do not turn formatting, documentation, or test-only commits into product features or claim unperformed tests passed.

## Commit and create the issue

1. Update the app's version/build in its canonical configuration and all applicable app configurations. Preserve unrelated target settings and production data.
2. Load the `git-commit` skill and perform the configured checks relevant to the committed changes. Inspect the final diff and resolve failures within scope before committing. Honor the repository's review requirements.
3. Commit only the release changes with the exact subject `version (build)`, for example `2.1.0 (30)`. This release marker intentionally overrides the usual Conventional Commit subject format so future releases can find the history boundary. Preserve the `git-commit` skill's verified model-author trailer requirement.
4. Create a new Linear issue in the resolved app project and team using the prepared title and description. The release request authorizes creating this issue. Check for an existing issue for this same release before creating it. Apply these defaults unless the user explicitly overrides them:
   - Status: resolve `Ready for Testing` in the app's team. If it is unavailable, ask instead of choosing another status.
   - Assignee: resolve and assign the authenticated user, `me`.
   - Priority: High, Linear priority `2`.
   - Labels: inspect the team's available active issue labels and infer applicable labels from the release kind and actual changes. Use existing labels and respect exclusive label groups. When correcting an existing release issue, preserve unrelated labels.
5. Read the issue back to verify its project, title, complete description, feature checkboxes, status, assignee, priority, and inferred labels. Report the version/build, commit hash, issue link, and relevant verification results.

If an operation fails or has an uncertain outcome, inspect the actual Git/Linear state before retrying. Resume the same release without incrementing again or duplicating a commit or issue. If the commit succeeded but Linear failed, preserve the commit and report the remaining issue-creation blocker. A later independent release request still creates a new version. Pushing, tagging, archiving, and publishing require their own request.
