---
name: add-data-source
description: Add a custom Coalesce IDataSource to filter or shape entity data for a specific use case
---

# Add Data Source Skill

Create a custom Coalesce `IDataSource<T>` implementation to provide filtered, shaped, or security-scoped access to an entity beyond the default CRUD behavior.

## When to Use

Invoke this skill when you need to:
- Expose a filtered subset of an entity (e.g., "only active records")
- Add includes/eager loading not present on the default source
- Scope data to the current user (tenancy, ownership)
- Return a projection or computed view of an entity

## Data Source Pattern

```csharp
using IntelliTect.Coalesce;
using IntelliTect.Coalesce.Api;
using IntelliTect.Coalesce.TypeDefinition;

[Coalesce]
public class ActiveEntitySource : StandardDataSource<Entity, AppDbContext>
{
    public ActiveEntitySource(CrudContext<AppDbContext> context) : base(context) { }

    public override IQueryable<Entity> GetQuery(IDataSourceParameters parameters)
        => base.GetQuery(parameters)
               .Where(e => e.IsActive)
               .Include(e => e.RelatedEntity);
}
```

## Steps

1. **Create the data source class** in a `DataSources/` folder beside your entity models
2. **Decorate with `[Coalesce]`** so the CLI picks it up during code generation
3. **Override `GetQuery`** — compose from `base.GetQuery()` to retain default filtering/sorting support
4. **Optionally override `TransformResults`** for post-query shaping
5. **Run `dotnet coalesce`** to expose it in the API:
   ```bash
   dotnet coalesce
   ```
6. **Verify the new data source appears** in the generated API and TypeScript service
7. **Write tests** that confirm filtering/scoping works correctly

## User-Scoped Data Source Pattern

```csharp
[Coalesce]
public class MyRecordsSource : StandardDataSource<Record, AppDbContext>
{
    private readonly ICurrentUserService _currentUser;

    public MyRecordsSource(CrudContext<AppDbContext> context, ICurrentUserService currentUser)
        : base(context)
    {
        _currentUser = currentUser;
    }

    public override IQueryable<Record> GetQuery(IDataSourceParameters parameters)
        => base.GetQuery(parameters)
               .Where(r => r.OwnerId == _currentUser.UserId);
}
```

## Notes

- Multiple data sources can exist for the same entity — each becomes a selectable source in the API
- The default data source is `StandardDataSource<T>` — your custom sources supplement it
- Always test that unauthorized data cannot be reached through alternative data sources
