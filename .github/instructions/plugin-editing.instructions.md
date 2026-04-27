---
applyTo: "plugins/**"
---

# Plugin Editing — Version Bump Reminder

Whenever you edit any file inside a `plugins/<name>/` directory, remind the user to bump the plugin version before committing:

1. Increment the `version` field in `plugins/<name>/plugin.json` using the semver rules below.
2. Update the matching entry's `version` in `.github/plugin/marketplace.json` to the same value.

## Semver guidance for plugins

**Patch** (`1.0.x`) — backward-compatible fixes and clarifications with no change in scope:
- Fixing typos, grammar, or unclear wording in instructions
- Rewording guidance to improve clarity without changing intent
- Adding or improving examples that illustrate existing rules

**Minor** (`1.x.0`) — backward-compatible additions that expand what the plugin covers:
- Adding new instruction files or new sections to existing ones
- Adding a new agent, prompt, or capability to the plugin
- Extending keywords or categories in `plugin.json`

**Major** (`x.0.0`) — changes that alter existing behavior in a way users may need to adapt to:
- Removing or renaming instruction files referenced by the plugin
- Fundamentally changing the guidance or recommendations in a way that conflicts with prior versions
- Changing the plugin `name` field (affects install commands and `@` references)

The CI workflow enforces that these two versions match, so both files must be updated together.
