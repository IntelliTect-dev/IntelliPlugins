---
applyTo: "plugins/**/plugin.json,.github/plugin/marketplace.json"
---

# Plugin Version Sync

The `version` field in every `plugins/<name>/plugin.json` **must always match** the corresponding entry's `version` in `.github/plugin/marketplace.json`.

When editing either file:
- If you change the `version` in a `plugin.json`, update the matching entry in `.github/plugin/marketplace.json` to the same value.
- If you change a plugin's `version` in `marketplace.json`, update the corresponding `plugin.json` to the same value.

Both files must be committed together so the CI version-sync check passes.
