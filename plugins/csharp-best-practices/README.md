# C# Best Practices Plugin

Professional C#-specific language patterns, naming conventions, async patterns, and enterprise development practices for modern .NET applications.

## Overview

C# is a modern, enterprise-grade programming language that combines the power of C++ with the simplicity of Visual Basic. This plugin provides comprehensive guidance on writing idiomatic, maintainable, and efficient C# code aligned with industry standards and Microsoft best practices.

Whether you're building console applications, web services, desktop clients, or cloud-native systems, this plugin helps you leverage C# language features effectively and write code that scales with your team.

## What's Covered

### 1. **C# Language Patterns** (`csharp-patterns.md`)
- **Type Design & Organization** - Classes, records, interfaces, and enums
- **Naming Conventions** - Methods, properties, fields, and constants
- **Property Patterns** - Auto-properties, init-only properties, and property initialization
- **Null Handling** - Null coalescing operators, null-forgiving operators, and nullable reference types
- **Pattern Matching** - Type, relational, and logical patterns
- **LINQ Best Practices** - Query syntax vs method syntax, performance considerations
- **Collections & Iteration** - Choosing the right collection types and iteration patterns
- **Modern C# Features** - Records, tuples, init accessors, and required members

### 2. **Naming Conventions** (`naming-conventions.md`)
- **Type Naming** - PascalCase for classes, interfaces, records, and structs
- **Member Naming** - Methods, properties, fields, and constants
- **Field Naming** - Private field prefixes, camelCase patterns
- **Generic Type Parameters** - T, TKey, TValue conventions
- **Async Methods** - Naming patterns for Task-returning methods
- **Enum Members** - Value naming and flag combinations
- **Avoiding Ambiguity** - Clarity, consistency, and avoiding reserved words

### 3. **Async/Await Patterns** (`async-patterns.md`)
- **Async Fundamentals** - Tasks, synchronous contexts, and proper async patterns
- **ConfigureAwait** - Using ConfigureAwait(false) in libraries and UI applications
- **Cancellation Tokens** - Proper cancellation propagation and timeout handling
- **Exception Handling** - Catching and preserving stack traces in async code
- **Avoiding Pitfalls** - Async void dangers, blocking on async code
- **Parallel Execution** - Task.WhenAll, Task.WhenAny, and concurrent operations
- **Task Composition** - Combining multiple async operations effectively

## When to Use This Plugin

Use this plugin when you're:
- Starting a new C# project and need consistent patterns
- Reviewing code for alignment with industry best practices
- Training junior developers on C# idioms
- Migrating code to modern C# versions
- Building enterprise applications requiring scalability
- Working in teams with varying C# experience levels

## Installation

Install this plugin using the Copilot CLI:

```bash
copilot plugin install csharp-best-practices@IntelliPlugins
```

Or, if installing from a local directory:

```bash
copilot plugin install ./plugins/csharp-best-practices
```

After installation, the plugin's instruction files will be automatically applied when you work with C# code.

## Quick Examples

### Naming Convention
```csharp
//  Good: PascalCase for public members
public class UserService
{
    private string _internalCache;  //  Underscore prefix for private fields
    
    public string UserName { get; set; }  //  PascalCase for properties
    
    public async Task<User> GetUserAsync(int userId)  //  Async suffix
    {
        return await _repository.FindAsync(userId);
    }
}

//  Avoid: camelCase for public or inconsistent naming
public class userService  // Should be UserService
{
    public string userName { get; set; }  // Should be UserName
}
```

### Null Handling
```csharp
//  Good: Modern null coalescing
string? description = user?.Address?.Description ?? "No description";

//  Good: Null-forgiving operator when you're sure
var street = user!.Address!.Street;  // Use only when certain

//  Good: Null coalescing assignment
user.LastModified ??= DateTime.UtcNow;
```

### Async Patterns
```csharp
//  Good: Library method with ConfigureAwait(false)
public async Task<User> GetUserAsync(int id, CancellationToken cancellationToken = default)
{
    using var response = await _client.GetAsync($"/users/{id}", cancellationToken)
        .ConfigureAwait(false);
    var json = await response.Content.ReadAsStringAsync(cancellationToken)
        .ConfigureAwait(false);
    return JsonSerializer.Deserialize<User>(json)!;
}

//  Avoid: Blocking on async code
var user = GetUserAsync(1).Result;  // Deadlock risk

//  Avoid: async void except for events
public async void OnUserChanged()  // Only acceptable for event handlers
{
    await UpdateUIAsync();
}
```

### LINQ Patterns
```csharp
//  Good: Query syntax for complex queries
var activeUsers = from user in users
                  where user.IsActive && user.JoinDate < cutoffDate
                  orderby user.Name
                  select new { user.Id, user.Name };

//  Good: Method syntax for simple operations
var count = users.Where(u => u.IsActive).Count();

//  Good: Deferred execution when needed
IEnumerable<User> GetActiveUsers()
{
    return users.Where(u => u.IsActive);  // Deferred
}

//  Good: Materialization when needed
List<User> GetActiveUsersList()
{
    return users.Where(u => u.IsActive).ToList();  // Materialized
}
```

## Language & Technology Stack

- **Language:** C# 13+ (leveraging latest language features)
- **Platforms:** .NET 8+, .NET Framework (where applicable)
- **Focus Areas:** Enterprise patterns, async/await, modern language features
- **Code Standards:** Microsoft naming conventions, SOLID principles

## Resources & References

### Official Microsoft Documentation
- [C# Documentation](https://learn.microsoft.com/en-us/dotnet/csharp/)
- [.NET API Reference](https://learn.microsoft.com/en-us/dotnet/api/)
- [C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Async/Await Best Practices](https://learn.microsoft.com/en-us/archive/msdn-magazine/2013/march/async-await-best-practices-in-asynchronous-programming)
- [LINQ Documentation](https://learn.microsoft.com/en-us/dotnet/csharp/linq/)

### Industry Standards
- [C# Coding Standards](https://en.wikibooks.org/wiki/C_Sharp_Programming)
- [Framework Design Guidelines](https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/)
- [Effective C#](https://www.informit.com/store/effective-csharp-50-specific-ways-to-improve-your-9780135704653) by Bill Wagner

### Community Resources
- [FxCop Rules](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/)
- [StyleCop Analyzers](https://github.com/DotNetAnalyzers/StyleCopAnalyzers)
- [Roslyn Analyzers](https://github.com/dotnet/roslyn-analyzers)

## Related Plugins

- **General Best Practices** - Cross-language patterns and principles
- **SOLID Principles** - Design principles for maintainable code
- **Design Patterns** - Gang of Four and architectural patterns
- **.NET Enterprise** - Enterprise architecture for .NET applications
- **Security Best Practices** - Safe coding patterns and vulnerability prevention

## Contributing

This plugin is part of the IntelliPlugins ecosystem. For contributions, feature requests, or bug reports, visit the [IntelliPlugins repository](https://github.com/IntelliTect-dev/IntelliPlugins).

## License

MIT License - See LICENSE file for details

---

**Version:** 1.0.0  
**Publisher:** IntelliTect-dev  
**Last Updated:** 2024
