# IntelliPlugins

A curated collection of GitHub Copilot plugins, instruction files, and prompt templates for enterprise development.

[![IntelliTect](https://img.shields.io/badge/by-IntelliTect-blue)](https://intellitect.com/)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

## Quick Start

### Install a Plugin

```bash
copilot plugin marketplace add IntelliTect/IntelliPlugins
```

### Browse Everything

Visit the **[help pages](https://intellitect.github.io/IntelliPlugins/)** for the full list of plugins, instructions, and prompts with documentation and usage examples.

## What's Included

| Section | Description | Docs |
|---------|-------------|------|
| **Plugins** | Copilot plugins for enterprise C#, Coalesce, Vuetify, and more | [Plugins](https://intellitect.github.io/IntelliPlugins/plugins/installation-guide.html) |
| **Instructions** | Instruction files that automatically apply coding standards to matching files | [Instructions](https://intellitect.github.io/IntelliPlugins/instructions/index.html) |
| **Prompts** | Reusable prompt files for common development workflows | [Prompts](https://intellitect.github.io/IntelliPlugins/prompts/index.html) |

## Repository Structure

```
IntelliPlugins/
├── plugins/                      # Copilot plugin implementations
├── instructions/                 # Copilot instruction files (*.instructions.md)
├── prompts/                      # Copilot prompt files (*.prompt.md)
├── scripts/                      # Doc generation and upstream sync scripts
├── docs/                         # DocFX documentation site source
│   ├── guides/
│   ├── plugins/                  # auto-generated from plugins/ on build
│   ├── instructions/             # auto-generated from instructions/ on build
│   └── prompts/                  # auto-generated from prompts/ on build
└── .github/
    ├── plugin/marketplace.json   # GitHub plugin registry
    └── workflows/                # CI/CD automation
```

## Adding a file from `github/awesome-copilot`

When the upstream repository introduces a new prompt, instruction, or chat mode you want to adopt:

```bash
npm run sync -- --import path/to/file.ext
```

This copies the file locally and records its upstream SHA in `.github/upstream-sync-state.json`. Review the file and state file, then commit when ready.

## Contributing

Have ideas for new content or improvements? Open a PR or reach out to dan.olvera@intellitect.com.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
