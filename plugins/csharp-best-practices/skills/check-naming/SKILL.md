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
