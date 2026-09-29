---
name: html-plan
description: When user asks for HTML plan.
---

# HTML Plan

Use this skill only when the user explicitly asks for an HTML plan, a shareable plan page, or a published static HTML plan.

## Workflow

1. Work in `~/Coding/html-plan`.
2. Create a new uniquely named `.html` file for each plan, using a readable slug plus a timestamp such as `20260625-143012-checkout-refactor-plan.html`. Do not overwrite an existing plan file.
3. Make the plan file a self-contained static document with inline CSS and no build step. Do not rely on external scripts, external stylesheets, sample data, placeholder content, or unpublished local assets.
4. Publish from `~/Coding/html-plan` with Postplan, passing the new file path: `npx postplan upload ./<plan-file>.html`.
5. Verify the upload output includes a public URL, expected to use `https://postplan.dev`. Return the published URL and local file path.

## Guardrails

- Do not substitute another hosting provider or hidden fallback when Postplan upload fails.
- If Postplan reports missing authentication or another upload failure, stop and report the exact failure and the local plan file path.
- Keep edits local to the new plan file in `~/Coding/html-plan` unless the user explicitly asks for additional files.
