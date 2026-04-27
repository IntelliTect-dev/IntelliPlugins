# Coalesce Workflows

This guide covers the end-to-end workflows for developing with Coalesce, from project setup through code generation to full-stack deployment.

## Development Workflow Overview

Coalesce development follows a **model-first** approach:

```
Design C# Models
     ↓
Configure EF Core & DbContext
     ↓
Create Database Migrations
     ↓
Run coalesce_generate
     ↓
Generated APIs & TypeScript Types
     ↓
Build Vue 3 Components
     ↓
Test End-to-End
```

Each change to the C# model requires regenerating Coalesce artifacts to keep the API and TypeScript types in sync.

## Setting Up a New Coalesce Project

### Prerequisites
- .NET 6+ SDK
- Node.js 16+ for Vue 3 frontend
- Visual Studio Code or Visual Studio
- SQL Server or another EF Core-supported database

### Creating a New Project

1. **Create the solution structure:**
```bash
dotnet new sln -n MyCoalesceApp
cd MyCoalesceApp
```

2. **Add a web project with Coalesce templates:**
```bash
# If using Coalesce template
dotnet new coalesce-app -n MyApp.Web
# OR create manually with ASP.NET Core project
```

3. **Install Coalesce NuGet package:**
```bash
cd MyApp.Web
dotnet add package IntelliTect.Coalesce
```

4. **Configure the project structure:**
```
MyApp.Web/
├── Models/                    # C# entity models
├── Data/
│   └── AppDbContext.cs       # EF Core DbContext
├── Controllers/              # API controllers (Coalesce generates many)
├── Services/                 # Custom business logic
├── Migrations/               # EF Core migrations
├── wwwroot/
│   └── coalesce/            # Generated TypeScript and API client
└── Startup.cs or Program.cs # Configure Coalesce and EF Core
```

### Configure Startup

In `Program.cs`:

```csharp
using IntelliTect.Coalesce;

var builder = WebApplicationBuilder.CreateBuilder(args);

// Add DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Add Coalesce
builder.Services.AddCoalesce(typeof(Program).Assembly);

// Add CORS if needed for development
builder.Services.AddCors(options =>
{
    options.AddPolicy("CorsPolicy", builder =>
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader());
});

var app = builder.Build();

app.UseCors("CorsPolicy");
app.MapControllers();

app.Run();
```

## Creating Models and DbContext

### Model Design

Create models in the `Models` directory:

```csharp
using System.ComponentModel.DataAnnotations;

public class Company
{
    public int CompanyId { get; set; }
    
    [Required(ErrorMessage = "Company name is required")]
    [StringLength(255)]
    public string Name { get; set; }
    
    [EmailAddress]
    public string Email { get; set; }
    
    public string PhoneNumber { get; set; }
    
    // Navigation property (one-to-many)
    public ICollection<Person> Employees { get; set; } = new List<Person>();
}

public class Person
{
    public int PersonId { get; set; }
    
    [Required]
    [StringLength(100)]
    public string FirstName { get; set; }
    
    [Required]
    [StringLength(100)]
    public string LastName { get; set; }
    
    public DateTime DateOfBirth { get; set; }
    
    [EmailAddress]
    public string Email { get; set; }
    
    // Foreign key
    public int CompanyId { get; set; }
    
    // Navigation property (many-to-one)
    public Company Company { get; set; }
}
```

### DbContext Configuration

Create `AppDbContext.cs`:

```csharp
using Microsoft.EntityFrameworkCore;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
    
    public DbSet<Company> Companies { get; set; }
    public DbSet<Person> People { get; set; }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        // Configure relationships
        modelBuilder.Entity<Person>()
            .HasOne(p => p.Company)
            .WithMany(c => c.Employees)
            .HasForeignKey(p => p.CompanyId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

## Code Generation Process

### Understanding coalesce_generate

The `coalesce_generate` command inspects your C# models and generates:

- **REST API endpoints** — Automatic CRUD operations
- **Data Transfer Objects (DTOs)** — API request/response models
- **TypeScript types** — Type-safe models for Vue consumption
- **API client** — Generated service for making API calls
- **Validation rules** — Based on C# attributes
- **OpenAPI documentation** — Swagger UI integration

### Running Code Generation

1. **Ensure the database connection is configured** in `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=MyCoalesceAppDb;Trusted_Connection=true;"
  }
}
```

2. **Create initial migration** (if database is new):
```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

3. **Run Coalesce code generation:**
```bash
# From the project directory
coalesce_generate

# Or if coalesce CLI is not installed globally:
dotnet tool install -g IntelliTect.Coalesce.CodeGeneration
coalesce_generate
```

The command will:
- Read models from the project
- Connect to the database (to understand schema)
- Generate TypeScript types in `wwwroot/coalesce/models`
- Generate API client in `wwwroot/coalesce/api-client`
- Generate metadata for code generation

### Generated File Structure

After running `coalesce_generate`:

```
wwwroot/coalesce/
├── models/
│   ├── company.ts              # TypeScript model
│   ├── company.d.ts            # Type definitions
│   └── person.ts
├── api-client/
│   ├── company.ts              # Generated API service
│   ├── person.ts
│   └── index.ts
├── metadata.g.ts               # Coalesce metadata
└── generated.ts                # Re-export of all generated types
```

## TypeScript Type Synchronization

### Automatic Synchronization

TypeScript types are **automatically generated from C# models** when you run `coalesce_generate`. This ensures type safety across your full stack.

### Example Sync

**C# Model:**
```csharp
public class Person
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    public DateTime DateOfBirth { get; set; }
}
```

**Generated TypeScript:**
```typescript
// models/person.ts
export class Person {
    public personId: number = null!;
    public firstName: string = null!;
    public dateOfBirth: Date = null!;
}
```

**Accessing in Vue:**
```typescript
import { Person } from '@/coalesce/models';

const person = ref<Person>(new Person());
person.value.firstName = "John";  // Type-safe!
```

### Re-generating After Model Changes

Workflow for adding a property:

1. **Add property to C# model:**
```csharp
[Required]
[StringLength(20)]
public string PhoneNumber { get; set; }
```

2. **Create migration (if schema changed):**
```bash
dotnet ef migrations add AddPhoneNumber
dotnet ef database update
```

3. **Regenerate Coalesce:**
```bash
coalesce_generate
```

4. **Verify TypeScript types updated:**
```typescript
// Build should succeed with new property
const person = new Person();
person.phoneNumber = "555-1234";
```

## Common Workflow Patterns

### Pattern 1: Adding a New Entity

```plaintext
1. Create C# model with properties and validation
2. Add DbSet to AppDbContext
3. Create EF Core migration
4. Run coalesce_generate
5. Create Vue component for the entity
6. Wire up list view and forms with generated API client
7. Test CRUD operations end-to-end
```

### Pattern 2: Implementing Complex Filtering

```plaintext
1. Add filter properties to model (with [Bind] attribute)
2. Optionally add [Search] for full-text search
3. Regenerate Coalesce
4. Use generated filters in Vue list components
5. Test pagination and filtering performance
```

### Pattern 3: Implementing Role-Based Access

```plaintext
1. Add [Restrict] attributes to model/properties
2. Implement authorization in custom service methods
3. Regenerate to apply restrictions to API
4. Test access control through UI
```

### Pattern 4: Working with Complex Relationships

```plaintext
1. Design entities and relationships (1-M, M-M)
2. Configure in DbContext OnModelCreating
3. Create migrations with proper foreign keys
4. Regenerate Coalesce
5. Load related data using include/expand in Vue
6. Bind nested collections in UI
```

## Troubleshooting Code Generation

### Issue: "coalesce_generate not found"

**Solution:** Install the Coalesce code generation tool:
```bash
dotnet tool install -g IntelliTect.Coalesce.CodeGeneration
```

Or run via dotnet:
```bash
dotnet tool run coalesce_generate
```

### Issue: Database Connection Failed

**Check:**
1. Connection string in `appsettings.json` is correct
2. Database server is running
3. User has permissions to connect
4. Migrations have been applied (`dotnet ef database update`)

**Solution:**
```bash
# Verify connection
dotnet ef database info

# Update database to latest migration
dotnet ef database update
```

### Issue: Generated Types Don't Match Model

**Check:**
1. Run `coalesce_generate` again after model changes
2. Ensure migrations were applied to the database
3. Check for uncommitted changes in the project

**Solution:**
```bash
# Rebuild and regenerate
dotnet clean
dotnet build
coalesce_generate
```

### Issue: TypeScript Compilation Errors

**Check:**
1. Verify generated files are in correct location (`wwwroot/coalesce/`)
2. Check tsconfig.json paths are configured correctly
3. Ensure all dependencies are installed (`npm install`)

**Solution:**
```bash
# Reinstall dependencies
npm install

# Clear generated cache
rm -rf wwwroot/coalesce/

# Regenerate
coalesce_generate

# Rebuild TypeScript
npm run build
```

## Best Practices for Model Design

### 1. Use Meaningful Names
- Model: `Person`, `Company`, `Order` (singular nouns)
- Properties: `FirstName`, `LastName`, `DateOfBirth` (PascalCase)
- Foreign Keys: `CompanyId` (Entity + Id)

### 2. Include Validation Attributes
```csharp
[Required]
[StringLength(100)]
[EmailAddress]
public string Email { get; set; }
```

Validation attributes are automatically converted to TypeScript constraints and API validation.

### 3. Design for Discoverability
Coalesce generates APIs for all public properties. Hide internal properties:
```csharp
[ApiExplorerSettings(IgnoreApi = true)]
public string InternalField { get; set; }
```

### 4. Plan Navigation Properties Carefully
- Use `ICollection<T>` for one-to-many relationships
- Consider lazy loading implications
- Use `[Bind(false)]` to exclude large collections from API responses

### 5. Version Your API
If making breaking changes, version the API:
```csharp
[ApiController]
[Route("api/v1/[controller]")]
public class PersonController : ControllerBase { }
```

### 6. Use DTOs for Sensitive Data
For properties that shouldn't be exposed via API, create a DTO:
```csharp
public class PersonDto
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    // Exclude sensitive properties
}
```

## Performance Considerations

### 1. Eager Load Related Data
```csharp
public IQueryable<Person> GetPeople()
{
    return _context.People.Include(p => p.Company);
}
```

### 2. Paginate Large Result Sets
Coalesce supports built-in paging:
```typescript
// Generated API client
const result = await PersonService.list(null, {
    pageSize: 20,
    pageNumber: 1
});
```

### 3. Optimize Database Indexes
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Person>()
        .HasIndex(p => p.Email)
        .IsUnique();
}
```

### 4. Use Projections for Large Models
```csharp
[Coalesce]
public class PersonListDto
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    // Exclude large properties for list view
}
```

## Next Steps

- Review **EF Core Patterns** guide for advanced model design
- Study **Code Generation** guide for customization options
- Explore Coalesce samples at [https://coalesce.intellitect.com/](https://coalesce.intellitect.com/)
