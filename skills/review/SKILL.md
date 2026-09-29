---
name: review
description: When user asks for review.
---

# Review Skill

## Method

- Treat technical debt and convention drift as first-class review findings. Do not omit them just because there are also security or correctness concerns.
- If no meaningful technical-debt findings exist, say that explicitly.
- When implementing fixes from a whole-program review, put each independent fix or tightly related group of fixes on a separate branch based on the original review base so the fixes can be reviewed independently.

## Output

- Assign every finding a unique sequential number, starting at 1, and include that number in its heading or label.
- For each finding, show implementation difficulty as `Low`, `Medium`, or `High`, considering the change's scope, risk, dependencies, and verification effort.
