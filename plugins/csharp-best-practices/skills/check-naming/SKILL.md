---
name: check-naming
description: Check C# naming conventions in a file or selection against Microsoft and project standards
---

# Check Naming Skill

Audit C# identifiers in the current file or selection for adherence to Microsoft naming conventions and enterprise project standards.

## When to Use

Invoke this skill when you:
- Want to validate naming before committing or opening a pull request
- Are reviewing code from someone unfamiliar with C# conventions
- Migrated code from another language and need a naming pass
- Want to enforce consistent style across a new file

## Conventions Checked

### Types (classes, interfaces, records, structs, enums)
```csharp
// ✅ PascalCase
public class UserAccountService { }
public interface IEmailSender { }
public record OrderSummary(int Id, decimal Total);
public enum OrderStatus { Pending, Active, Closed }

// ❌
public class userAccountService { }  // camelCase
public interface EmailSender { }     // missing I prefix
```

### Methods and properties
```csharp
// ✅ PascalCase
public string GetDisplayName() { }
public bool IsActive { get; set; }
public async Task<User> GetUserAsync(int id) { }  // Async suffix

// ❌
public string getDisplayName() { }  // camelCase
public async Task<User> GetUser(int id) { }  // missing Async suffix
```

### Private fields
```csharp
// ✅ _camelCase with underscore prefix
private readonly ILogger<MyService> _logger;
private string _cachedValue;

// ❌
private readonly ILogger<MyService> logger;  // no underscore
private string CachedValue;               // PascalCase for field
```

### Constants and static readonly
```csharp
// ✅ PascalCase
public const int MaxRetryCount = 3;
private static readonly TimeSpan DefaultTimeout = TimeSpan.FromSeconds(30);

// ❌
public const int MAX_RETRY_COUNT = 3;  // SCREAMING_CASE
```

### Parameters and local variables
```csharp
// ✅ camelCase
public void Process(int userId, string displayName) { }
var orderCount = orders.Count();

// ❌
public void Process(int UserId, string DisplayName) { }  // PascalCase
```

### Generic type parameters
```csharp
// ✅ T, or TKey/TValue for multiple parameters
public class Repository<T> where T : class { }
public class Dictionary<TKey, TValue> { }

// ❌
public class Repository<Entity> { }  // descriptive word without T prefix
```

## Review Output

For each violation found, report:
- **Identifier**: the name that violates the convention
- **Expected convention**: what it should be
- **Suggested name**: the corrected identifier
- **Location**: line number in the file


## Reference: Naming Conventions

# C# Naming Conventions & Code Organization

Professional naming conventions aligned with Microsoft guidelines and industry best practices.

## Table of Contents
1. [Type Naming](#type-naming)
2. [Member Naming](#member-naming)
3. [Field Naming](#field-naming)
4. [Generic Type Parameters](#generic-type-parameters)
5. [Async Method Naming](#async-method-naming)
6. [Enum Members](#enum-members)
7. [Constants](#constants)
8. [Best Practices & Avoiding Pitfalls](#best-practices--avoiding-pitfalls)

## Type Naming

All type names use **PascalCase** with descriptive, noun-based names.

### Classes

Use descriptive nouns that represent the object's responsibility.

```csharp
//  Good: Clear responsibility nouns
public class User { }
public class UserService { }
public class OrderProcessor { }
public class EmailNotification { }
public class AuthenticationProvider { }

//  Good: Domain-specific names
public class Invoice { }
public class CustomerAccount { }
public class PaymentGateway { }

//  Avoid: Vague names without context
public class Manager { }  // Manager of what?
public class Service { }  // What service?
public class Helper { }   // Helper for what?

//  Avoid: Abbreviations except for very common terms
public class UMgr { }     // Should be UserManager
public class CustSvc { }  // Should be CustomerService

//  Avoid: Hungarian notation or encoding
public class CUser { }      // Should be User (C prefix unnecessary)
public class clsUser { }    // Should be User (cls prefix unnecessary)
```

### Interfaces

Use descriptive names starting with **I** (uppercase I, not lowercase).

```csharp
//  Good: Clear interface contracts
public interface IRepository { }
public interface IUserService { }
public interface IEmailProvider { }
public interface IPaymentProcessor { }
public interface INotificationChannel { }

//  Avoid: I prefix without substance
public interface IManager { }  // What's being managed?

//  Avoid: Redundant suffixes
public interface IRepositoryInterface { }  // "Interface" is redundant

//  Avoid: Lowercase i (not standard C#)
public interface iRepository { }
```

### Records

Use the same naming as classes. Records are often used for DTOs and value objects.

```csharp
//  Good: Descriptive record names
public record User { }
public record CreateUserRequest { }
public record UserResponse { }
public record Address { }
public record Money { }

//  Good: Domain event records
public record UserCreatedEvent { }
public record PaymentProcessedEvent { }

//  Avoid: Abbreviations
public record Usr { }           // Should be User
public record CrtUsrReq { }     // Should be CreateUserRequest
```

### Structs

Use PascalCase for struct names. Use sparingly; prefer classes or records.

```csharp
//  Good: Value type structs for performance-critical scenarios
public struct Point { }
public struct Coordinate { }
public struct Money { }

//  Avoid: Structs for large data types (inefficient copying)
public struct UserData { }  // Should be a class or record
```

### Enums

Use singular or plural nouns appropriately. Enum member names are PascalCase.

```csharp
//  Good: Singular for status/state enums
public enum OrderStatus
{
    Pending,
    Confirmed,
    Shipped,
    Delivered,
    Cancelled
}

//  Good: Plural for collection enums
public enum UserPermissions
{
    Read,
    Write,
    Delete,
    Admin
}

//  Good: Named flag enums
[Flags]
public enum FilePermissions
{
    Read = 1,
    Write = 2,
    Execute = 4,
    All = Read | Write | Execute
}

//  Avoid: Prefixing enum values with enum name
public enum Color
{
    ColorRed,        // Should be Red
    ColorGreen,      // Should be Green
    ColorBlue        // Should be Blue
}

//  Avoid: Ambiguous enum names
public enum Status { }  // Status of what?
```

### Delegates

Use descriptive names with **Handler** or **Callback** suffix or a verb-based name.

```csharp
//  Good: Handler suffix for event handlers
public delegate void ClickEventHandler(object sender, EventArgs e);
public delegate void UserCreatedEventHandler(User user);

//  Good: Function-based names for callbacks
public delegate bool ValidationFunction(string value);
public delegate string TransformFunction(string input);

//  Good: Predicate/Func naming conventions
public delegate bool UserFilter(User user);
```

---

## Member Naming

### Methods

Use verb-based names in PascalCase describing what the method does.

```csharp
//  Good: Verb-based method names
public void SendEmail() { }
public void ProcessOrder() { }
public void ValidateInput(string input) { }
public User GetUser(int id) { }
public void RemoveExpiredTokens() { }

//  Good: Boolean-returning methods with "Is", "Has", "Can" prefixes
public bool IsActive() { }
public bool HasPermission(string permission) { }
public bool CanDelete() { }
public bool Contains(User user) { }

//  Good: Async methods with Async suffix (see async-patterns.md)
public async Task<User> GetUserAsync(int id) { }
public async Task SendEmailAsync(string recipient) { }

//  Avoid: Vague method names
public void Do() { }          // Do what?
public void Handle() { }      // Handle what?
public void Process() { }     // Process what?

//  Avoid: Hungarian notation
public void DoGetUser() { }   // Should be GetUser
public void GetUserAndProcess() { }  // Split into separate methods

//  Avoid: Methods named as properties
public void Name() { }        // Should be a property
public void Age() { }         // Should be a property
```

### Properties

Use noun-based names in PascalCase describing what data is exposed.

```csharp
public class User
{
    //  Good: Descriptive property names
    public string Name { get; set; }
    public string Email { get; set; }
    public DateTime CreatedDate { get; set; }
    public bool IsActive { get; set; }
    public List<Order> Orders { get; set; }
    
    //  Good: Boolean properties with descriptive names
    public bool IsVerified { get; set; }
    public bool HasActiveSubscription { get; set; }
    public bool CanDelete { get; set; }
    
    //  Good: Computed properties
    public string FullName => $"{FirstName} {LastName}";
    public int OrderCount => Orders?.Count ?? 0;
}

//  Avoid: Verb-based property names (use methods instead)
public class BadUser
{
    public string GetName { get; }      // Should be Name property
    public bool VerifyEmail() { }       // Should be IsEmailVerified property
}

//  Avoid: Redundant prefixes
public class Configuration
{
    public int ConfigTimeout { get; }  // Should be Timeout
    public string ConfigServer { get; }  // Should be Server
}
```

---

## Field Naming

### Private Fields

Use **camelCase** with **underscore prefix** for private instance fields.

```csharp
public class UserService
{
    //  Good: Private field with underscore prefix
    private string _internalCache;
    private readonly IUserRepository _repository;
    private List<User> _activeUsers;
    
    public void ProcessUsers()
    {
        var users = _activeUsers;  // Clearly private, distinct from parameters
    }
}

//  Avoid: No prefix for private fields (hard to distinguish from local variables)
public class BadService
{
    private string internalCache;  // Ambiguous - could be local variable
}

//  Avoid: camelCase without underscore
public class AnotherBadService
{
    private string cache;  // No clear indication it's private
}
```

### Backing Fields with Properties

Use underscore prefix consistently with corresponding properties.

```csharp
public class Account
{
    private string _email;
    
    //  Good: Clear relationship between field and property
    public string Email
    {
        get => _email;
        set => _email = value ?? string.Empty;
    }
    
    //  Good: Auto-properties eliminate need for explicit backing field
    public string Name { get; set; } = string.Empty;
}

//  Avoid: Inconsistent naming between field and property
public class BadAccount
{
    private string email;
    public string Email { get; set; }  // Hard to see the relationship
}
```

### Static Fields

Use **PascalCase** for static fields (preferred) or **camelCase with underscore prefix** if private.

```csharp
public class Constants
{
    //  Good: Public static field (rare, but PascalCase)
    public static readonly string DefaultCulture = "en-US";
    
    //  Good: Private static field with underscore
    private static readonly int _maxRetries = 3;
}
```

### Local Variables

Use **camelCase** for local variables.

```csharp
public void ProcessUsers(IEnumerable<User> users)
{
    //  Good: camelCase for local variables
    var activeUsers = users.Where(u => u.IsActive).ToList();
    int count = activeUsers.Count;
    string logMessage = "Processing users";
    var serviceInstance = new UserService();
    
    foreach (var user in activeUsers)
    {
        //  Good: camelCase for loop variables
        var profile = user.Profile;
        ProcessProfile(profile);
    }
}
```

### Method Parameters

Use **camelCase** for method parameters.

```csharp
public class UserRepository
{
    //  Good: camelCase parameters
    public void AddUser(User user) { }
    
    public User? GetUser(int userId, string userEmail) { }
    
    public void UpdateUserProfile(int userId, UserProfile profile, bool notifyUser) { }
    
    public async Task<IEnumerable<User>> SearchAsync(string query, int pageSize, int pageNumber)
    {
        // Parameters remain camelCase throughout method
    }
}

//  Avoid: PascalCase for parameters
public void AddUser(User User) { }  // Parameter should be user
```

---

## Generic Type Parameters

Use descriptive single-letter names for generic parameters. Follow these conventions:

```csharp
//  Good: Single letter for simple generics
public class Repository<T> where T : IEntity { }
public interface IFactory<T> { }

//  Good: Descriptive names for multiple type parameters
public class Dictionary<TKey, TValue> { }
public interface IRepository<TEntity, TIdentifier> { }
public class Cache<TInput, TOutput> { }

//  Good: Common generic type parameters
public class Result<T> { }              // Generic result
public class Repository<T> { }          // Generic entity type
public class Handler<TRequest, TResponse> { }  // CQRS pattern

//  Good: Constraint names use T prefix
public interface IComparable<T> where T : IComparable<T> { }
public class Container<TItem> where TItem : IContainable { }

//  Avoid: Unclear single letters for complex scenarios
public class Complex<K, V, U> { }  // Should use TKey, TValue, TUnknown

//  Avoid: Lowercase for type parameters
public class Repository<t> { }     // Should be Repository<T>
```

Common generic parameter names:

| Name | Usage |
|------|-------|
| `T` | Generic entity or item type |
| `TKey` | Dictionary key |
| `TValue` | Dictionary value or property value |
| `TEntity` | ORM entity type |
| `TRequest` | Request type (CQRS, API) |
| `TResponse` | Response type (CQRS, API) |
| `TResult` | Operation result type |
| `TException` | Exception type |
| `TService` | Service dependency |

---

## Async Method Naming

Always add **Async** suffix to methods returning `Task` or `Task<T>`.

```csharp
public class UserService
{
    //  Good: Async suffix for async methods
    public async Task<User?> GetUserAsync(int userId) { }
    
    public async Task SendWelcomeEmailAsync(User user) { }
    
    public async Task<IEnumerable<User>> GetActiveUsersAsync(CancellationToken cancellationToken = default) { }
    
    //  Good: Synchronous version without Async suffix
    public User? GetUser(int userId) { }  // Blocking version
    
    //  Good: Both sync and async versions available
    public void ValidateUser(User user) { }
    public async Task ValidateUserAsync(User user) { }
}

//  Avoid: No Async suffix for Task-returning methods
public Task<User> GetUser(int id) { }  // Should be GetUserAsync

//  Avoid: Redundant naming
public async Task GetUserAsyncTask(int userId) { }  // Should be GetUserAsync

//  Exception: Event handlers can be async void
public event Func<EventArgs, Task>? UserCreated;
private async void OnUserCreated(EventArgs e)  // Acceptable for event handlers
{
    await _notificationService.NotifyAsync();
}
```

---

## Enum Members

Enum member names use **PascalCase** without redundant prefixes.

```csharp
//  Good: Clear enum member names
public enum OrderStatus
{
    Pending,
    Confirmed,
    Processing,
    Shipped,
    Delivered,
    Cancelled,
    Failed
}

//  Good: Flag enum members
[Flags]
public enum UserPermissions
{
    None = 0,
    Read = 1,
    Write = 2,
    Delete = 4,
    Admin = Read | Write | Delete
}

//  Good: Combining related values
[Flags]
public enum FileMode
{
    Read = 1,
    Write = 2,
    Execute = 4,
    ReadWrite = Read | Write
}

//  Avoid: Prefixing enum member with enum name
public enum Color
{
    ColorRed,        // Should be Red
    ColorGreen,      // Should be Green
    ColorBlue        // Should be Blue
}

//  Avoid: Inconsistent casing
public enum Status
{
    active,          // Should be Active
    INACTIVE,        // Should be Inactive
    Pending
}
```

---

## Constants

Use **PascalCase** for public constants or **camelCase with underscore prefix** for private constants.

```csharp
public class EmailConfiguration
{
    //  Good: Public constant in PascalCase
    public const string DefaultFrom = "noreply@company.com";
    public const int MaxRetries = 3;
    public const int DefaultTimeout = 30;
    
    //  Good: Private constant with underscore
    private const string _encryptionAlgorithm = "AES256";
    private const int _minPasswordLength = 8;
}

public static class Constants
{
    //  Good: Static readonly for complex constants
    public static readonly TimeSpan DefaultTimeout = TimeSpan.FromSeconds(30);
    public static readonly string[] AllowedExtensions = { ".txt", ".pdf", ".doc" };
}

//  Avoid: ALL_CAPS for constants (outdated C# style)
public const string ALL_CAPS_CONSTANT = "value";  // Should be AllCapConstant

//  Avoid: Unclear abbreviations
public const int MaxRtry = 3;  // Should be MaxRetries
```

---

## Best Practices & Avoiding Pitfalls

### 1. Clarity Over Brevity

```csharp
//  Good: Clear, self-documenting names
public class OrderProcessingService
{
    public async Task ProcessOrdersWithinSLAAsync(CancellationToken cancellationToken) { }
}

//  Avoid: Abbreviated, unclear names
public class OPS
{
    public async Task ProcOrds(CancellationToken ct) { }
}
```

### 2. Consistency Across Codebase

```csharp
//  Good: Consistent naming throughout
public class UserService
{
    private readonly IUserRepository _userRepository;
    private readonly ILogger<UserService> _logger;
    
    public async Task<User?> GetUserAsync(int userId) { }
    public async Task<IEnumerable<User>> GetActiveUsersAsync() { }
    public async Task CreateUserAsync(CreateUserRequest request) { }
}

//  Avoid: Inconsistent naming patterns
public class UserService
{
    private readonly IUserRepository repo;  // Abbreviated
    private readonly ILogger<UserService> log;  // Abbreviated
    
    public async Task<User?> GetUser(int userId) { }  // Missing Async
    public async Task<IEnumerable<User>> FetchActiveUsers() { }  // Different verb
    public async Task NewUser(CreateUserRequest request) { }  // Different pattern
}
```

### 3. Avoiding Ambiguity

```csharp
//  Good: Clear, distinct names
public class Employee
{
    public int EmployeeId { get; set; }  // Primary key
    public string FirstName { get; set; }
    public string LastName { get; set; }
    public int ManagerId { get; set; }  // Foreign key reference
    public DateTime HireDate { get; set; }
}

//  Avoid: Similar or ambiguous names
public class Employee
{
    public int Id { get; set; }
    public int EmpId { get; set; }  // Ambiguous - which is the real ID?
    public string Name { get; set; }
    public int Manager { get; set; }  // Is this ID or the manager object?
}
```

### 4. Meaningful Names from Domain

```csharp
//  Good: Domain-specific, meaningful names
public class PurchaseOrder
{
    public string PoNumber { get; set; }  // Industry standard
    public decimal TotalAmount { get; set; }
    public OrderLineItem[] LineItems { get; set; }
}

//  Avoid: Generic, meaningless names
public class Data
{
    public string Item1 { get; set; }
    public decimal Item2 { get; set; }
    public object[] Items { get; set; }
}
```

### 5. Using Namespaces Properly

```csharp
//  Good: Logical namespace organization
namespace Company.Products.Services
{
    public class ProductService { }
}

namespace Company.Products.Models
{
    public class Product { }
}

namespace Company.Products.Repositories
{
    public class ProductRepository { }
}

//  Avoid: Flat or unclear namespace structure
namespace Services
{
    public class ProductService { }
    public class UserService { }
    public class OrderService { }
}
```

### 6. Reserved Words

Avoid using C# reserved keywords. Use @ prefix only when absolutely necessary.

```csharp
//  Good: Use alternatives to reserved words
public class Permission
{
    public string PermissionName { get; set; }  // Instead of "class"
    public bool IsAllowed { get; set; }  // Instead of "is"
}

//  Acceptable: Use @ prefix when necessary (rare)
public class DataModel
{
    public string @class { get; set; }  // Only if interfacing with non-.NET systems
    public string @event { get; set; }  // Only if interfacing with non-.NET systems
}
```

---

## Quick Reference Table

| Identifier Type | Casing | Example | Notes |
|---|---|---|---|
| **Classes** | PascalCase | `UserService` | Descriptive nouns |
| **Interfaces** | PascalCase + I | `IUserRepository` | I prefix, no suffix |
| **Records** | PascalCase | `UserResponse` | Like classes |
| **Enums** | PascalCase | `OrderStatus` | Enum name is singular/plural as needed |
| **Enum Members** | PascalCase | `Pending` | No prefix duplication |
| **Methods** | PascalCase | `GetUser` | Verb-based |
| **Properties** | PascalCase | `UserName` | Noun-based |
| **Public Fields** | PascalCase | (rare) | Use properties instead |
| **Private Fields** | _camelCase | `_cache` | Underscore prefix |
| **Local Variables** | camelCase | `activeUsers` | Loop/temp variables |
| **Parameters** | camelCase | `userId` | Method parameters |
| **Constants** | PascalCase | `DefaultTimeout` | Static readonly or const |
| **Generic Params** | PascalCase + T | `TEntity`, `TKey` | T prefix for type params |

---

## Summary

Follow Microsoft naming conventions for consistency across .NET ecosystem:

1. **PascalCase** for types, methods, properties, and public members
2. **camelCase** for local variables, parameters, and private fields with underscore prefix
3. **Descriptive names** over abbreviations
4. **Async suffix** for Task-returning methods
5. **Domain-appropriate terminology** for clarity

These conventions ensure your code is readable, maintainable, and consistent with the broader C# community standards.
