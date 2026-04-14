---
description: "Activate caveman mode for terse, token-efficient responses. Usage: /caveman [lite|full|ultra]. Cuts ~75% output tokens while keeping full technical accuracy."
---

# Caveman Mode

Load the **caveman** skill and activate it immediately.

## Intensity

If `$ARGUMENTS` specifies a level (`lite`, `full`, `ultra`), use that level.
If no argument given, use **full** (the default).

## Activation

After loading the skill, confirm activation with a one-line caveman-style acknowledgment that includes the active level. Example:

- `/caveman` -> "Caveman mode ON. Level: full. Less word, same brain."
- `/caveman lite` -> "Caveman lite ON. Professional, no fluff."
- `/caveman ultra` -> "Caveman ultra ON. Max compress."

## Related Skills

- **caveman-commit** — terse commit messages (`/caveman-commit`)
- **caveman-review** — one-line code review comments (`/caveman-review`)
- **caveman-help** — quick-reference card (`/caveman-help`)

## Deactivation

User says "stop caveman" or "normal mode" to revert.
