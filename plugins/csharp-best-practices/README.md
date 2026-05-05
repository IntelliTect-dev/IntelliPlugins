# C# Best Practices Plugin

Professional C#-specific language patterns, naming conventions, async patterns, and enterprise development practices for modern .NET applications.

## Overview

C# is a cross-platform, modern, enterprise-grade programming language. This plugin provides comprehensive guidance on writing idiomatic, maintainable, and efficient C# code aligned with industry standards and Microsoft best practices.

Whether you're building console applications, web services, desktop clients, or cloud-native systems, this plugin helps you leverage C# language features effectively and write code that scales with your team.

## What's Covered

### 1. **C# Language Patterns** (`csharp-patterns.md`)

- **Type Design & Organization** - Classes, records, interfaces, and enums
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

After installation, the plugin will be automatically applied when you work with C# code.

## Language & Technology Stack

- **Language:** C# 14 (leveraging latest language features)
- **Platforms:** .NET 10, .NET Framework (where applicable)
- **Focus Areas:** Enterprise patterns, async/await, modern language features
- **Code Standards:** Microsoft naming conventions, SOLID principles

## Resources & References

### Official Microsoft Documentation

- [C# Documentation](https://learn.microsoft.com/en-us/dotnet/csharp/)
- [.NET API Reference](https://learn.microsoft.com/en-us/dotnet/api/)
- [C# Coding Conventions](https://learn.microsoft.com/en-us/dotnet/csharp/fundamentals/coding-style/coding-conventions)
- [Async/Await Best Practices](https://learn.microsoft.com/en-us/archive/msdn-magazine/2013/march/async-await-best-practices-in-asynchronous-programming)
- [LINQ Documentation](https://learn.microsoft.com/en-us/dotnet/csharp/linq/)

### Community Resources

- [Essential C#](https://essentialcsharp.com/home)
- [Framework Design Guidelines](https://learn.microsoft.com/en-us/dotnet/standard/design-guidelines/)
- [Effective C#](https://www.informit.com/store/effective-csharp-50-specific-ways-to-improve-your-9780135704653) by Bill Wagner
- [FxCop Rules](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/)
- [StyleCop Analyzers](https://github.com/DotNetAnalyzers/StyleCopAnalyzers)
- [Roslyn Analyzers](https://github.com/dotnet/roslyn-analyzers)

## Related Plugins

- **General Best Practices** - Cross-language patterns and principles
- **SOLID Principles** - Design principles for maintainable code
- **Design Patterns** - Gang of Four and architectural patterns
- **.NET Enterprise** - Enterprise architecture for .NET applications
- **Security Best Practices** - Safe coding patterns and vulnerability prevention
