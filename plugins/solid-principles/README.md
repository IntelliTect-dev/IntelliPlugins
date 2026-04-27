# SOLID Principles & Architecture Plugin

Enterprise-grade guidance on SOLID principles, architecture patterns, and code quality for maintainable C# projects.

## Overview

This plugin provides comprehensive guidance on applying SOLID principles and architectural best practices to C# code. It ensures that your codebase is modular, testable, maintainable, and resilient to change — essential characteristics of enterprise software.

## Why SOLID Principles Matter

SOLID principles form the foundation of clean, professional code. They help you:

- **Write Maintainable Code**: Code is easier to understand and modify
- **Enable Testing**: Proper abstractions make unit testing straightforward
- **Reduce Bugs**: Clear responsibilities and contracts prevent mistakes
- **Support Growth**: New features can be added with minimal impact on existing code
- **Facilitate Teamwork**: Clear architecture allows teams to work independently

## What This Plugin Covers

### Core SOLID Principles

1. **Single Responsibility Principle (SRP)**: Each class has one reason to change
2. **Open/Closed Principle (OCP)**: Open for extension, closed for modification
3. **Liskov Substitution Principle (LSP)**: Subtypes are substitutable for base types
4. **Interface Segregation Principle (ISP)**: Clients depend only on what they use
5. **Dependency Inversion Principle (DIP)**: Depend on abstractions, not concretions

### Architecture & Design

- Layered architecture (Controller → Service → Repository)
- Dependency Injection patterns
- Service-oriented design
- Repository patterns

### Code Quality

- DRY (Don't Repeat Yourself)
- YAGNI (You Aren't Gonna Need It)
- Clear, intention-revealing naming
- Proper error handling
- Testing strategies

### Anti-Patterns

- Service Locator
- Static dependencies
- Magic strings/numbers
- God objects
- Untested code

## When to Use This Plugin

Use this plugin when:

- **Designing new services or features** — architect with SOLID from the start
- **Reviewing code** — ensure architectural compliance
- **Refactoring legacy code** — improve structure and testability
- **Onboarding new developers** — teach code quality standards
- **Addressing code smells** — identify and fix architectural violations

## Installation

### Install from IntelliPlugins

```bash
copilot plugin install solid-principles@IntelliPlugins
```

### Verify Installation

```bash
copilot plugin list
```

You should see `solid-principles` in the list of installed plugins.

## How Copilot Uses This Guidance

With this plugin installed, Copilot will:

- **Propose proper architectures** when you ask for new features: "I'll create a service layer with dependency injection..."
- **Suggest refactoring** when violations are detected: "This class has too many responsibilities. Let's split it into..."
- **Generate proper patterns** for common scenarios: service classes, repository interfaces, validation logic
- **Enforce testing standards** by generating comprehensive unit tests
- **Catch violations early** and recommend fixes before code is committed

### Example: Service Creation

**You ask:** "Create a UserRegistration service"

**Copilot responds:**
```
I'll create a UserService that follows SOLID principles:
- IUserRepository for data access (Dependency Inversion)
- IPasswordHasher for password handling (Single Responsibility)
- Constructor injection for dependencies
- Comprehensive unit tests with mocks
- Clear error handling with specific exceptions

Does this approach work for you?
```

### Example: Code Review

**You ask:** "Review this code for architectural issues"

**Copilot identifies:**
- God class with multiple responsibilities (SRP violation)
- Direct static dependencies (DIP violation)
- Missing validation (error handling)
- No tests (testing requirement)
- Magic strings (naming clarity)

**Copilot recommends:**
- Break into focused services
- Use dependency injection
- Add validation helper
- Write unit tests
- Use named constants

## Key Features

###  Do This

```csharp
// Single Responsibility - UserService handles only user logic
public class UserService
{
    private readonly IUserRepository _repository;
    
    public async Task RegisterAsync(User user)
    {
        // User registration logic only
    }
}

// Dependency Injection - abstract dependencies
public class OrderService
{
    private readonly IPaymentProcessor _paymentProcessor;
    
    public OrderService(IPaymentProcessor paymentProcessor)
    {
        _paymentProcessor = paymentProcessor;
    }
}

// Proper Testing
[TestClass]
public class UserServiceTests
{
    [TestMethod]
    public async Task RegisterAsync_WithValidInput_CreatesUser()
    {
        // Arrange, Act, Assert
    }
}
```

###  Avoid This

```csharp
// God class - violates SRP
public class UserManager
{
    public void CreateUser() { }
    public void SendEmail() { }
    public void ProcessPayment() { }
    public void LogActivity() { }
}

// Static dependencies - violates DIP
public class OrderService
{
    public void ProcessOrder(Order order)
    {
        DatabaseHelper.Save(order); // Can't test or change implementation
        EmailHelper.Send(order);
    }
}

// No tests - violates testing standards
public class UserService
{
    // Untested business logic
}
```

## Architecture Patterns

### Layered Architecture

```
┌─────────────────────────────┐
│    API Controllers          │ HTTP requests/responses
├─────────────────────────────┤
│    Service Layer            │ Business logic
├─────────────────────────────┤
│    Repository Layer         │ Data access
├─────────────────────────────┤
│    Database/External APIs   │ External resources
└─────────────────────────────┘
```

**Flow:**
1. Controller receives HTTP request
2. Controller calls Service with request data
3. Service contains business logic, calls Repository
4. Repository handles data access, returns entities
5. Service returns DTO to Controller
6. Controller returns HTTP response

### Dependency Injection

```csharp
// Startup - wire dependencies
public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddScoped<IUserRepository, SqlUserRepository>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IPasswordHasher, BcryptHasher>();
    }
}

// Usage - dependencies injected automatically
[ApiController]
public class UsersController
{
    private readonly IUserService _userService;
    
    public UsersController(IUserService userService)
    {
        _userService = userService; // Injected by container
    }
}
```

## Code Quality Standards

### Naming Conventions

- **Classes**: PascalCase, descriptive (`UserAuthenticationService`)
- **Methods**: PascalCase, action-oriented (`AuthenticateUserAsync`)
- **Variables**: camelCase, intention-revealing (`hashedPassword`)
- **Constants**: PascalCase, UPPER_SNAKE_CASE (`MaxPasswordAttempts`)
- **Interfaces**: PascalCase, prefix with `I` (`IUserRepository`)

### Error Handling

```csharp
// Always throw specific exceptions
if (userId <= 0)
    throw new ArgumentException("User ID must be positive.", nameof(userId));

if (user == null)
    throw new EntityNotFoundException($"User {userId} not found");

// Log and rethrow, never silently fail
try
{
    await _repository.SaveAsync(user);
}
catch (DbUpdateException ex)
{
    _logger.LogError(ex, "Failed to save user");
    throw new OperationFailedException("User save failed", ex);
}
```

### Testing

- **Arrange-Act-Assert structure**
- **One assertion per test** or related assertions
- **Meaningful test names** describing the scenario
- **Mock external dependencies**
- **Test edge cases**: null, empty, boundary values
- **No test interdependencies**

## Common Patterns

### Repository Pattern

```csharp
public interface IUserRepository
{
    Task<User> GetByIdAsync(int id);
    Task<IEnumerable<User>> GetAllAsync();
    Task<User> CreateAsync(User user);
    Task<User> UpdateAsync(User user);
    Task DeleteAsync(int id);
}

public class SqlUserRepository : IUserRepository
{
    private readonly DbContext _dbContext;
    
    public SqlUserRepository(DbContext dbContext)
    {
        _dbContext = dbContext;
    }
    
    public async Task<User> GetByIdAsync(int id)
    {
        var user = await _dbContext.Users.FindAsync(id);
        if (user == null)
            throw new EntityNotFoundException($"User {id} not found");
        return user;
    }
}
```

### Service Pattern

```csharp
public interface IUserService
{
    Task<UserDto> RegisterAsync(string email, string password);
    Task<UserDto> GetUserAsync(int id);
}

public class UserService : IUserService
{
    private readonly IUserRepository _repository;
    private readonly IPasswordHasher _passwordHasher;

    public UserService(IUserRepository repository, IPasswordHasher passwordHasher)
    {
        _repository = repository;
        _passwordHasher = passwordHasher;
    }

    public async Task<UserDto> RegisterAsync(string email, string password)
    {
        ValidateInput(email, password);
        
        var hashedPassword = _passwordHasher.Hash(password);
        var user = new User { Email = email, PasswordHash = hashedPassword };
        
        var created = await _repository.CreateAsync(user);
        return MapToDto(created);
    }
}
```

### Validation Pattern

```csharp
public static class UserValidator
{
    public static void ValidateEmail(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email is required.", nameof(email));
        if (!email.Contains("@"))
            throw new ArgumentException("Invalid email format.", nameof(email));
    }

    public static void ValidatePassword(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
            throw new ArgumentException("Password is required.", nameof(password));
        if (password.Length < 8)
            throw new ArgumentException("Password must be at least 8 characters.", nameof(password));
    }
}
```

## Anti-Patterns to Avoid

###  Service Locator
```csharp
// Don't do this - hard to test, hidden dependencies
var repository = ServiceLocator.GetService<IUserRepository>();
```

###  Use Dependency Injection Instead
```csharp
public class UserService
{
    private readonly IUserRepository _repository;
    
    public UserService(IUserRepository repository)
    {
        _repository = repository;
    }
}
```

###  Static Dependencies
```csharp
// Don't do this - couples to specific implementation
user.PasswordHash = PasswordUtility.Hash(password);
```

###  Inject Dependencies
```csharp
public class UserService
{
    private readonly IPasswordHasher _hasher;
    
    public UserService(IPasswordHasher hasher)
    {
        _hasher = hasher;
    }
}
```

###  God Classes
```csharp
// Don't do this - too many responsibilities
public class UserManager
{
    public void CreateUser() { }
    public void SendEmail() { }
    public void ProcessPayment() { }
    public void GenerateReport() { }
}
```

###  Focused Services
```csharp
public class UserService { /* User operations */ }
public class EmailService { /* Email operations */ }
public class PaymentService { /* Payment operations */ }
public class ReportService { /* Reporting */ }
```

## Checklist for Code Reviews

- [ ] Each class has a single, clear responsibility
- [ ] All external dependencies are injected (no `new` keyword for dependencies)
- [ ] Interfaces are used for abstractions
- [ ] No static utility methods for business logic
- [ ] No magic strings or numbers (use named constants)
- [ ] Meaningful exception types are thrown with descriptive messages
- [ ] No `try-catch` without logging or rethrowing
- [ ] Unit tests cover happy path, error cases, and edge cases
- [ ] Test names describe what they're testing
- [ ] Tests use mocks for external dependencies
- [ ] No code duplication (DRY principle)

## Troubleshooting

### Q: When should I use interfaces?
**A:** Use interfaces for all external dependencies and major abstractions. This enables dependency injection, testing, and flexibility to change implementations.

### Q: Is the repository pattern always necessary?
**A:** For simple CRUD operations with Entity Framework, repositories can add unnecessary abstraction. However, they're valuable when:
- You need to swap data sources (SQL to NoSQL)
- You have complex queries to encapsulate
- You want to mock data access in tests
- You have multiple repositories with shared patterns

### Q: How much error handling is enough?
**A:** Handle only errors you can meaningfully recover from. For others, let exceptions bubble up (with logging). Use meaningful exception types and messages.

### Q: Can I mix SOLID with code-first development?
**A:** Absolutely. SOLID principles are about structure and relationships, not methodology. Start simple, refactor to SOLID as complexity grows.

## Related Plugins

- **csharp-best-practices** — C# language-specific best practices
- **testing-essentials** — Comprehensive unit testing strategies
- **enterprise-bug-fixing** — Debug and fix complex issues
- **coalesce-accelerator** — Rapid entity/API development

## Resources

### Books
- *Clean Code* by Robert C. Martin
- *Clean Architecture* by Robert C. Martin
- *Dependency Injection in .NET* by Mark Seemann

### Online
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
- [Design Patterns in C#](https://www.dofactory.com/net/design-patterns)
- [Microsoft Dependency Injection](https://docs.microsoft.com/en-us/dotnet/core/extensions/dependency-injection)

## License

MIT License. See LICENSE file in the repository.

## Support

For issues, questions, or contributions:
- GitHub: [IntelliPlugins](https://github.com/IntelliTect-dev/IntelliPlugins)
- Issues: [GitHub Issues](https://github.com/IntelliTect-dev/IntelliPlugins/issues)

---

**Last Updated:** 2024
**Plugin Version:** 1.0.0
