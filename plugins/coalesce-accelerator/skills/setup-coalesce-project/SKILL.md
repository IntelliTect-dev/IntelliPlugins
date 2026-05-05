---
name: setup-coalesce-project
description: Set up a new Coalesce full-stack project from scratch including models, DbContext, and project structure
---

# Setup Coalesce Project Skill

Guide the full setup of a new Coalesce full-stack project including C# models, EF Core DbContext, Coalesce configuration, and Vue 3 frontend scaffolding.

## When to Use

Invoke this skill when you:

- Are starting a brand new Coalesce project from scratch
- Need to configure an existing project to use Coalesce
- Want to understand the required project structure and dependencies

## Creating a New Project

Use the official Coalesce Vue template ([getting started docs](https://coalesce.intellitect.com/stacks/vue/getting-started.html)):

```bash
dotnet new install IntelliTect.Coalesce.Vue.Template
dotnet new coalescevue -n MyCompany.MyProject -o MyProject
cd MyProject/*.Web
npm i
dotnet restore
dotnet coalesce
```

The template includes all required configuration for ASP.NET Core, EF Core, Vue 3, and Coalesce out of the box.

## Adding Coalesce to an Existing Project

1. **Add the NuGet package** to the web project:

```bash
dotnet add package IntelliTect.Coalesce
```

2. **Register Coalesce** in `Program.cs`:

```csharp
builder.Services.AddCoalesce<AppDbContext>();
```

3. **Add `coalesce.json`** to the solution root pointing to your projects:

```json
{
  "webProject": {
    "projectFile": "src/MyApp.Web/MyApp.Web.csproj"
  },
  "dataProject": {
    "projectFile": "src/MyApp.Domain/MyApp.Domain.csproj"
  }
}
```

4. **Run code generation** (use the `run-code-generation` skill):

```bash
dotnet coalesce
```

## Model and DbContext Pattern

```csharp
// AppDbContext.cs
public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<Company> Companies { get; set; }
    public DbSet<Person> People { get; set; }
}
```

See the `scaffold-entity` skill for the entity class pattern.
