---
applyTo: "plugins/**"
---

# Plugin Editing — Version Bump Reminder

Whenever you edit any file inside a `plugins/<name>/` directory, remind the user to bump the plugin version before committing:

1. Increment the `version` field in `plugins/<name>/plugin.json` (follow semver: patch for fixes/content tweaks, minor for new instructions or capabilities, major for breaking changes).
2. Update the matching entry's `version` in `.github/plugin/marketplace.json` to the same value.

The CI workflow enforces that these two versions match, so both files must be updated together.
