# IntelliPlugins - Copilot Plugin Marketplace

Curated GitHub Copilot plugins for enterprise C# development, Coalesce framework, and Vue 3 with Vuetify.

[![IntelliTect](https://img.shields.io/badge/by-IntelliTect-blue)](https://intellitect.com/)
[![MIT License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

## Quick Start

### Install a Plugin

```bash
copilot plugin install solid-principles@IntelliPlugins
```

### Use in Copilot

```
@solid-principles Review this service class for SOLID violations.
```

### Browse All Plugins

Visit [help pages](https://intellitect-dev.github.io/IntelliPlugins/) for documentation, examples, and installation guides.

## Available Plugins

### Enterprise-Generic (Reusable Across Projects)

- **[SOLID Principles & Architecture](plugins/solid-principles)** - Enterprise design patterns
- **[Testing Essentials](plugins/testing-essentials)** - Comprehensive testing strategies
- **[C# Best Practices](plugins/csharp-best-practices)** - Modern C# language idioms

### Framework-Specific (IntelliTect Tech Stack)

- **[Coalesce Accelerator](plugins/coalesce-accelerator)** - Full-stack Coalesce development
- **[Vuetify Components & Patterns](plugins/vuetify-components)** - Vue 3 + Vuetify UI

### Specialized Workflows

- **[Enterprise Bug Fixing](plugins/enterprise-bug-fixing)** - Structured bug resolution with Azure DevOps

## Documentation

- **[Getting Started](docs/guides/getting-started.md)** - Your first steps with IntelliPlugins
- **[Usage Examples](docs/guides/usage-examples.md)** - Real-world scenarios
- **[Installation Guide](docs/plugins/installation-guide.md)** - Detailed setup
- **[Full Documentation](https://intellitect-dev.github.io/IntelliPlugins/)** - Complete guides and examples

## Repository Structure

```
IntelliPlugins/
├── .github/plugin/               # GitHub plugin registry
│   └── marketplace.json          # Marketplace definition
├── plugins/                      # All plugin implementations
│   ├── solid-principles/
│   ├── testing-essentials/
│   ├── csharp-best-practices/
│   ├── coalesce-accelerator/
│   ├── vuetify-components/
│   └── enterprise-bug-fixing/
├── docs/                         # DocFX documentation site
│   ├── docfx.json
│   ├── guides/
│   └── plugins/                  # auto-generated from plugin implementations on build
└── .github/workflows/            # CI/CD automation
```

## Plugin Contents

Each plugin includes:

- **plugin.json** - Plugin manifest and metadata
- **README.md** - Comprehensive documentation
- **instructions/** - Copilot guidance files
- **agents/** - Specialized workflow agents (if applicable)
- **docs/** - Additional resources

## Example Use Cases

### Code Review with SOLID Principles

```
@solid-principles
This UserService handles auth, data access, and notifications.
Does it violate any principles? How should I refactor?
```

### Writing Unit Tests

```
@testing-essentials
I have a DiscountCalculator service.
What test cases should I write and how should I structure them?
```

### Full-Stack Coalesce Development

```
@coalesce-accelerator @vuetify-components
I need to add an Order feature with a sortable table and edit dialog.
What's the full workflow from model to UI?
```

### Bug Fixing with Azure DevOps

```
@enterprise-bug-fixing @testing-essentials
Help me fix bug #12345. Let's start with a test-first approach.
```

## Installation

### Prerequisites

- GitHub Copilot CLI ([installation guide](https://docs.github.com/en/copilot/how-tos/copilot-cli/getting-started-with-github-copilot-cli))
- Git

### Install from Marketplace

```bash
copilot plugin marketplace add IntelliTect-dev/IntelliPlugins
```

### Install All Plugins

```bash
copilot plugin install solid-principles@IntelliPlugins && \
copilot plugin install testing-essentials@IntelliPlugins && \
copilot plugin install csharp-best-practices@IntelliPlugins && \
copilot plugin install coalesce-accelerator@IntelliPlugins && \
copilot plugin install vuetify-components@IntelliPlugins && \
copilot plugin install enterprise-bug-fixing@IntelliPlugins
```

### Project-Level Setup

Create `.copilot/config.json` in your project:

```json
{
  "plugins": [
    "solid-principles@IntelliPlugins",
    "testing-essentials@IntelliPlugins",
    "csharp-best-practices@IntelliPlugins"
  ]
}
```

## Contributing

Have ideas for new plugins or improvements? Open a PR or reach out to dan.olvera@intellitect.com.
