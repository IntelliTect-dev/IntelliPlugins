# Getting Started with IntelliPlugins

Extend GitHub Copilot with enterprise C# development, Coalesce framework, and Vue 3 with Vuetify expertise.

## Install from Marketplace

```bash
copilot plugin marketplace add IntelliTect/IntelliPlugins
```

## Install Your First Plugin

```bash
copilot plugin install solid-principles@IntelliPlugins
```

## Use It in Copilot

When working on code, reference the plugin:

```
@solid-principles Help me apply the Single Responsibility Principle to this service class
```

Copilot will use the plugin's guidance to provide advice aligned with IntelliTect's standards.

## Common Use Cases

| Goal                 | Plugin                | Example                                                    |
| -------------------- | --------------------- | ---------------------------------------------------------- |
| Better architecture  | solid-principles      | `@solid-principles Review this for SOLID violations`       |
| Write better tests   | testing-essentials    | `@testing-essentials What tests should I write?`           |
| Modern C# code       | csharp-best-practices | `@csharp-best-practices Is this async code correct?`       |
| Coalesce development | coalesce-accelerator  | `@coalesce-accelerator I need to add a new model property` |
| Vue/Vuetify UI       | vuetify-components    | `@vuetify-components How should I structure this form?`    |
| Bug fixing           | enterprise-bug-fixing | `@enterprise-bug-fixing Help me fix this issue`            |

## Using Multiple Plugins Together

Plugins work together seamlessly:

```
@solid-principles @testing-essentials
I'm creating a new repository pattern. Design it for testability and clean architecture.
```

## Project-Level Setup

Create `.copilot/config.json` in your project:

```json
{
  "plugins": [
    "solid-principles@IntelliPlugins",
    "testing-essentials@IntelliPlugins",
    "csharp-best-practices@IntelliPlugins",
    "coalesce-accelerator@IntelliPlugins"
  ]
}
```

Benefits:

- Team members automatically get the same plugins
- Configuration stored in version control
- Consistent development practices
