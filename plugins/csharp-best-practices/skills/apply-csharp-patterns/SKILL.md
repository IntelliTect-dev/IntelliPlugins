---
name: apply-csharp-patterns
description: Apply enterprise C# patterns including error handling, dependency injection, and clean code principles
---

# Apply C# Patterns Skill

Apply idiomatic C# language patterns including type design, null handling, pattern matching, LINQ, and modern C# features for clean, maintainable enterprise code.

## When to Use

Invoke this skill when you:
- Need to refactor existing code to follow C# best practices
- Are writing new C# code and want to apply proper patterns
- Want a review of C# language feature usage in a file or class
- Are modernizing older C# code to use current language features

# C# Language Patterns & Best Practices

Comprehensive guide to idiomatic C# patterns, type design, and language features for writing maintainable, performant code.

## Table of Contents
1. [Type Design & Organization](#type-design--organization)
2. [Naming Conventions](#naming-conventions-overview)
3. [Property Patterns](#property-patterns)
4. [Null Handling](#null-handling)
5. [Pattern Matching](#pattern-matching)
6. [LINQ Best Practices](#linq-best-practices)
7. [Collections & Iteration](#collections--iteration)
8. [Modern C# Features](#modern-c-features)

## Type Design & Organization

### Classes

Use classes for reference types that encapsulate mutable state or behavior.

```csharp
//  Good: Clear responsibility, well-organized
public class UserService
{
    private readonly IUserRepository _repository;
    private readonly ILogger<UserService> _logger;

    public UserService(IUserRepository repository, ILogger<UserService> logger)
    {
        _repository = repository;
        _logger = logger;
    }

    public async Task<User?> GetUserAsync(int userId)
    {
        try
        {
            return await _repository.GetUserAsync(userId);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to retrieve user {UserId}", userId);
            throw;
        }
    }
}

//  Avoid: God object with too many responsibilities
public class UserManager
{
    // Methods for authentication, authorization, repository access, logging, caching, etc.
    // Too many responsibilities
}
```

### Records

Use records for immutable data transfer objects, value objects, and DTOs. Records automatically implement equality, hashing, and ToString.

```csharp
//  Good: Immutable record for domain value object
public record Money(decimal Amount, string Currency)
{
    public static Money Zero(string currency) => new(0, currency);
}

//  Good: Record for API response
public record UserResponse(int Id, string Name, string Email, DateOnly CreatedDate);

//  Good: Record with validation (init-only properties with backing field)
public record User
{
    private decimal _salary;
    
    public int Id { get; init; }
    public string Name { get; init; } = string.Empty;
    
    public decimal Salary
    {
        get => _salary;
        init => _salary = value >= 0 ? value : throw new ArgumentException("Salary cannot be negative");
    }
}

//  Avoid: Using classes when records are more appropriate
public class Money
{
    public decimal Amount { get; }
    public string Currency { get; }
    
    public Money(decimal amount, string currency)
    {
        Amount = amount;
        Currency = currency;
    }
    
    // Must manually implement Equals, GetHashCode, ToString, etc.
}
```

### Interfaces

Use interfaces to define contracts and enable dependency injection and polymorphism.

```csharp
//  Good: Single responsibility, domain-focused
public interface IUserRepository
{
    Task<User?> GetUserAsync(int userId);
    Task<IEnumerable<User>> GetUsersAsync();
    Task AddUserAsync(User user);
    Task UpdateUserAsync(User user);
    Task DeleteUserAsync(int userId);
}

//  Good: Separate interfaces for different concerns
public interface IUserValidator
{
    bool IsValidEmail(string email);
    bool IsValidPassword(string password);
}

//  Avoid: Large, unfocused interfaces (Interface Segregation Principle)
public interface IUserService
{
    Task<User> GetUser(int id);
    Task CreateUser(User user);
    bool ValidateEmail(string email);
    bool ValidatePassword(string password);
    Task SendWelcomeEmail(User user);
    Task UpdateUserLastLogin(int userId);
    // ... 20 more methods
}
```

### Enums

Use enums for fixed sets of named constants. Prefer enum-based validation over magic numbers.

```csharp
//  Good: Type-safe enum
public enum UserRole
{
    Admin,
    Manager,
    Employee,
    Guest
}

public enum OrderStatus
{
    Pending = 1,
    Confirmed = 2,
    Shipped = 3,
    Delivered = 4,
    Cancelled = 5
}

//  Good: Using enum with pattern matching
public string GetStatusDescription(OrderStatus status) => status switch
{
    OrderStatus.Pending => "Order is pending confirmation",
    OrderStatus.Confirmed => "Order confirmed, awaiting shipment",
    OrderStatus.Shipped => "Order shipped",
    OrderStatus.Delivered => "Order delivered",
    OrderStatus.Cancelled => "Order cancelled",
    _ => throw new ArgumentException($"Unknown status: {status}")
};

//  Avoid: Magic numbers without context
public int GetUserLevel(int userType)
{
    return userType switch
    {
        1 => 100,  // What do 1 and 100 mean?
        2 => 50,
        3 => 25,
        _ => 0
    };
}
```

### Static Classes

Use static classes for utility functions and stateless operations.

```csharp
//  Good: Static utility class with related functions
public static class StringExtensions
{
    public static bool IsNullOrEmpty(this string? value) => string.IsNullOrEmpty(value);
    
    public static string Truncate(this string value, int maxLength)
    {
        return value?.Length > maxLength ? value[..maxLength] + "..." : value ?? string.Empty;
    }
}

//  Good: Static factory methods for construction
public static class UserFactory
{
    public static User CreateGuest() => new() { Name = "Guest", Role = UserRole.Guest };
    
    public static User CreateFromEmail(string email) => new() { Email = email };
}
```

---

## Naming Conventions (Overview)

Refer to `naming-conventions.md` for comprehensive naming patterns. Key principles:

- **PascalCase:** Types, methods, properties, constants, enum members
- **camelCase:** Local variables, method parameters
- **_camelCase:** Private fields
- **CONSTANT:** All-caps for module-level constants (uncommon in modern C#)

---

## Property Patterns

### Auto-Properties

Use auto-properties for simple get/set patterns. The compiler generates the backing field.

```csharp
//  Good: Simple auto-property
public class User
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
}

//  Good: Read-only auto-property (initialized at construction)
public class Order
{
    public int Id { get; }
    public DateTime CreatedDate { get; } = DateTime.UtcNow;
    
    public Order(int id)
    {
        Id = id;
    }
}

//  Good: Init-only properties (immutable after initialization)
public class Product
{
    public int Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public decimal Price { get; init; }
}
```

### Property Initialization

Initialize properties at declaration or in constructors to avoid null reference exceptions.

```csharp
//  Good: Field initialization with default values
public class Configuration
{
    public int MaxRetries { get; set; } = 3;
    public TimeSpan Timeout { get; set; } = TimeSpan.FromSeconds(30);
    public List<string> AllowedHosts { get; set; } = new();
}

//  Good: Property initialization with nullable reference types
public class UserProfile
{
    public string? Biography { get; set; }
    public string? ProfileImageUrl { get; set; }
}

//  Avoid: Uninitialized properties that might be null
public class BadConfiguration
{
    public List<string> Servers { get; set; }  // Uninitialized - potential NullReferenceException
}
```

### Computed Properties

Use computed properties for simple calculations; use methods for complex operations.

```csharp
//  Good: Simple computed property
public class Order
{
    public decimal Subtotal { get; set; }
    public decimal TaxRate { get; set; } = 0.08m;
    
    public decimal Tax => Subtotal * TaxRate;
    public decimal Total => Subtotal + Tax;
}

//  Good: Expression-bodied properties
public class Rectangle
{
    public double Width { get; set; }
    public double Height { get; set; }
    
    public double Area => Width * Height;
}

//  Avoid: Complex logic in properties (use methods instead)
public class DataProcessor
{
    public IEnumerable<Data>? ProcessedData
    {
        get
        {
            var raw = FetchData();
            var filtered = FilterOutliers(raw);
            var normalized = Normalize(filtered);
            var grouped = GroupByCategory(normalized);
            return grouped;  // Too complex for a property
        }
    }
}
```

---

## Null Handling

### Nullable Reference Types

Enable nullable reference types in your project to catch null reference exceptions at compile time.

```csharp
// In .csproj:
// <Nullable>enable</Nullable>

//  Good: Nullable reference types enabled
public class User
{
    public string Name { get; set; } = string.Empty;  // Non-nullable - must be initialized
    public string? Email { get; set; }  // Nullable - can be null
    
    public string GetEmail() => Email ?? "No email";
}

//  Good: Handling nullable parameters
public void SendEmail(string? emailAddress)
{
    if (string.IsNullOrEmpty(emailAddress))
    {
        return;
    }
    
    _emailService.Send(emailAddress);
}
```

### Null-Coalescing Operators

Use null-coalescing operators for clean, concise null checking.

```csharp
//  Good: Null coalescing operator (??)
string email = user.Email ?? "default@example.com";

//  Good: Null coalescing assignment (??=)
user.LastModified ??= DateTime.UtcNow;
configuration.Port ??= 8080;

//  Good: Chained null coalescing
string city = user?.Address?.City ?? "Unknown City";

//  Avoid: Nested ternary operators
string result = user != null ? user.Email != null ? user.Email : "no-email" : "no-user";
```

### Null-Forgiving Operator

Use the null-forgiving operator (!) only when you're certain a value is not null.

```csharp
//  Good: Using null-forgiving operator when certain
public class DataCache
{
    private Dictionary<int, User> _cache = new();
    
    public User GetUser(int id)
    {
        if (_cache.TryGetValue(id, out var user))
        {
            return user!;  // Certain it's not null from TryGetValue
        }
        
        throw new KeyNotFoundException();
    }
}

//  Avoid: Overusing null-forgiving operator (defeats null safety)
public string ProcessUser(User? user)
{
    var name = user!.Name;  // Not certain user is not null
    var email = user!.Email!;  // Dangerous!
}
```

### Optional Parameters

Use optional parameters with null for truly optional behavior.

```csharp
//  Good: Optional parameter with null default
public async Task<User?> GetUserAsync(int userId, CancellationToken cancellationToken = default)
{
    return await _repository.GetUserAsync(userId, cancellationToken);
}

//  Good: Distinguishing between "not provided" and "null"
public void UpdateUser(User user, string? newEmail = null, string? newPhone = null)
{
    if (newEmail != null)
        user.Email = newEmail;
    
    if (newPhone != null)
        user.Phone = newPhone;
}
```

---

## Pattern Matching

Pattern matching simplifies complex conditionals and type checking.

### Type Patterns

```csharp
//  Good: Type pattern
public string ProcessData(object data) => data switch
{
    string s => $"String: {s}",
    int i => $"Integer: {i}",
    List<string> list => $"String list with {list.Count} items",
    null => "No data",
    _ => "Unknown type"
};

//  Good: Type pattern with when condition
public decimal CalculateTax(object income) => income switch
{
    int i when i < 20000 => i * 0.05m,
    int i when i < 50000 => i * 0.15m,
    int i => i * 0.25m,
    _ => 0
};
```

### Property Patterns

```csharp
//  Good: Property pattern matching
public string GetStatus(User user) => user switch
{
    { IsActive: true, Role: UserRole.Admin } => "Active Admin",
    { IsActive: true, Role: UserRole.Manager } => "Active Manager",
    { IsActive: false } => "Inactive",
    _ => "Unknown"
};

//  Good: Nested property patterns
public bool IsValidOrder(Order order) => order switch
{
    { Customer: not null, Customer.IsVerified: true, Items.Count: > 0, Total: > 0 } => true,
    _ => false
};
```

### Relational Patterns

```csharp
//  Good: Relational patterns with numbers
public string GetPriceCategory(decimal price) => price switch
{
    < 10 => "Budget",
    >= 10 and < 50 => "Standard",
    >= 50 and < 100 => "Premium",
    >= 100 => "Luxury"
};

//  Good: Combining patterns
public string GetDiscount(Order order) => (order.Customer.Tier, order.Total) switch
{
    ("Premium", >= 500) => "20% discount",
    ("Premium", >= 100) => "15% discount",
    ("Standard", >= 100) => "10% discount",
    _ => "No discount"
};
```

---

## LINQ Best Practices

### Query Syntax vs Method Syntax

Use query syntax for complex queries with multiple filters, joins, and projections. Use method syntax for simple operations.

```csharp
//  Good: Query syntax for complex queries
var activeUsers = from user in _repository.GetUsers()
                  where user.IsActive && user.JoinDate < cutoffDate
                  orderby user.Name
                  select new { user.Id, user.Name, user.Email };

//  Good: Method syntax for simple operations
var count = users.Where(u => u.IsActive).Count();
var first = users.FirstOrDefault();

//  Good: Method syntax for chaining simple operations
var result = users
    .Where(u => u.IsActive)
    .OrderBy(u => u.Name)
    .Take(10)
    .ToList();
```

### Deferred Execution

Understand that LINQ queries are lazily evaluated. Materialize with ToList() when needed.

```csharp
//  Good: Deferred execution (query not executed until enumeration)
IEnumerable<User> GetActiveUsers()
{
    return _repository.GetUsers().Where(u => u.IsActive);
}

//  Good: Materializing when needed
List<User> GetActiveUsersList()
{
    return _repository.GetUsers().Where(u => u.IsActive).ToList();
}

//  Good: Multiple enumeration with materialization
var users = _repository.GetUsers().Where(u => u.IsActive).ToList();
var count = users.Count;  // Second enumeration safe
var first = users.FirstOrDefault();

//  Avoid: Multiple enumeration without materialization (multiple database queries)
IEnumerable<User> activeUsers = _repository.GetUsers().Where(u => u.IsActive);
var count = activeUsers.Count();  // Query executed
var first = activeUsers.FirstOrDefault();  // Query executed again!
```

### Performance Considerations

Filter at the source (database) rather than in memory.

```csharp
//  Good: Filtering in database query
var recentUsers = _repository.GetUsers()
    .Where(u => u.JoinDate > DateTime.UtcNow.AddMonths(-6))
    .ToList();

//  Avoid: Pulling all data and filtering in memory
var allUsers = _repository.GetUsers().ToList();
var recentUsers = allUsers.Where(u => u.JoinDate > DateTime.UtcNow.AddMonths(-6)).ToList();

//  Good: Use AsNoTracking for read-only queries (EF Core)
var users = _context.Users.AsNoTracking().Where(u => u.IsActive).ToList();

//  Good: Using Any() instead of Count() > 0
if (users.Any(u => u.IsActive)) { }  // More efficient

//  Avoid: Using Count() for existence check
if (users.Where(u => u.IsActive).Count() > 0) { }
```

### LINQ Operators

Common LINQ operations and when to use them.

```csharp
//  Good: Select for transformation
var userNames = users.Select(u => u.Name).ToList();

//  Good: SelectMany for flattening
var allOrders = customers.SelectMany(c => c.Orders).ToList();

//  Good: GroupBy for aggregation
var usersByRole = users.GroupBy(u => u.Role)
    .ToDictionary(g => g.Key, g => g.ToList());

//  Good: Join for relational operations
var userOrders = from user in users
                 join order in orders on user.Id equals order.UserId
                 select new { user.Name, order.OrderId };

//  Good: Distinct for uniqueness
var uniqueRoles = users.Select(u => u.Role).Distinct();

//  Good: OrderBy/ThenBy for multi-level sorting
var sorted = users.OrderBy(u => u.Role).ThenBy(u => u.Name);
```

---

## Collections & Iteration

### Choosing Collections

Use the right collection for your use case.

```csharp
//  Good: List for indexed access, fast insertion at end
List<User> users = new();
users.Add(user);
var first = users[0];

//  Good: Dictionary for key-value lookups
Dictionary<int, User> userCache = new();
if (userCache.TryGetValue(userId, out var user)) { }

//  Good: HashSet for unique items and containment checks
HashSet<string> emails = new(StringComparer.OrdinalIgnoreCase);
if (emails.Contains(email)) { }

//  Good: Queue/Stack for FIFO/LIFO semantics
Queue<Message> messageQueue = new();
messageQueue.Enqueue(message);

//  Good: IEnumerable for sequences without modification
IEnumerable<User> GetUsers() => _users.Where(u => u.IsActive);
```

### Iteration Patterns

```csharp
//  Good: Using foreach for simple iteration
foreach (var user in users)
{
    ProcessUser(user);
}

//  Good: Using for when index is needed
for (int i = 0; i < users.Count; i++)
{
    Console.WriteLine($"{i}: {users[i].Name}");
}

//  Good: Using LINQ ForEach for side effects (when appropriate)
users.ForEach(u => _logger.Log(u.Name));

//  Good: Using string.Join for formatting lists
string userNames = string.Join(", ", users.Select(u => u.Name));

//  Avoid: Modifying collections during iteration
foreach (var user in users)
{
    if (user.IsInactive)
        users.Remove(user);  // Can cause skipped items
}

//  Good: Create a separate list for removals
var inactiveUsers = users.Where(u => u.IsInactive).ToList();
foreach (var user in inactiveUsers)
{
    users.Remove(user);
}
```

---

## Modern C# Features

### Records with Positional Members

```csharp
//  Good: Concise record declaration
public record Address(string Street, string City, string State, string ZipCode);

public record User(int Id, string Name, string Email, Address Address);

// Usage with deconstruction
var (id, name, email, address) = user;
```

### Init-Only Properties

```csharp
//  Good: Immutable after initialization
public record Product
{
    public int Id { get; init; }
    public string Name { get; init; } = string.Empty;
    public decimal Price { get; init; }
}

var product = new Product { Id = 1, Name = "Widget", Price = 99.99m };
// product.Price = 50;  // Compile error - cannot modify init-only property
```

### Required Members

```csharp
//  Good: Required properties (C# 11+)
public class Order
{
    public required int OrderId { get; init; }
    public required DateTime OrderDate { get; init; }
    public string? SpecialInstructions { get; init; }
}

// var order = new Order();  // Compile error - missing required members
var order = new Order { OrderId = 1, OrderDate = DateTime.UtcNow };
```

### Tuples

```csharp
//  Good: Returning multiple values
public (bool Success, string Message, User? User) TryGetUser(int id)
{
    var user = _repository.Find(id);
    return user != null 
        ? (true, "Found", user)
        : (false, "Not found", null);
}

var (success, message, user) = TryGetUser(123);

//  Good: Named tuples for clarity
public record PagedResult(List<User> Items, int Total, int PageNumber, int PageSize);
```

### Using Declarations

```csharp
//  Good: Using declaration (automatically disposes at end of scope)
public async Task ProcessFileAsync(string path)
{
    using var stream = File.OpenRead(path);
    var data = await stream.ReadAllBytesAsync();
    // stream automatically disposed here
}

//  Good: Multiple using declarations
public void CopyFile(string source, string dest)
{
    using var sourceFile = File.OpenRead(source);
    using var destFile = File.OpenWrite(dest);
    sourceFile.CopyTo(destFile);
    // Both files automatically disposed here
}
```

---

## Summary

Follow these patterns to write clean, idiomatic C# code:

- Design types with single responsibility
- Use records for immutable data
- Apply nullable reference types
- Leverage pattern matching for clarity
- Choose appropriate collections
- Filter at the source in LINQ queries
- Use modern C# features (records, init, required, tuples)

See `naming-conventions.md` for detailed naming guidance and `async-patterns.md` for asynchronous programming patterns.
