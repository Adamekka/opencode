---
name: codex-rate-limit-reset
description: Use when the user asks when their Codex rate limit resets, how much quota is left, whether reset coupons are available, or what the current rate-limit status is.
---

# Codex Rate Limit Reset

## Overview

Reads Codex Desktop's local session snapshots and persisted app state to report the latest known standard rate-limit windows and reset-coupon metadata.

When auth is available, prefers the live reset-credit endpoint to report exact coupon expirations. Falls back to local app-state metadata only when the live lookup is unavailable.

## Workflow

1. Run the helper script from the skill directory:

```bash
python3 ~/.config/opencode/skills/codex-rate-limit-reset/scripts/read_rate_limits.py
```

2. If the user mentions a specific thread or session file, rerun with one of:

```bash
python3 ~/.config/opencode/skills/codex-rate-limit-reset/scripts/read_rate_limits.py --thread-id <thread-id>
python3 ~/.config/opencode/skills/codex-rate-limit-reset/scripts/read_rate_limits.py --session-file <absolute-path-to-rollout.jsonl>
python3 ~/.config/opencode/skills/codex-rate-limit-reset/scripts/read_rate_limits.py --json
```

3. If auth auto-discovery fails, point the script at the Desktop auth file explicitly:

```bash
python3 ~/.config/opencode/skills/codex-rate-limit-reset/scripts/read_rate_limits.py --auth "/Users/<user>/Library/Application Support/Parall/Codex/.codex/auth.json"
```

4. Report:
- the snapshot timestamp
- the plan type
- the primary and secondary windows
- each window's used percent
- each reset time as an exact local timestamp
- the relative time remaining until reset
- `rate_limit_reached_type` when present
- reset-coupon availability and exact expirations from the live endpoint when available
- the live coupon source used, or the local fallback source when the live lookup fails
- any locally-stored coupon timestamp and what it does or does not mean when fallback data is all that exists

5. State the evidence boundary clearly:
- describe the standard windows as the latest local Codex session snapshot
- describe live coupon data as coming from the Codex/ChatGPT backend reset-credit endpoint
- describe fallback coupon data as local app-state metadata, not a live server-side account API
- do not claim an exact coupon expiry unless the live endpoint or another dedicated expiry field exists
- if only a local timestamp exists, label any derived deadline as an upper bound such as "expires no later than"
- if no snapshot is found, say so plainly and avoid guessing

## Output Rules

- Prefer exact dates and times over vague phrases like "later today."
- Keep timezone handling explicit when the user seems confused.
- If the user only asks "when does it reset?", answer that first, then mention the secondary window if available.
- If the user asks about reset coupons, answer that before the normal windows.
- If the live coupon lookup succeeds, prefer the next exact coupon expiry over any derived local estimate.
- If the only coupon timestamp is a dismissal or observation timestamp, explain that it is not the exact issuance time.
- If the user asks for raw details or automation, use `--json`.

## Testing

Run tests from the skill directory:

```bash
python3 -m pytest ~/.config/opencode/skills/codex-rate-limit-reset/tests/
```
