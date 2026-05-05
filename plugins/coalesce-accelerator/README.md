# Coalesce Accelerator Plugin

Streamline full-stack Coalesce framework development with code generation, data binding, and EF Core migration workflows.

## Overview

The **Coalesce Accelerator** plugin accelerates development with the [Coalesce framework](https://coalesce.intellitect.com/), which generates REST APIs, TypeScript clients, and Vue 3 components from C# models.

## Quick Start

```bash
copilot plugin install coalesce-accelerator@IntelliPlugins
```

## Skills

- **`setup-coalesce-project`** — Create a new project with the official template or add Coalesce to an existing app
- **`scaffold-entity`** — Add a new entity class with EF Core annotations, relationships, and DbContext registration
- **`generate-migration`** — Create and apply an EF Core migration after model changes
- **`run-code-generation`** — Run `dotnet coalesce` to regenerate TypeScript types and API clients
- **`add-data-source`** — Create a custom `IDataSource<T>` for filtered or user-scoped data access

## Coalesce MCP Server

Projects from the Coalesce template include MCP configuration automatically. To add it manually, add to your VS Code workspace or user MCP config:

```json
{
  "servers": {
    "coalesce": {
      "command": "npx",
      "args": ["coalesce-mcp@latest"]
    }
  }
}
```

**Available tools:**

- `coalesce_generate` — runs code generation (preferred over running `dotnet coalesce` directly in agent sessions)
- `get_template_features` — lists available template features and the files involved
- `read_template_file` — reads a file from the latest Coalesce template (useful during upgrades)
- `read_changelog` — reads the changelog, optionally filtered to versions newer than your current one

**Available prompts:**

- `upgrade` — step-by-step agent-guided Coalesce upgrade (run via `/mcp` in VS Code chat)

**Available resources:**

- `coalesce://template-file/{filePath}` — add individual template files as context. In VS Code: _Add Context... → MCP Resources... → Coalesce_

Full MCP docs: https://coalesce.intellitect.com/topics/mcp-server.html

## Documentation

- [Coalesce Docs](https://coalesce.intellitect.com/)
- [Getting Started (Vue)](https://coalesce.intellitect.com/stacks/vue/getting-started.html)
- [coalesce.json Reference](https://coalesce.intellitect.com/topics/coalesce-json.html)
- [Coalesce GitHub](https://github.com/IntelliTect/Coalesce)

## Related Plugins

- **[C# Best Practices](https://intellitect.github.io/IntelliPlugins/plugins/csharp-best-practices)**
- **[Vuetify Components](https://intellitect.github.io/IntelliPlugins/plugins/vuetify-components)**
- **[Testing Essentials](https://intellitect.github.io/IntelliPlugins/plugins/testing-essentials)**
