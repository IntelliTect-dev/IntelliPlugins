---
name: generate-migration
description: Generate an EF Core migration and run it for the current Coalesce project
---

# Generate Migration Skill

Generate a new EF Core database migration after making changes to Coalesce entity models, then optionally apply it to the database.

## When to Use

Invoke this skill after you have:
- Added, renamed, or removed a property on a Coalesce entity
- Added or removed a navigation property or relationship
- Changed a `[StringLength]`, `[Required]`, or other schema-affecting attribute
- Added a new entity class to the `DbContext`

## Steps

1. **Verify the model compiles**
   ```bash
   dotnet build
   ```
   Fix any compiler errors before proceeding.

2. **Regenerate Coalesce artifacts** to keep the API and TypeScript types in sync:
   ```bash
   coalesce_generate
   ```

3. **Add the EF Core migration** using a descriptive PascalCase name that describes the change:
   ```bash
   dotnet ef migrations add <MigrationName> --project <DataProject> --startup-project <WebProject>
   ```
   Examples: `AddCompanyPhoneNumber`, `RemoveOrderLegacyStatus`, `AddIndexOnUserEmail`

4. **Review the generated migration file** in `Migrations/` — verify the `Up()` and `Down()` methods match your intent. Check for:
   - Unexpected table drops or column drops
   - Missing `nullable` settings
   - Correct foreign key constraints

5. **Apply the migration to the database**:
   ```bash
   dotnet ef database update --project <DataProject> --startup-project <WebProject>
   ```

6. **Run tests** to confirm nothing regressed:
   ```bash
   dotnet test
   ```

## Naming Conventions

Migration names should be short, PascalCase, and describe **what changed**:
- ✅ `AddUserEmailIndex`
- ✅ `RenameCompanyAddressToStreet`
- ❌ `Update1`, `Migration20240101`, `Changes`

## Notes

- Always review the generated `.cs` migration file before applying — EF Core may infer destructive changes
- If the migration is complex, split it: one for schema changes, one for data changes
- For seed data changes, consider a separate data migration or a custom `IHostedService`
