---
name: html-plan
description: When user asks for HTML plan.
---

# HTML Plan

Use this skill only when the user explicitly asks for an HTML plan, a shareable plan page, or a published static HTML plan.

## Workflow

1. Gather enough context to write the plan. Inspect the relevant project files first when the plan depends on an existing codebase.
2. Work in `~/Coding/html-plan`.
3. Create a new uniquely named `.html` file for each plan, using a readable slug plus a timestamp such as `20260625-143012-checkout-refactor-plan.html`. Do not overwrite an existing plan file.
4. Make the plan file a self-contained static document with inline CSS and no build step. Do not rely on external scripts, external stylesheets, sample data, placeholder content, or unpublished local assets.
5. Write the plan as production-facing planning material for the user's actual request. Include the goal, current understanding, implementation steps, verification steps, risks or open questions, and clear success criteria.
6. Validate that the new plan file exists, is non-empty, starts with `<!doctype html>`, and has a useful `<title>`.
7. Publish from `~/Coding/html-plan` with Postplan, passing the new file path: `npx postplan upload ./<plan-file>.html`.
8. Capture the published URL from the command output and return it to the user with the local file path.

## Guardrails

- Do not publish a generic template. The HTML must reflect the user's concrete request and the current repository context when relevant.
- Do not substitute another hosting provider or hidden fallback when Postplan upload fails.
- If Postplan reports missing authentication or another upload failure, stop and report the exact failure and the local plan file path.
- Keep edits local to the new plan file in `~/Coding/html-plan` unless the user explicitly asks for additional files.

## Verification

- Inspect the final HTML before upload for obvious broken structure, placeholder text, and developer-facing copy.
- Run the Postplan upload command from `~/Coding/html-plan` and verify the output includes a public URL, expected to use the `https://postplan.dev` base URL.
- In the final response, include the published URL and mention if upload could not be completed.
