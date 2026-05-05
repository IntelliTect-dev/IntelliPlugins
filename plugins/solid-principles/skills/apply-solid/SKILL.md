---
name: apply-solid
description: Enterprise-grade guidance on SOLID principles, architecture patterns, and code quality for maintainable C# projects.
---

# Apply SOLID Principles Skill

Apply SOLID architecture principles to C# codebases to improve maintainability, testability, and extensibility.

## When to Use

Invoke this skill when you:

- Need to review code for SOLID principle violations
- Are refactoring a class or module to improve separation of concerns
- Want to apply dependency inversion to decouple components
- Are designing new classes and want to follow SOLID from the start

# SOLID Principles & Architecture Guidance

## Overview

SOLID principles form the foundation of enterprise-grade, maintainable software. This guidance ensures that code is modular, testable, resilient to change, and adheres to industry best practices.

---

## Core SOLID Principles

### 1. Single Responsibility Principle (SRP)

**A class should have one, and only one, reason to change.**

A class should have a single, well-defined responsibility. This ensures that the class is focused, easier to understand, and simpler to maintain.

#### Good Example

```csharp
// UserService handles only user business logic
public class UserService
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;

    public UserService(IUserRepository userRepository, IPasswordHasher passwordHasher)
    {
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task<User> RegisterUserAsync(string email, string password)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email is required.", nameof(email));

        var hashedPassword = _passwordHasher.Hash(password);
        var user = new User { Email = email, PasswordHash = hashedPassword };

        return await _userRepository.CreateAsync(user);
    }
}

// EmailService handles only email responsibilities
public class EmailService
{
    private readonly IEmailProvider _emailProvider;

    public EmailService(IEmailProvider emailProvider)
    {
        _emailProvider = emailProvider;
    }

    public async Task SendWelcomeEmailAsync(string email, string userName)
    {
        var message = new EmailMessage
        {
            To = email,
            Subject = "Welcome!",
            Body = $"Hello {userName}, welcome to our platform!"
        };

        await _emailProvider.SendAsync(message);
    }
}
```

#### Bad Example

```csharp
// God class violates SRP - handles users, emails, AND data persistence
public class UserManager
{
    private SqlConnection _connection;

    public void RegisterUser(string email, string password)
    {
        // Validation logic
        // Hashing logic
        // Database operations
        // Email sending logic
        // Logging
        // Error handling
        // ... too much responsibility!
    }
}
```

#### Why It Matters

- **Maintainability**: Changes to one responsibility don't affect others
- **Testability**: Easier to test isolated units
- **Reusability**: Classes can be used in different contexts
- **Reduced Coupling**: Fewer dependencies between classes

---

### 2. Open/Closed Principle (OCP)

**Classes should be open for extension, closed for modification.**

Design classes so that new functionality can be added without changing existing code. Use abstraction and polymorphism.

#### Good Example

```csharp
// Abstraction allows extensions without modification
public interface IDiscountStrategy
{
    decimal CalculateDiscount(decimal amount);
}

public class NoDiscount : IDiscountStrategy
{
    public decimal CalculateDiscount(decimal amount) => 0;
}

public class PercentageDiscount : IDiscountStrategy
{
    private readonly decimal _percentage;

    public PercentageDiscount(decimal percentage)
    {
        if (percentage < 0 || percentage > 100)
            throw new ArgumentException("Percentage must be between 0 and 100.");
        _percentage = percentage;
    }

    public decimal CalculateDiscount(decimal amount) => amount * (_percentage / 100);
}

public class BulkDiscount : IDiscountStrategy
{
    private readonly int _minimumQuantity;
    private readonly decimal _discountAmount;

    public BulkDiscount(int minimumQuantity, decimal discountAmount)
    {
        _minimumQuantity = minimumQuantity;
        _discountAmount = discountAmount;
    }

    public decimal CalculateDiscount(decimal amount) => amount >= _minimumQuantity * 10 ? _discountAmount : 0;
}

// PricingEngine closed for modification, open for extension
public class PricingEngine
{
    private readonly IDiscountStrategy _discountStrategy;

    public PricingEngine(IDiscountStrategy discountStrategy)
    {
        _discountStrategy = discountStrategy ?? throw new ArgumentNullException(nameof(discountStrategy));
    }

    public decimal CalculateFinalPrice(decimal basePrice)
    {
        var discount = _discountStrategy.CalculateDiscount(basePrice);
        return basePrice - discount;
    }
}

// Usage: Add new discount types without modifying PricingEngine
var tieredDiscount = new TieredDiscount(...);
var pricingEngine = new PricingEngine(tieredDiscount);
```

#### Bad Example

```csharp
// Violates OCP - must modify for every new discount type
public class PricingEngine
{
    public decimal CalculateFinalPrice(decimal basePrice, string discountType)
    {
        if (discountType == "percentage")
        {
            return basePrice * 0.9m;
        }
        else if (discountType == "bulk")
        {
            return basePrice - 10;
        }
        else if (discountType == "tiered")
        {
            // More logic
        }
        // Adding new discount type requires modifying this class
        return basePrice;
    }
}
```

#### Why It Matters

- **Minimal Risk**: New features don't affect existing code
- **Scalability**: Easy to add new behaviors
- **Maintainability**: Existing code stays stable
- **Reduced Bugs**: Tested code doesn't change

---

### 3. Liskov Substitution Principle (LSP)

**Subtypes must be substitutable for their base types without breaking the application.**

If a class derives from a base class or implements an interface, it must fulfill the contract completely and not violate the expectations of the caller.

#### Good Example

```csharp
public abstract class Bird
{
    public abstract void Eat();
}

public class Sparrow : Bird
{
    public override void Eat() => Console.WriteLine("Sparrow eats seeds");
}

public class Parrot : Bird
{
    public override void Eat() => Console.WriteLine("Parrot eats nuts");
}

public class FlyingBird : Bird
{
    public virtual void Fly() => Console.WriteLine("Bird is flying");
}

public class Eagle : FlyingBird
{
    public override void Eat() => Console.WriteLine("Eagle eats fish");
    public override void Fly() => Console.WriteLine("Eagle is flying high");
}

// Penguin doesn't fly, so don't inherit from FlyingBird
public class Penguin : Bird
{
    public override void Eat() => Console.WriteLine("Penguin eats fish");
    public void Swim() => Console.WriteLine("Penguin is swimming");
}

// Client code works with any Bird substitute
public void FeedBird(Bird bird)
{
    bird.Eat();
}
```

#### Bad Example

```csharp
// Violates LSP - Penguin can't fly but inherits FlyingBird
public class FlyingBird : Bird
{
    public virtual void Fly() => Console.WriteLine("Flying");
}

public class Penguin : FlyingBird
{
    public override void Eat() => Console.WriteLine("Penguin eats fish");

    // Violates the contract - penguin can't fly!
    public override void Fly() => throw new NotImplementedException("Penguins cannot fly");
}

// This breaks the substitution principle
public void MakeBirdFly(FlyingBird bird)
{
    bird.Fly(); // Works for Eagle, crashes for Penguin
}
```

#### Why It Matters

- **Predictability**: Polymorphism works as expected
- **Robustness**: No runtime surprises with subtype behavior
- **Contract Integrity**: Interfaces and base classes represent reliable contracts
- **Testability**: Mock objects behave consistently

---

### 4. Interface Segregation Principle (ISP)

**Clients should not be forced to depend on interfaces they do not use.**

Create fine-grained, focused interfaces rather than bloated "fat" interfaces. Clients should only depend on the methods they actually need.

#### Good Example

```csharp
// Segregated interfaces - clients depend only on what they use
public interface IReader
{
    string Read();
}

public interface IWriter
{
    void Write(string content);
}

public interface ISeeker
{
    void Seek(int position);
}

public class FileStream : IReader, IWriter, ISeeker
{
    public string Read() => "file content";
    public void Write(string content) => Console.WriteLine("Writing to file");
    public void Seek(int position) => Console.WriteLine($"Seeking to {position}");
}

public class ConsoleStream : IReader, IWriter
{
    public string Read() => Console.ReadLine();
    public void Write(string content) => Console.WriteLine(content);
}

// Clients depend only on what they need
public class DataProcessor
{
    private readonly IReader _reader;

    public DataProcessor(IReader reader)
    {
        _reader = reader;
    }

    public void Process()
    {
        var data = _reader.Read();
        // Process data
    }
}
```

#### Bad Example

```csharp
// Fat interface forces unnecessary dependencies
public interface IStream
{
    string Read();
    void Write(string content);
    void Seek(int position);
    void Encrypt(byte[] key);
    void Compress();
}

public class ConsoleStream : IStream
{
    public string Read() => Console.ReadLine();
    public void Write(string content) => Console.WriteLine(content);

    // Must implement methods it doesn't use
    public void Seek(int position) => throw new NotImplementedException();
    public void Encrypt(byte[] key) => throw new NotImplementedException();
    public void Compress() => throw new NotImplementedException();
}

// Client forced to depend on IStream even if it only reads
public class DataProcessor
{
    private readonly IStream _stream; // Depends on unused methods
}
```

#### Why It Matters

- **Flexibility**: Classes aren't tied to unnecessary methods
- **Clarity**: Interfaces document specific contracts
- **Loose Coupling**: Fewer dependencies between classes
- **Testing**: Easier to mock focused interfaces

---

### 5. Dependency Inversion Principle (DIP)

**High-level modules should not depend on low-level modules. Both should depend on abstractions.**

Depend on abstractions (interfaces), not concrete implementations. This inverts the typical dependency flow and increases flexibility.

#### Good Example

```csharp
// Abstractions at the top
public interface IUserRepository
{
    Task<User> GetByIdAsync(int id);
    Task<User> CreateAsync(User user);
}

public interface IEmailService
{
    Task SendAsync(string to, string subject, string body);
}

// High-level UserService depends on abstractions
public class UserService
{
    private readonly IUserRepository _userRepository;
    private readonly IEmailService _emailService;

    public UserService(IUserRepository userRepository, IEmailService emailService)
    {
        _userRepository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
        _emailService = emailService ?? throw new ArgumentNullException(nameof(emailService));
    }

    public async Task RegisterUserAsync(User user)
    {
        var createdUser = await _userRepository.CreateAsync(user);
        await _emailService.SendAsync(user.Email, "Welcome", "Welcome to our platform!");
    }
}

// Low-level implementations depend on same abstractions
public class SqlUserRepository : IUserRepository
{
    private readonly IDbContext _dbContext;

    public SqlUserRepository(IDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<User> GetByIdAsync(int id) => await _dbContext.Users.FindAsync(id);
    public async Task<User> CreateAsync(User user)
    {
        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync();
        return user;
    }
}

public class SmtpEmailService : IEmailService
{
    private readonly ISmtpClient _smtpClient;

    public SmtpEmailService(ISmtpClient smtpClient)
    {
        _smtpClient = smtpClient;
    }

    public async Task SendAsync(string to, string subject, string body)
    {
        var message = new MailMessage { To = to, Subject = subject, Body = body };
        await _smtpClient.SendMailAsync(message);
    }
}

// Dependency injection wires everything
var userRepository = new SqlUserRepository(dbContext);
var emailService = new SmtpEmailService(smtpClient);
var userService = new UserService(userRepository, emailService);
```

#### Bad Example

```csharp
// High-level module depends directly on low-level implementations
public class UserService
{
    private readonly SqlUserRepository _userRepository = new();
    private readonly SmtpEmailService _emailService = new();

    public void RegisterUser(User user)
    {
        _userRepository.CreateUser(user); // Direct dependency on SQL implementation
        _emailService.SendEmail(user.Email); // Direct dependency on SMTP
    }
}

// Testing is impossible - can't mock or substitute implementations
// Changing the database or email provider requires modifying UserService
```

#### Why It Matters

- **Flexibility**: Easy to swap implementations (databases, email providers, etc.)
- **Testability**: Mock dependencies during testing
- **Maintainability**: Changes to implementations don't affect high-level logic
- **Scalability**: New implementations can be added without modifying existing code

---

## Architecture Patterns

### Layered Architecture

Organize code into logical layers: Controller → Service → Repository.

```csharp
// Controller layer - handles HTTP
[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpPost]
    public async Task<ActionResult<UserDto>> Register(RegisterRequest request)
    {
        var result = await _userService.RegisterAsync(request.Email, request.Password);
        return CreatedAtAction(nameof(GetById), new { id = result.Id }, result);
    }
}

// Service layer - business logic
public interface IUserService
{
    Task<UserDto> RegisterAsync(string email, string password);
}

public class UserService : IUserService
{
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;

    public async Task<UserDto> RegisterAsync(string email, string password)
    {
        // Validation, password hashing, business rules
        var hashedPassword = _passwordHasher.Hash(password);
        var user = new User { Email = email, PasswordHash = hashedPassword };
        var created = await _userRepository.CreateAsync(user);
        return MapToDto(created);
    }
}

// Repository layer - data access
public interface IUserRepository
{
    Task<User> CreateAsync(User user);
    Task<User> GetByIdAsync(int id);
}

public class UserRepository : IUserRepository
{
    private readonly DbContext _dbContext;

    public async Task<User> CreateAsync(User user)
    {
        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync();
        return user;
    }
}
```

### Dependency Injection Container

Use a DI container to manage object lifecycles and dependencies.

---

## Code Quality Guidelines

### DRY (Don't Repeat Yourself)

Extract duplicated code into reusable methods, classes, or services.

#### Good Example

```csharp
public class ValidationHelper
{
    public static void ValidateEmail(string email)
    {
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email is required.");
        if (!email.Contains("@"))
            throw new ArgumentException("Invalid email format.");
    }

    public static void ValidatePassword(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
            throw new ArgumentException("Password is required.");
        if (password.Length < 8)
            throw new ArgumentException("Password must be at least 8 characters.");
    }
}

public class UserService
{
    public async Task RegisterAsync(string email, string password)
    {
        ValidationHelper.ValidateEmail(email);
        ValidationHelper.ValidatePassword(password);
        // Register user
    }
}
```

#### Bad Example

```csharp
public class UserService
{
    public async Task RegisterAsync(string email, string password)
    {
        // Duplicated validation logic
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email is required.");
        if (!email.Contains("@"))
            throw new ArgumentException("Invalid email format.");
        if (string.IsNullOrWhiteSpace(password))
            throw new ArgumentException("Password is required.");
        if (password.Length < 8)
            throw new ArgumentException("Password must be at least 8 characters.");
    }
}

public class ProfileService
{
    public async Task UpdateProfileAsync(string email, string password)
    {
        // Same validation logic duplicated again
        if (string.IsNullOrWhiteSpace(email))
            throw new ArgumentException("Email is required.");
        if (!email.Contains("@"))
            throw new ArgumentException("Invalid email format.");
        // ...
    }
}
```

### YAGNI (You Aren't Gonna Need It)

Don't add features or complexity you don't need now. Keep code simple and focused on current requirements.

#### Good Example

```csharp
public class OrderService
{
    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        var items = request.Items;
        var total = items.Sum(i => i.Price * i.Quantity);

        var order = new Order { Items = items, Total = total };
        await _orderRepository.CreateAsync(order);

        return order;
    }
}
```

#### Bad Example

```csharp
public class OrderService
{
    // Over-engineered: adds strategy pattern, caching, multiple price calculations
    private readonly IPricingStrategy _pricingStrategy;
    private readonly ICacheService _cache;
    private readonly IShippingCalculator _shippingCalculator;
    private readonly ITaxCalculator _taxCalculator;
    private readonly IDiscountEngine _discountEngine;

    public async Task CreateOrderAsync(CreateOrderRequest request)
    {
        // Too complex for current needs
    }
}
```

### Correct Naming

Use clear, intention-revealing names that describe purpose and behavior.

#### Good Example

```csharp
public interface IUserPasswordValidator
{
    bool IsValid(string password);
}

public class UserAuthenticationService
{
    private readonly IUserRepository _userRepository;
    private readonly IUserPasswordValidator _passwordValidator;

    public async Task<AuthenticationResult> AuthenticateUserAsync(string email, string password)
    {
        var user = await _userRepository.GetByEmailAsync(email);
        if (user == null)
            return AuthenticationResult.Failure("User not found");

        if (!_passwordValidator.IsValid(password))
            return AuthenticationResult.Failure("Invalid password");

        return AuthenticationResult.Success(user);
    }
}
```

#### Bad Example

```csharp
public interface IValidator { bool Validate(string input); }

public class AuthService
{
    private readonly IRepository _repo;
    private readonly IValidator _validator;

    public async Task<Result> Auth(string u, string p)
    {
        var usr = await _repo.Get(u);
        if (usr == null) return Result.Fail();
        if (!_validator.Validate(p)) return Result.Fail();
        return Result.Ok(usr);
    }
}
```

---

## Error Handling Best Practices

### Use Meaningful Exceptions

Throw specific exceptions with descriptive messages.

#### Good Example

```csharp
public class UserService
{
    public async Task<User> GetUserByIdAsync(int userId)
    {
        if (userId <= 0)
            throw new ArgumentException("User ID must be greater than zero.", nameof(userId));

        var user = await _userRepository.GetByIdAsync(userId);

        if (user == null)
            throw new EntityNotFoundException($"User with ID {userId} not found.");

        return user;
    }
}

// Custom exception
public class EntityNotFoundException : Exception
{
    public EntityNotFoundException(string message) : base(message) { }
}
```

#### Bad Example

```csharp
public class UserService
{
    public async Task<User> GetUserByIdAsync(int userId)
    {
        try
        {
            var user = await _userRepository.GetByIdAsync(userId);
            return user; // Returns null without indication
        }
        catch (Exception ex)
        {
            throw new Exception("Error"); // Generic error message
        }
    }
}
```

### Avoid Swallowing Exceptions

Never catch an exception and silently ignore it without logging or rethrowing.

#### Good Example

```csharp
public async Task ProcessOrderAsync(Order order)
{
    try
    {
        await _orderRepository.CreateAsync(order);
    }
    catch (DbUpdateException ex)
    {
        _logger.LogError(ex, "Failed to persist order. Order ID: {OrderId}", order.Id);
        throw new OrderProcessingException("Failed to save order. Please try again.", ex);
    }
}
```

#### Bad Example

```csharp
public async Task ProcessOrderAsync(Order order)
{
    try
    {
        await _orderRepository.CreateAsync(order);
    }
    catch (Exception ex)
    {
        // Silent failure - no logging, no rethrow
    }
}
```

---

## Anti-Patterns to Avoid

### Service Locator Pattern

Avoid using a service locator; use dependency injection instead.

#### Bad

```csharp
public class UserService
{
    public void RegisterUser(User user)
    {
        var repository = ServiceLocator.GetService<IUserRepository>();
        repository.Create(user);
    }
}
```

#### Good

```csharp
public class UserService
{
    private readonly IUserRepository _repository;

    public UserService(IUserRepository repository)
    {
        _repository = repository;
    }

    public void RegisterUser(User user)
    {
        _repository.Create(user);
    }
}
```

### Static Dependencies

Avoid static utility classes for business logic; use dependency injection.

#### Bad

```csharp
public class UserService
{
    public void RegisterUser(User user)
    {
        // Hard to test, tightly coupled
        ValidationUtility.ValidateEmail(user.Email);
        user.PasswordHash = PasswordUtility.Hash(user.Password);
    }
}
```

#### Good

```csharp
public class UserService
{
    private readonly IEmailValidator _emailValidator;
    private readonly IPasswordHasher _passwordHasher;

    public void RegisterUser(User user)
    {
        _emailValidator.Validate(user.Email);
        user.PasswordHash = _passwordHasher.Hash(user.Password);
    }
}
```

### Magic Strings and Numbers

Avoid hardcoded values; use named constants or configuration.

#### Bad

```csharp
public class OrderService
{
    public decimal CalculateTax(decimal amount)
    {
        return amount * 0.08m; // What is 0.08? Tax rate? Why?
    }

    public void SendOrderConfirmation(Order order)
    {
        if (order.Status == "completed") // Magic string
        {
            _emailService.Send("orders@company.com", "Order confirmed");
        }
    }
}
```

#### Good

```csharp
public class OrderService
{
    private const decimal SalesTaxRate = 0.08m;
    private const string OrderConfirmationRecipient = "orders@company.com";

    public decimal CalculateTax(decimal amount)
    {
        return amount * SalesTaxRate;
    }

    public void SendOrderConfirmation(Order order)
    {
        if (order.Status == OrderStatus.Completed)
        {
            _emailService.Send(OrderConfirmationRecipient, "Order confirmed");
        }
    }
}
```

### God Objects

Avoid large classes with too many responsibilities.

#### Bad

```csharp
public class UserManager
{
    // Too many responsibilities!
    public void CreateUser() { }
    public void DeleteUser() { }
    public void SendEmail() { }
    public void LogActivity() { }
    public void ValidatePayment() { }
    public void ProcessRefund() { }
    public void GenerateReport() { }
}
```

#### Good

```csharp
public class UserService { /* User operations */ }
public class EmailService { /* Email operations */ }
public class AuditLogger { /* Logging */ }
public class PaymentProcessor { /* Payment operations */ }
public class ReportGenerator { /* Reporting */ }
```

---

## When to Push Back

If asked to implement something that violates these principles, propose the proper solution first and explain trade-offs:

1. **Architectural Violations**: "That approach violates SRP. Instead, let's create a separate service for that responsibility because..."
2. **Untested Code**: "Business logic should be unit tested. We should extract this into a service and add tests."
3. **Hardcoded Dependencies**: "This creates a static dependency. Let's use DI so we can test and swap implementations."
4. **Code Duplication**: "This logic is repeated in three places. Let's extract it to a shared utility/service."
5. **Magic Strings/Numbers**: "Let's use a named constant here so it's clear what this value represents."

Always explain the benefits: testability, maintainability, flexibility, and reduced risk.

---

## Be Explicit

Before implementing, explain your intended architecture:

"I'm planning to:

- Create a `{Name}Service` class for business logic
- Implement an `I{Name}Repository` interface for data access
- Use constructor injection for all dependencies
- Write unit tests with mocks for external dependencies
- Use constants for magic values

Does this approach work for you, or would you prefer a different architecture?"

---

## Summary

**SOLID principles are non-negotiable for enterprise code.** They ensure:

- Code is maintainable and easier to understand
- Changes are localized and don't break unrelated parts
- Testing is straightforward with proper abstractions
- New features can be added without modifying existing code
- Teams can work on different components independently

Follow these principles consistently across your codebase for long-term success.
