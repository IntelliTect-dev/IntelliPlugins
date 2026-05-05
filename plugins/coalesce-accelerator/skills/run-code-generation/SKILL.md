---
name: run-code-generation
description: Run Coalesce code generation to regenerate TypeScript types and API client after C# model changes
---

# Run Code Generation Skill

Trigger and manage Coalesce's code generation pipeline to regenerate TypeScript types, API clients, and ViewModels after C# model or service changes.

## When to Use

Invoke this skill when you:

- Have made changes to C# entity classes and need to regenerate TypeScript types
- Need to run `dotnet coalesce` and understand what it produces
- Want to troubleshoot code generation errors or stale generated files
- Are setting up or configuring the code generation pipeline

## Running Code Generation

```bash
dotnet coalesce
```

Run this from any directory at or below where `coalesce.json` lives — the tool walks up the directory tree to find it. For projects from the Coalesce template, run from the `*.Web` project directory.

## What Gets Generated

- `models.g.ts` — TypeScript model classes mirroring your C# entities
- `viewmodels.g.ts` — ViewModel classes with reactive state and API call methods
- `api-clients.g.ts` — Low-level typed API client classes
- `metadata.g.ts` — Property metadata (types, validation rules, display names)
- C# controller and DTO files in the web project

Coalesce reads your C# assembly — it does **not** require a live database connection to generate code.

## Configuration (`coalesce.json`)

Place `coalesce.json` in the solution root ([full reference](https://coalesce.intellitect.com/topics/coalesce-json.html)):

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

## When to Regenerate

Run `dotnet coalesce` after:

1. Adding, renaming, or removing a model property
2. Adding or removing navigation properties or relationships
3. Changing `[Coalesce]` attributes, data sources, or behaviors
4. Adding a new entity class to the `DbContext`

## Troubleshooting

**Generated files not updating:**
```bash
dotnet clean && dotnet build
dotnet coalesce
```

**API endpoints missing:**
1. Verify the entity's `DbSet` exists in `DbContext`
2. Verify the model is `public`
3. Re-run `dotnet coalesce` and restart the app

**TypeScript compilation errors:**
1. Verify `models.g.ts` and `viewmodels.g.ts` exist in the Vue `src/` folder
2. Run `npm install` to ensure dependencies are current
