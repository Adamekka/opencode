# Verify CoreUtils and localization

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
