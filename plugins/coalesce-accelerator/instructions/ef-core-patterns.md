# Entity Framework Core Patterns with Coalesce

This guide covers Entity Framework Core (EF Core) best practices, patterns, and configurations specifically for Coalesce development.

## Model Design for Coalesce

### Basic Entity Structure

Coalesce entities should follow this pattern:

```csharp
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

[Table("Companies")]
public class Company
{
    [Key]
    public int CompanyId { get; set; }
    
    [Required(ErrorMessage = "Company name is required")]
    [StringLength(255, ErrorMessage = "Name cannot exceed 255 characters")]
    [Display(Name = "Company Name")]
    public string Name { get; set; }
    
    [EmailAddress(ErrorMessage = "Invalid email address")]
    public string Email { get; set; }
    
    [Phone]
    public string PhoneNumber { get; set; }
    
    [Range(typeof(DateTime), "1/1/2000", "1/1/2100")]
    public DateTime? FoundedDate { get; set; }
    
    // Navigation property
    public ICollection<Person> Employees { get; set; } = new List<Person>();
    
    // Metadata
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? UpdatedAt { get; set; }
}
```

### Key Conventions

1. **Primary Key** — Name property `{EntityName}Id` (e.g., `CompanyId`, `PersonId`)
2. **Required Properties** — Use `[Required]` attribute
3. **String Length** — Use `[StringLength]` to define database column size
4. **Validation** — Use data annotation attributes for validation
5. **Display Names** — Use `[Display]` for UI labels in generated views
6. **Navigation Properties** — Use `ICollection<T>` for collections

## Relationship Patterns

### One-to-Many Relationship

**Most common pattern** — Parent has multiple children.

**Models:**
```csharp
public class Department
{
    public int DepartmentId { get; set; }
    public string Name { get; set; }
    public ICollection<Employee> Employees { get; set; } = new List<Employee>();
}

public class Employee
{
    public int EmployeeId { get; set; }
    public string Name { get; set; }
    
    // Foreign key
    public int DepartmentId { get; set; }
    
    // Navigation property
    public Department Department { get; set; }
}
```

**DbContext Configuration:**
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Employee>()
        .HasOne(e => e.Department)
        .WithMany(d => d.Employees)
        .HasForeignKey(e => e.DepartmentId)
        .OnDelete(DeleteBehavior.Restrict);  // Prevent orphans
}
```

**API Generated:**
- GET `/api/Department/{id}` — Returns department with embedded employees
- GET `/api/Employee?DepartmentId={id}` — Filter by department
- POST `/api/Department` — Create with nested employees

**Vue Usage:**
```typescript
import { Department } from '@/coalesce/models';
import { DepartmentService } from '@/coalesce/api-client';

const department = ref<Department>();

onMounted(async () => {
    const result = await DepartmentService.get(1);
    if (result.wasSuccessful) {
        department.value = result.object;
    }
});
```

### Many-to-Many Relationship

**Pattern** — Two entities with independent collections.

**Example:** Students and Courses (each student can take multiple courses, each course has multiple students).

**Models:**
```csharp
public class Student
{
    public int StudentId { get; set; }
    public string Name { get; set; }
    public ICollection<StudentCourse> StudentCourses { get; set; } = new List<StudentCourse>();
}

public class Course
{
    public int CourseId { get; set; }
    public string Title { get; set; }
    public ICollection<StudentCourse> StudentCourses { get; set; } = new List<StudentCourse>();
}

// Junction table (bridge entity)
public class StudentCourse
{
    public int StudentId { get; set; }
    public Student Student { get; set; }
    
    public int CourseId { get; set; }
    public Course Course { get; set; }
    
    // Additional properties for the relationship
    public DateTime EnrolledDate { get; set; }
    public decimal? Grade { get; set; }
}
```

**DbContext Configuration:**
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Define composite primary key
    modelBuilder.Entity<StudentCourse>()
        .HasKey(sc => new { sc.StudentId, sc.CourseId });
    
    // Foreign key relationships
    modelBuilder.Entity<StudentCourse>()
        .HasOne(sc => sc.Student)
        .WithMany(s => s.StudentCourses)
        .HasForeignKey(sc => sc.StudentId);
    
    modelBuilder.Entity<StudentCourse>()
        .HasOne(sc => sc.Course)
        .WithMany(c => c.StudentCourses)
        .HasForeignKey(sc => sc.CourseId);
}
```

**Vue Usage:**
```typescript
// Load student with enrolled courses
const student = ref<Student>();
student.value = await StudentService.get(1);

// Iterate through courses
student.value.studentCourses?.forEach(enrollment => {
    console.log(`${enrollment.course?.title}: ${enrollment.grade}`);
});
```

### Self-Referential Relationship

**Pattern** — Entity references itself (e.g., manager/employee, parent/child comments).

**Model:**
```csharp
public class Employee
{
    public int EmployeeId { get; set; }
    public string Name { get; set; }
    
    // Manager reference (nullable - CEO has no manager)
    public int? ManagerId { get; set; }
    public Employee Manager { get; set; }
    
    // Direct reports
    public ICollection<Employee> DirectReports { get; set; } = new List<Employee>();
}
```

**DbContext Configuration:**
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    modelBuilder.Entity<Employee>()
        .HasOne(e => e.Manager)
        .WithMany(e => e.DirectReports)
        .HasForeignKey(e => e.ManagerId)
        .OnDelete(DeleteBehavior.Restrict);
}
```

**Vue Usage:**
```typescript
// Load organizational hierarchy
const ceo = await EmployeeService.get(1);
ceo.directReports?.forEach(report => {
    console.log(`${report.name} reports to ${ceo.name}`);
});
```

## Data Annotations and Configurations

### Validation Attributes

```csharp
public class Product
{
    [Required(ErrorMessage = "Product name is required")]
    public string Name { get; set; }
    
    [Range(0.01, double.MaxValue, ErrorMessage = "Price must be greater than 0")]
    public decimal Price { get; set; }
    
    [StringLength(500, MinimumLength = 10)]
    public string Description { get; set; }
    
    [EmailAddress]
    public string ContactEmail { get; set; }
    
    [Phone]
    public string ContactPhone { get; set; }
    
    [RegularExpression(@"^\d{5}-\d{4}$", ErrorMessage = "ZIP code must be in format XXXXX-XXXX")]
    public string ZipCode { get; set; }
}
```

Coalesce automatically:
- Adds validation to generated API
- Generates TypeScript validation rules
- Displays validation errors in UI forms

### Display and Metadata Attributes

```csharp
public class Product
{
    [Display(Name = "Product ID", Order = 1)]
    public int ProductId { get; set; }
    
    [Display(Name = "Product Name", Order = 2, Description = "The name of the product")]
    public string Name { get; set; }
    
    [Display(Name = "List Price", Order = 3)]
    [DisplayFormat(DataFormatString = "{0:C}")]
    public decimal Price { get; set; }
    
    [Display(Name = "Available", Order = 4)]
    public bool IsAvailable { get; set; }
}
```

### Binding Control

```csharp
public class User
{
    public int UserId { get; set; }
    
    [Required]
    public string Email { get; set; }
    
    // Exclude from API/binding
    [Bind(false)]
    [ScaffoldColumn(false)]
    public string PasswordHash { get; set; }
    
    // Exclude large collection from API responses
    [Bind(false)]
    public ICollection<AuditLog> AuditLogs { get; set; }
}
```

## Lazy Loading vs Eager Loading vs Explicit Loading

### Lazy Loading (Default)

Related data is loaded only when accessed:

```csharp
// Lazy loading disabled by default in EF Core
var employee = await _context.Employees.FirstAsync(e => e.EmployeeId == 1);
// Department not loaded yet

var department = employee.Department; // LAZY LOAD - Database call here
```

**Pros:** Only load data when needed; less memory overhead
**Cons:** N+1 query problem if not careful; unpredictable performance

### Eager Loading (Recommended for Coalesce)

Related data is loaded immediately with `.Include()`:

```csharp
// Load employee with related department
var employee = await _context.Employees
    .Include(e => e.Department)
    .FirstAsync(e => e.EmployeeId == 1);

var department = employee.Department; // Already loaded
```

**Pros:** Predictable, single query; prevents N+1 problems
**Cons:** May load unnecessary data

**In Coalesce services:**
```csharp
[Coalesce]
public class EmployeeService : StandardDataService<Employee, AppDbContext>
{
    public override IQueryable<Employee> GetQuery()
    {
        return base.GetQuery()
            .Include(e => e.Department)
            .Include(e => e.Manager);
    }
}
```

### Explicit Loading

Load related data on-demand:

```csharp
var employee = await _context.Employees.FirstAsync(e => e.EmployeeId == 1);

// Explicitly load department later
await _context.Entry(employee)
    .Reference(e => e.Department)
    .LoadAsync();
```

**Pros:** Flexible; load different data based on context
**Cons:** Multiple database queries; requires careful orchestration

## Validation with Coalesce

### Model-Level Validation

Use data annotations for automatic validation:

```csharp
public class Order
{
    [Required]
    public int OrderId { get; set; }
    
    [Required(ErrorMessage = "Customer is required")]
    public int CustomerId { get; set; }
    
    [Range(0.01, double.MaxValue)]
    public decimal TotalAmount { get; set; }
    
    [Range(typeof(DateTime), "1/1/2020", "1/1/2100")]
    public DateTime OrderDate { get; set; }
}
```

### Custom Validation Logic

Implement `IValidatableObject` for complex rules:

```csharp
public class Order : IValidatableObject
{
    public int OrderId { get; set; }
    public int CustomerId { get; set; }
    public decimal TotalAmount { get; set; }
    public DateTime OrderDate { get; set; }
    
    public IEnumerable<ValidationResult> Validate(ValidationContext context)
    {
        if (OrderDate > DateTime.Now)
            yield return new ValidationResult("Order date cannot be in the future");
        
        if (TotalAmount < 10)
            yield return new ValidationResult("Minimum order amount is $10");
    }
}
```

### Service-Level Validation

For business logic validation:

```csharp
[Coalesce]
public class OrderService : StandardDataService<Order, AppDbContext>
{
    public override async Task<SaveResult<Order>> BeforeSave(SaveRequest<Order> request)
    {
        var result = await base.BeforeSave(request);
        
        if (!result.IsSuccessful) return result;
        
        var order = request.Object;
        
        // Check customer exists
        var customer = await Db.Customers.FindAsync(order.CustomerId);
        if (customer == null)
            result.Errors.Add("CustomerId", "Customer not found");
        
        // Check inventory
        if (!await CheckInventoryAvailable(order))
            result.Errors.Add("Items", "Insufficient inventory");
        
        return result;
    }
}
```

## Migrations and Database Schema

### Creating Migrations

After creating or modifying models:

```bash
# Add migration with descriptive name
dotnet ef migrations add AddOrderTable
dotnet ef migrations add AddCustomerPhoneNumber
dotnet ef migrations add CreateStudentCourseRelationship
```

### Migration File Structure

```csharp
public partial class AddOrderTable : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Orders",
            columns: table => new
            {
                OrderId = table.Column<int>(),
                CustomerId = table.Column<int>(),
                TotalAmount = table.Column<decimal>(),
                OrderDate = table.Column<DateTime>(),
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Orders", x => x.OrderId);
                table.ForeignKey(
                    name: "FK_Orders_Customers_CustomerId",
                    column: x => x.CustomerId,
                    principalTable: "Customers",
                    principalColumn: "CustomerId",
                    onDelete: ReferentialAction.Restrict);
            });
    }
    
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "Orders");
    }
}
```

### Applying Migrations

```bash
# Update database to latest migration
dotnet ef database update

# Update to specific migration
dotnet ef database update AddOrderTable

# Revert to previous migration
dotnet ef database update PreviousMigrationName
```

### Best Practices

1. **Create migrations frequently** — Don't wait to run multiple changes
2. **Use descriptive names** — `AddCustomerPhoneNumber` not `Update1`
3. **Never modify applied migrations** — Create new migration for changes
4. **Script for production** — Use `dotnet ef migrations script` for production deployments
5. **Test on staging** — Verify migrations on test database first

## Navigation Properties and DTOs

### Navigation Properties in Coalesce

By default, Coalesce includes navigation properties in API responses:

```csharp
// Model with navigation properties
public class Person
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    
    public int CompanyId { get; set; }
    public Company Company { get; set; }  // Included in API response
}

// Generated API response
{
    "personId": 1,
    "firstName": "John",
    "companyId": 5,
    "company": {
        "companyId": 5,
        "name": "ACME Corp"
    }
}
```

### Excluding Navigation Properties

Use `[Bind(false)]` to exclude large collections:

```csharp
public class Company
{
    public int CompanyId { get; set; }
    public string Name { get; set; }
    
    // Exclude large collection from responses
    [Bind(false)]
    public ICollection<Person> Employees { get; set; }
}
```

### Using DTOs for Complex Scenarios

Create specialized models for specific use cases:

```csharp
// Entity model
public class Person
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public ICollection<Skill> Skills { get; set; }
}

// DTO for list view (minimal data)
[Coalesce]
public class PersonListDto
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
}

// DTO for detail view (rich data)
[Coalesce]
public class PersonDetailDto
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public ICollection<Skill> Skills { get; set; }
}
```

## Performance Patterns

### Indexing Strategy

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Single column index
    modelBuilder.Entity<Person>()
        .HasIndex(p => p.Email)
        .IsUnique();
    
    // Composite index
    modelBuilder.Entity<Person>()
        .HasIndex(p => new { p.FirstName, p.LastName })
        .HasName("IX_PersonName");
    
    // Include additional columns in index
    modelBuilder.Entity<Person>()
        .HasIndex(p => p.LastName)
        .IncludeProperties(p => p.FirstName, p => p.Email);
}
```

### Pagination for Large Result Sets

```csharp
[Coalesce]
public class PersonService : StandardDataService<Person, AppDbContext>
{
    public override IQueryable<Person> GetQuery()
    {
        return base.GetQuery()
            .Include(p => p.Company)
            .OrderBy(p => p.PersonId);
    }
}

// Use in Vue
const result = await PersonService.list(null, {
    pageSize: 50,
    pageNumber: 1,
    orderBy: "-personId"
});
```

### Filtering and Searching

```csharp
public class Person
{
    public int PersonId { get; set; }
    
    [Search]  // Enable full-text search
    public string FirstName { get; set; }
    
    [Search]
    public string LastName { get; set; }
    
    [Bind]    // Include in API filtering
    public string Email { get; set; }
}

// Generated API supports
// GET /api/Person?search=john&email=john@example.com
```

## Common Patterns and Examples

### Soft Deletes (Logical Deletion)

Instead of physically deleting records:

```csharp
public class Person
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    
    public bool IsDeleted { get; set; }
    public DateTime? DeletedAt { get; set; }
}

[Coalesce]
public class PersonService : StandardDataService<Person, AppDbContext>
{
    public override IQueryable<Person> GetQuery()
    {
        return base.GetQuery().Where(p => !p.IsDeleted);
    }
    
    public override async Task<SaveResult<Person>> BeforeDelete(Person item)
    {
        item.IsDeleted = true;
        item.DeletedAt = DateTime.UtcNow;
        await Db.SaveChangesAsync();
        return new SaveResult<Person> { Object = item };
    }
}
```

### Audit Trail

Track changes to entities:

```csharp
public class Person
{
    public int PersonId { get; set; }
    public string FirstName { get; set; }
    
    // Audit fields
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public string CreatedBy { get; set; }
    
    public DateTime? UpdatedAt { get; set; }
    public string UpdatedBy { get; set; }
}

public class AuditLog
{
    public int AuditLogId { get; set; }
    public string EntityType { get; set; }
    public int EntityId { get; set; }
    public string Action { get; set; }  // Created, Updated, Deleted
    public string UserId { get; set; }
    public DateTime Timestamp { get; set; }
    public string Changes { get; set; }  // JSON diff
}
```

## Integration with Coalesce Services

Services extend `StandardDataService<TModel, TContext>` to add business logic:

```csharp
[Coalesce]
public class PersonService : StandardDataService<Person, AppDbContext>
{
    private readonly IEmailService _emailService;
    
    public PersonService(AppDbContext db, IEmailService emailService) 
        : base(db)
    {
        _emailService = emailService;
    }
    
    public override async Task<SaveResult<Person>> BeforeSave(SaveRequest<Person> request)
    {
        var result = await base.BeforeSave(request);
        if (!result.IsSuccessful) return result;
        
        var person = request.Object;
        
        // Send welcome email for new users
        if (request.WasNew)
        {
            await _emailService.SendWelcomeAsync(person.Email);
        }
        
        return result;
    }
}
```

## Next Steps

- Study **Coalesce Workflows** for project setup and generation
- Review **Code Generation** guide for API customization
- Explore Coalesce samples at [https://coalesce.intellitect.com/](https://coalesce.intellitect.com/)
