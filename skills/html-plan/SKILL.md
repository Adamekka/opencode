---
name: html-plan
description: When user asks for HTML plan.
disable-model-invocation: true
---

# HTML Plan

Use this skill only when the user explicitly asks for an HTML plan, a shareable plan page, or a published static HTML plan.

## Workflow

1. Work in `~/Coding/html-plan`.
2. Create a new uniquely named `.html` file for each plan, using a readable slug plus a timestamp such as `20260625-143012-checkout-refactor-plan.html`. Do not overwrite an existing plan file.
3. Make the plan file a self-contained static document with inline CSS and no build step. Do not rely on external scripts, external stylesheets, sample data, placeholder content, or unpublished local assets.
4. Publish from `~/Coding/html-plan` with Postplan, passing the new file path: `npx postplan upload ./<plan-file>.html`.
5. Verify the upload output includes a public URL, expected to use `https://postplan.dev`. Return the published URL and local file path.

## Visual first

- Show everything as visuals: charts for numbers and trends, tiles for headline figures, a diagram or timeline for plan steps.
- Draw charts as inline SVG in the plan file, with no chart libraries or image files, so the page stays self-contained.
- Chart rules: bar charts for comparisons, line charts for change over time, no pie charts. Label values directly instead of using a legend, start bar axes at zero, and use one accent color plus grey. Define colors as CSS variables with a dark-mode override.
- Keep text to titles, labels and one-line captions. No paragraphs.
- Sources go in a single short line at the bottom.

## Guardrails

- Do not substitute another hosting provider or hidden fallback when Postplan upload fails.
- If Postplan reports missing authentication or another upload failure, stop and report the exact failure and the local plan file path.
- Keep edits local to the new plan file in `~/Coding/html-plan` unless the user explicitly asks for additional files.
