---
name: run-code-generation
description: Run Coalesce code generation to regenerate TypeScript types and API client after C# model changes
---

# Run Code Generation Skill

Trigger and manage Coalesce's code generation pipeline to regenerate TypeScript types, API clients, and ViewModels after C# model or service changes.

## When to Use

Invoke this skill when you:
- Have made changes to C# entity classes and need to regenerate TypeScript types
- Need to run coalesce_generate and understand what it produces
- Want to troubleshoot code generation errors or stale generated files
- Are setting up or configuring the code generation pipeline

# Coalesce Code Generation

This guide explains what Coalesce generates, how to run code generation, customize the output, and manage regeneration workflows.

## Overview: What Coalesce Generates

When you run `coalesce_generate`, Coalesce inspects your C# models and automatically creates:

### 1. REST API Endpoints

For each model, Coalesce generates complete CRUD endpoints:

**Model:**
```csharp
public class Person
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public int CompanyId { get; set; }
    public Company Company { get; set; }
}
```

**Generated API Endpoints:**
```
GET    /api/Person                    # List with filtering, paging
GET    /api/Person/{id}              # Get single record
POST   /api/Person                    # Create new record
PUT    /api/Person/{id}              # Update record
DELETE /api/Person/{id}              # Delete record
GET    /api/Person/count             # Count records
POST   /api/Person/bulkSave          # Batch create/update
```

### 2. TypeScript Type Definitions

Automatic TypeScript models synchronized with C# entities:

**Generated TypeScript (from C# model above):**
```typescript
// models/person.ts
export class Person {
    public personId: number = null!;
    public firstName: string = null!;
    public lastName: string = null!;
    public companyId: number = null!;
    public company: Company | null = null;
    
    constructor(init?: Partial<Person>) {
        Object.assign(this, init);
    }
}

export namespace Person {
    export const displayName = "Person";
    export const displayPluralName = "People";
    export const singularDisplayName = "Person";
    
    export const props = {
        personId: { type: "number", role: "primaryKey" },
        firstName: { type: "string" },
        lastName: { type: "string" },
        companyId: { type: "number" },
        company: { type: "Company", navigationProperty: true }
    };
}
```

### 3. API Client Service

Type-safe service for making API calls from Vue:

**Generated Service (api-client/person.ts):**
```typescript
export namespace PersonService {
    // List records with filtering and paging
    export async function list(
        filter?: ListFilters<Person>,
        queryParams?: ApiQueryParams
    ): Promise<ItemResult<Person[]>> {
        // Implementation
    }
    
    // Get single record
    export async function get(
        id: number,
        queryParams?: ApiQueryParams
    ): Promise<ItemResult<Person>> {
        // Implementation
    }
    
    // Create or update
    export async function save(
        item: Person
    ): Promise<SaveResult<Person>> {
        // Implementation
    }
    
    // Delete
    export async function delete(
        id: number
    ): Promise<SaveResult<Person>> {
        // Implementation
    }
    
    // Count records
    export async function count(
        filter?: ListFilters<Person>,
        queryParams?: ApiQueryParams
    ): Promise<ItemResult<number>> {
        // Implementation
    }
}
```

### 4. Validation Rules

Data annotations are converted to TypeScript validation metadata:

**C# Model:**
```csharp
public class Person
{
    [Required]
    [StringLength(100)]
    public string FirstName { get; set; }
    
    [EmailAddress]
    public string Email { get; set; }
    
    [Range(18, 150)]
    public int Age { get; set; }
}
```

**Generated Validation Metadata:**
```typescript
Person.props.firstName = {
    type: "string",
    required: true,
    maxLength: 100
};

Person.props.email = {
    type: "string",
    pattern: "email"
};

Person.props.age = {
    type: "number",
    min: 18,
    max: 150
};
```

### 5. OpenAPI/Swagger Documentation

Auto-generated API documentation:

```
http://localhost:5000/swagger/index.html
```

Includes:
- All endpoints with request/response schemas
- Parameter descriptions from C# attributes
- Try-it-out functionality to test endpoints
- Authentication/authorization info

## Running Code Generation

### Installation

Ensure the Coalesce code generation tool is installed:

```bash
dotnet tool install -g IntelliTect.Coalesce.CodeGeneration
```

Or add to project:
```bash
dotnet add package IntelliTect.Coalesce.CodeGeneration
```

### Basic Execution

From your project directory:

```bash
coalesce_generate
```

The command:
1. Reads your C# models from the project
2. Connects to the configured database to understand the schema
3. Generates TypeScript types in `wwwroot/coalesce/models/`
4. Generates API client in `wwwroot/coalesce/api-client/`
5. Generates metadata in `wwwroot/coalesce/generated.ts`

### Configuration

The tool looks for `coalesce.json` in the project root:

```json
{
  "Source": "MyApp.Web.csproj",
  "OutputPath": "wwwroot/coalesce",
  "TypescriptOutputPath": "wwwroot/coalesce",
  "IncludeMetadata": true,
  "GenerateImplementation": true
}
```

### Connection String

The generation tool needs database access. Configure in `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=MyAppDb;Trusted_Connection=true;"
  }
}
```

For development:
```bash
# Ensure database is created and migrations applied
dotnet ef database update

# Then generate
coalesce_generate
```

### Troubleshooting Generation

**Problem: "Could not find DbContext"**
```bash
# Ensure DbContext is in the assembly being scanned
# Verify DbContext is registered in DI

# Re-run explicitly
coalesce_generate --verbose
```

**Problem: "Database connection failed"**
```bash
# Check connection string
# Verify database server is running
# Ensure user has connection permissions

dotnet ef database info  # Test connection
```

**Problem: "Generated files not updated"**
```bash
# Rebuild project first
dotnet clean
dotnet build

# Force regenerate
rm -r wwwroot/coalesce/
coalesce_generate
```

## Generated File Structure

After running `coalesce_generate`:

```
wwwroot/
└── coalesce/
    ├── models/
    │   ├── person.ts              # TypeScript model class
    │   ├── person.d.ts            # Type definitions
    │   ├── company.ts
    │   ├── company.d.ts
    │   └── index.ts               # Barrel export
    │
    ├── api-client/
    │   ├── person.ts              # PersonService
    │   ├── company.ts             # CompanyService
    │   └── index.ts               # Barrel export
    │
    ├── generated.ts               # Master export file
    ├── generated.d.ts             # Type definitions
    ├── metadata.g.ts              # Coalesce metadata
    └── README.md                  # Documentation
```

### Importing Generated Code

**In Vue components:**

```typescript
import { Person, Company } from '@/coalesce/generated';
import { PersonService, CompanyService } from '@/coalesce/generated';

export default {
    setup() {
        const people = ref<Person[]>([]);
        
        onMounted(async () => {
            const result = await PersonService.list();
            people.value = result.object || [];
        });
        
        return { people };
    }
};
```

**Or import directly:**

```typescript
import { Person } from '@/coalesce/models/person';
import { PersonService } from '@/coalesce/api-client/person';
```

## TypeScript Type Definitions

### Model Classes

Generated models are TypeScript classes with property definitions:

```typescript
export class Person {
    // Properties initialized to null (non-nullable in strict mode)
    public personId: number = null!;
    public firstName: string = null!;
    public lastName: string = null!;
    public dateOfBirth: Date | null = null;
    public email: string | null = null;
    
    // Constructor for easy instantiation
    constructor(init?: Partial<Person>) {
        Object.assign(this, init);
    }
}
```

### Using Generated Types

```typescript
// Create instance
const person = new Person();
person.firstName = "John";
person.lastName = "Doe";

// Create with initialization
const person2 = new Person({
    firstName: "Jane",
    lastName: "Smith",
    email: "jane@example.com"
});

// In Vue components (fully type-safe)
const model = ref<Person>(new Person());
model.value.firstName = "Test";  // Type-safe!
```

### Metadata and Introspection

Each model includes metadata for advanced scenarios:

```typescript
Person.displayName;              // "Person"
Person.displayPluralName;        // "People"
Person.singularDisplayName;      // "Person"

Person.props.personId;           // Property metadata
Person.props.personId.type;      // "number"
Person.props.personId.role;      // "primaryKey"

Person.props.firstName;          
Person.props.firstName.type;     // "string"
Person.props.firstName.required; // true
Person.props.firstName.maxLength;// 100
```

## Generated API Endpoints

### List Endpoint

**Endpoint:** `GET /api/Person`

**Query Parameters:**
```typescript
// Filtering
?filter={"firstName":"John"}

// Paging
?pageSize=50&pageNumber=1

// Sorting
?orderBy=firstName,-companyId

// Includes (eager load related data)
?includes=company

// Search
?search=john
```

**Usage in Vue:**
```typescript
// Simple list
const result = await PersonService.list();
console.log(result.object);  // Person[]

// With filtering
const result = await PersonService.list({
    firstName: "John"
});

// With paging
const result = await PersonService.list(null, {
    pageSize: 20,
    pageNumber: 2
});

// With includes
const result = await PersonService.list(null, {
    includes: "company"
});
```

### Get Endpoint

**Endpoint:** `GET /api/Person/{id}`

**Usage:**
```typescript
const result = await PersonService.get(1);
if (result.wasSuccessful) {
    console.log(result.object);  // Single Person object
}
```

### Create/Update Endpoint

**Endpoint:** `POST /api/Person` (create) or `PUT /api/Person/{id}` (update)

**Usage:**
```typescript
const person = new Person({
    firstName: "John",
    lastName: "Doe",
    email: "john@example.com"
});

const result = await PersonService.save(person);

if (result.wasSuccessful) {
    console.log(result.object);  // Updated Person with ID
} else {
    console.log(result.errors);  // Validation errors
}
```

### Delete Endpoint

**Endpoint:** `DELETE /api/Person/{id}`

**Usage:**
```typescript
const result = await PersonService.delete(1);

if (result.wasSuccessful) {
    console.log("Person deleted");
} else {
    console.log("Delete failed", result.errors);
}
```

### Count Endpoint

**Endpoint:** `GET /api/Person/count`

**Usage:**
```typescript
const result = await PersonService.count();
console.log(result.object);  // Total count

// With filter
const result = await PersonService.count({
    companyId: 5
});
console.log(result.object);  // Filtered count
```

## Regeneration Workflow

### When to Regenerate

Run `coalesce_generate` after:
1. **Adding a new model** — Create the C# class, add DbSet, regenerate
2. **Modifying model properties** — Change property names, types, validation, regenerate
3. **Changing relationships** — Add/remove navigation properties, regenerate
4. **Updating validation attributes** — Add/change [Required], [StringLength], etc., regenerate
5. **Database schema changes** — After running migrations, regenerate

### Complete Regeneration Workflow

```plaintext
1. Modify C# model
   └─ Add properties, relationships, validation attributes
   
2. Create EF Core migration (if database schema changed)
   └─ dotnet ef migrations add MyMigrationName
   
3. Apply migration
   └─ dotnet ef database update
   
4. Rebuild project
   └─ dotnet build
   
5. Regenerate Coalesce
   └─ coalesce_generate
   
6. Rebuild TypeScript
   └─ npm run build
   
7. Test in Vue component
   └─ Verify new types and properties are available
```

### Example: Adding a Property

**Step 1: Modify Model**
```csharp
public class Person
{
    // ... existing properties ...
    
    [Phone]  // Add new property
    public string PhoneNumber { get; set; }
}
```

**Step 2: Create Migration**
```bash
dotnet ef migrations add AddPhoneNumberToPerson
dotnet ef database update
```

**Step 3: Regenerate**
```bash
dotnet build
coalesce_generate
```

**Step 4: Use in Vue**
```typescript
// TypeScript now knows about phoneNumber
const person = new Person();
person.phoneNumber = "555-1234";

// API includes the property
const result = await PersonService.get(1);
console.log(result.object?.phoneNumber);
```

## Customizing Code Generation

### Excluding Properties from API

Use `[Bind(false)]` to hide internal properties:

```csharp
public class Person
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    
    // This won't appear in API or generated TypeScript
    [Bind(false)]
    [ScaffoldColumn(false)]
    public string InternalId { get; set; }
}
```

### Excluding Models from Generation

Use `[Coalesce(false)]` to skip a model:

```csharp
[Coalesce(false)]
public class InternalConfig
{
    // Not exposed via API
}
```

### Custom Display Names

Control how properties appear in API docs and UI:

```csharp
public class Person
{
    [Display(Name = "First Name", Order = 1)]
    public string FirstName { get; set; }
    
    [Display(Name = "Last Name", Order = 2)]
    public string LastName { get; set; }
}
```

### API Attributes

Fine-tune API generation with attributes:

```csharp
[Coalesce]
public class PersonService : StandardDataService<Person, AppDbContext>
{
    // Executed before returning list results
    public override IQueryable<Person> GetQuery()
    {
        return base.GetQuery()
            .Include(p => p.Company)
            .Where(p => !p.IsDeleted);
    }
    
    // Executed before save
    public override async Task<SaveResult<Person>> BeforeSave(SaveRequest<Person> request)
    {
        // Validate, authorize, etc.
        return await base.BeforeSave(request);
    }
}
```

### Bulk Operations

Configure bulk create/update:

```csharp
[Coalesce]
public class PersonService : StandardDataService<Person, AppDbContext>
{
    // Configure bulk save behavior
    public override async Task<SaveResult<Person>> BeforeSave(SaveRequest<Person> request)
    {
        if (request.ForceUpdateDuringCreate)
        {
            // Handle as update even if no ID
        }
        return await base.BeforeSave(request);
    }
}
```

## Generated Validation

### Validation Constraints

C# validation attributes are converted to TypeScript constraints:

**C# Model:**
```csharp
public class Person
{
    [Required(ErrorMessage = "Name is required")]
    [StringLength(100, MinimumLength = 2)]
    public string Name { get; set; }
    
    [Range(18, 150)]
    public int Age { get; set; }
    
    [EmailAddress]
    public string Email { get; set; }
    
    [RegularExpression(@"^\d{5}$")]
    public string ZipCode { get; set; }
}
```

**Generated TypeScript Metadata:**
```typescript
Person.props.name = {
    type: "string",
    required: true,
    minLength: 2,
    maxLength: 100
};

Person.props.age = {
    type: "number",
    min: 18,
    max: 150
};

Person.props.email = {
    type: "string",
    pattern: "email"
};

Person.props.zipCode = {
    type: "string",
    pattern: /^\d{5}$/
};
```

### Using Validation in Vue

```typescript
import { Person } from '@/coalesce/generated';

const person = ref<Person>(new Person());
const errors = ref<Record<string, string>>({});

async function savePerson() {
    // Validate before sending
    if (!person.value.name) {
        errors.value.name = "Name is required";
        return;
    }
    
    if (person.value.name.length < 2) {
        errors.value.name = "Name must be at least 2 characters";
        return;
    }
    
    // Send to API
    const result = await PersonService.save(person.value);
    
    if (!result.wasSuccessful) {
        errors.value = result.errors || {};
    }
}
```

### Server-Side Validation

API always validates using C# data annotations:

```typescript
const result = await PersonService.save({
    personId: 0,
    name: "X",  // Too short (min 2)
    age: 10,    // Below range (min 18)
    email: "invalid"
});

if (!result.wasSuccessful) {
    console.log(result.errors);
    // {
    //   name: "Name must be at least 2 characters",
    //   age: "Must be between 18 and 150",
    //   email: "Invalid email address"
    // }
}
```

## Performance and Generation

### Generation Performance

For large codebases:
1. Generation reads entire assembly and database schema
2. Larger models = slower generation
3. Database connection required (adds latency)

### Optimizing Generation

- Exclude unrelated assemblies from scanning
- Use specific DbContext if multiple exist
- Close other tools connecting to database

### Incremental Development

Work locally with local database:
```bash
# Use LocalDB or SQL Express for fast generation cycles
# Connection: Server=(localdb)\mssqllocaldb;Database=MyApp;
```

## Troubleshooting Common Issues

### Types Not Updating

```bash
# Clear generated files
rm -r wwwroot/coalesce/

# Rebuild
dotnet build

# Regenerate
coalesce_generate
```

### API Endpoints Missing

1. Verify model has `[Coalesce]` attribute (if required)
2. Verify model is public
3. Verify DbSet exists in DbContext
4. Run `coalesce_generate` again
5. Rebuild and restart application

### TypeScript Compilation Errors

1. Verify `wwwroot/coalesce/generated.ts` exists
2. Check tsconfig.json includes generated files
3. Run `npm install` to ensure dependencies
4. Clear node_modules and reinstall if needed

## Next Steps

- Review **Coalesce Workflows** for full development cycle
- Study **EF Core Patterns** for advanced model design
- Explore official samples at [https://coalesce.intellitect.com/](https://coalesce.intellitect.com/)
