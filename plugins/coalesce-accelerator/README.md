# Coalesce Accelerator Plugin

Streamline full-stack Coalesce framework development with code generation, data binding, and EF Core migration workflows.

## Overview

The **Coalesce Accelerator** plugin accelerates development with the [Coalesce framework](https://coalesce.intellitect.com/), a low-code framework that generates REST APIs, TypeScript clients, and Vue 3 components from C# models. This plugin provides expert guidance on:

- **Full-stack development patterns** — from C# models to Vue 3 UI
- **Code generation workflows** — Coalesce code generation and TypeScript synchronization
- **EF Core best practices** — model design, migrations, and relationships
- **Data binding integration** — Vue 3 reactivity with Coalesce-generated types
- **Common enterprise patterns** — pagination, filtering, real-time updates

## Quick Start

### Installation

```bash
copilot plugin install coalesce-accelerator@IntelliPlugins
```

### First-Time Workflow

1. **Create a Coalesce project** — Set up a new .NET web application with Coalesce
2. **Design your data model** — Create C# entities and configure EF Core
3. **Run code generation** — Execute `coalesce_generate` to create APIs and TypeScript types
4. **Build Vue 3 UI** — Use generated types in Vue components with Vuetify
5. **Deploy and iterate** — Test end-to-end, then add features and regenerate

## Key Features

###  Full-Stack Development Patterns
- Coalesce project structure and conventions
- Model design for API generation
- Navigation properties and relationships
- DTOs and projection strategies

###  Code Generation Workflows
- Automated REST API creation from C# models
- TypeScript type definitions synchronized with C# models
- Generated validation rules and constraints
- Regeneration after schema changes

###  Entity Framework Core Patterns
- Model-first development with Coalesce
- One-to-many, many-to-many, and self-referential relationships
- Lazy loading, eager loading, and explicit loading strategies
- Database migrations with `dotnet ef`

###  Vue 3 Data Binding
- Integration with Coalesce-generated TypeScript types
- Reactive form binding with Vuetify components
- List management and filtering
- Real-time updates with SignalR

###  Production-Ready Workflows
- Complex filtering and search
- Pagination and performance optimization
- Role-based access control and authorization
- Error handling and validation

## Common Scenarios

### Adding a New Entity with Full-Stack Propagation

```plaintext
1. Create C# model in the server project
2. Add DbSet to AppDbContext
3. Configure relationships and data annotations
4. Run `coalesce_generate`
5. Use generated TypeScript types in Vue components
6. Create Vuetify form/table for the new entity
```

### Updating an Existing Model

```plaintext
1. Modify the C# model (properties, relationships, validation)
2. Create EF Core migration: `dotnet ef migrations add [MigrationName]`
3. Update AppDbContext if needed
4. Run `coalesce_generate` to update APIs and TypeScript types
5. Verify generated TS types match component expectations
6. Update Vue components as needed
7. Run `dotnet build` and verify full-stack compilation
```

### Implementing Complex Filtering

```plaintext
1. Define filter properties on the model
2. Add [Bind] and [Search] attributes for Coalesce
3. Regenerate to update API endpoints
4. Use generated filters in Vue with Coalesce list bindings
5. Test filtering with Vuetify table or custom filters
```

## Documentation Links

### Official Resources
- **[Coalesce Documentation](https://coalesce.intellitect.com/)** — Official guides, API docs, examples
- **[Coalesce GitHub](https://github.com/IntelliTect/Coalesce)** — Source code and issue tracking
- **[Vue 3 Documentation](https://vuejs.org/)** — Vue 3 fundamentals
- **[Vuetify Documentation](https://vuetifyjs.com/)** — Vue 3 component library

### Entity Framework Core
- **[EF Core Documentation](https://learn.microsoft.com/en-us/ef/core/)** — Model design, migrations, queries
- **[EF Core Relationships](https://learn.microsoft.com/en-us/ef/core/modeling/relationships/)** — Relationship patterns

## Instruction Guides

This plugin includes three comprehensive instruction files:

### 1. **Coalesce Workflows** (`coalesce-workflows.md`)
- Project setup and initialization
- Model and DbContext creation
- Code generation process and troubleshooting
- TypeScript type synchronization
- Best practices for model design

### 2. **EF Core Patterns** (`ef-core-patterns.md`)
- Model design for Coalesce
- Relationships (one-to-many, many-to-many, self-referential)
- Data annotations and configurations
- Lazy vs eager loading strategies
- Validation and constraints
- Migrations and schema management

### 3. **Code Generation** (`code-generation.md`)
- What Coalesce generates (APIs, TypeScript, validation)
- Running `coalesce_generate` and understanding output
- Generated file structure and organization
- TypeScript type definitions and API clients
- Regeneration workflows after model changes
- Customization and extension points

## Related Plugins

- **[C# Best Practices](https://intelliplugins.github.io/plugins/csharp-best-practices)** — SOLID principles and architectural patterns for .NET
- **[Vuetify Components](https://intelliplugins.github.io/plugins/vuetify-components)** — Material Design UI component library for Vue 3
- **[Testing Essentials](https://intelliplugins.github.io/plugins/testing-essentials)** — Unit, integration, and E2E testing strategies

## Architecture Highlights

### What Coalesce Generates

For a model like:
```csharp
public class Person
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public DateTime DateOfBirth { get; set; }
    public ICollection<Company> Companies { get; set; }
}
```

Coalesce automatically generates:
- **REST API** — CRUD endpoints with filtering, sorting, pagination
- **TypeScript DTO** — Type-safe model for Vue consumption
- **API Client** — Generated service for making API calls
- **Validation Rules** — Based on C# data annotations
- **OpenAPI/Swagger** — Full API documentation

### Integration with Vue 3

```typescript
// Generated TypeScript type (auto-synced from C#)
interface Person {
  personId: number;
  firstName: string;
  lastName: string;
  dateOfBirth: Date;
  companies: Company[];
}

// Use in Vue component with Coalesce binding
const model = ref<Person>(new Person());
```

## Enterprise Patterns

### Pagination and Performance
- Use Coalesce's built-in paging to reduce payload sizes
- Configure eager loading strategically to minimize N+1 queries
- Index frequently-filtered columns in the database

### Role-Based Access Control
- Use Coalesce `[Restrict]` attributes for property-level authorization
- Implement service methods for complex authorization logic
- Validate permissions on the server side (never on the client)

### Real-Time Updates
- Leverage SignalR for live notifications
- Combine with Coalesce services for efficient data synchronization
- Use client-side caching to minimize round trips

### Error Handling
- Standardize API responses with Coalesce validation
- Use consistent HTTP status codes
- Provide meaningful error messages to the client

## Version History

### v1.0.0 (2025)
- Initial release
- Full-stack Coalesce development workflows
- EF Core patterns and best practices
- Code generation and TypeScript synchronization
- Vue 3 and Vuetify integration examples

## Support and Feedback

For issues, questions, or suggestions:
- Open an issue on [GitHub](https://github.com/IntelliTect-dev/IntelliPlugins/issues)
- Reference this plugin: `coalesce-accelerator`
- Include your Coalesce version and .NET version

## License

MIT License — See LICENSE file for details.

---

**Last Updated:** 2025  
**Maintained by:** IntelliTect Development Team
