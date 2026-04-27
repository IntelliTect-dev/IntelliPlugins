---
name: scaffold-entity
description: Scaffold a new Coalesce entity class with EF Core annotations, navigation properties, and register it in the DbContext
---

# Scaffold Entity Skill

Create a complete Coalesce-compatible C# entity class with appropriate EF Core data annotations, navigation properties, and DbContext registration.

## When to Use

Invoke this skill when you need to:
- Add a new domain entity to the Coalesce data model
- Create a related/child entity with a foreign key relationship
- Scaffold a lookup/reference table entity

## Required Information

Before scaffolding, gather:
1. **Entity name** — PascalCase noun (e.g., `Invoice`, `ProjectMilestone`)
2. **Properties** — names, types, and whether required/optional
3. **Relationships** — parent entity (if any), one-to-many or many-to-many
4. **Table name** — usually pluralized entity name (e.g., `Invoices`)

## Scaffold Pattern

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using IntelliTect.Coalesce.DataAnnotations;

[Table("EntityNamePlural")]
public class EntityName
{
    // Primary key — name must be {EntityName}Id
    [Key]
    public int EntityNameId { get; set; }

    // Required string property
    [Required]
    [StringLength(255)]
    [Display(Name = "Friendly Label")]
    public required string Name { get; set; }

    // Optional string property
    [StringLength(1024)]
    public string? Description { get; set; }

    // Foreign key + navigation (many-to-one)
    public int ParentId { get; set; }
    public Parent Parent { get; set; } = null!;

    // Audit fields
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
```

## Steps

1. **Create the entity file** in the `Models/` directory
2. **Add the DbSet** to the application's `DbContext`:
   ```csharp
   public DbSet<EntityName> EntityNames { get; set; }
   ```
3. **Run `coalesce_generate`** to generate the API and TypeScript types:
   ```bash
   coalesce_generate
   ```
4. **Create a migration** to add the table (use the `generate-migration` skill)
5. **Build and test**:
   ```bash
   dotnet build && dotnet test
   ```

## Coalesce-Specific Annotations

| Attribute | Effect |
|-----------|--------|
| `[Read(Roles = "Admin")]` | Restrict read access by role |
| `[Edit(Roles = "Admin")]` | Restrict edit access by role |
| `[Hidden]` | Exclude from generated list views |
| `[Search]` | Include property in text search |
| `[DefaultOrderBy]` | Set default sort property |
| `[ListText]` | Use as display text in dropdowns |
