# Testing Essentials

Comprehensive testing best practices including unit testing strategies, test naming conventions, and mock frameworks.

## Overview

Testing is a cornerstone of enterprise software development. This plugin provides guidance on building a sustainable testing culture, from unit test organization to advanced mocking strategies. Whether you're starting a new project or improving an existing test suite, Testing Essentials helps you write tests that catch bugs early and document business requirements clearly.

## Why Testing Matters

In enterprise development, testing is not just a quality gate—it's a business enabler:

- **Risk Reduction**: Comprehensive tests catch regressions before they reach production
- **Requirements Documentation**: Well-written tests serve as executable specifications of business requirements
- **Design Validation**: Writing tests first (TDD) naturally leads to more modular, testable code
- **Maintenance Confidence**: Refactoring becomes safe when backed by a robust test suite
- **Cost Efficiency**: Bugs caught in testing are orders of magnitude cheaper to fix than those in production

## Core Principles

### Business-First Testing

Tests should validate **business requirements**, not just code coverage metrics:

```csharp
//  Good - describes business requirement
[Fact]
public void OrderCancellation_WithinThirtyDays_RefundsFull()
{
    // Arrange
    var order = CreateOrderFromThirtyDaysAgo();
    var refundService = new RefundService();

    // Act
    var refund = refundService.CalculateRefund(order);

    // Assert
    Assert.Equal(order.Total, refund.Amount);
}

//  Poor - tests implementation detail, not business value
[Fact]
public void SetOrderStatusToCancelled()
{
    var order = new Order();
    order.Cancel();
    Assert.Equal(OrderStatus.Cancelled, order.Status);
}
```

### Arrange-Act-Assert Pattern

Every test follows a clear, three-part structure:

1. **Arrange**: Set up test data and dependencies
2. **Act**: Execute the behavior under test
3. **Assert**: Verify the results

This pattern makes tests easy to understand and maintain.

## Test Naming Conventions

Clear test names are critical for test suite maintainability:

```csharp
// Pattern: [MethodUnderTest]_[Condition]_[ExpectedResult]

[Fact]
public void CalculateDiscount_WithPremiumCustomer_ReturnsPercentageDiscount()
{
    // When a premium customer calculates a discount, they get a percentage applied
}

[Fact]
public void ParseDate_WithInvalidFormat_ThrowsFormatException()
{
    // When parsing fails, the method throws
}

[Fact]
public void FindUser_WithNullId_ReturnsNull()
{
    // Edge case: null inputs are handled gracefully
}
```

## Test Independence and Isolation

Each test must be independent:

- **No shared state** between tests
- **No test ordering dependencies** (tests should pass in any order)
- **Mock external dependencies** (databases, APIs, file systems)
- **One logical assertion per test** (can have multiple physical asserts on the same object)

```csharp
//  Good - isolated test with mocked dependency
[Fact]
public void SendNotification_OnOrderConfirmed_CallsEmailService()
{
    // Arrange
    var mockEmailService = new Mock<IEmailService>();
    var notificationHandler = new OrderNotificationHandler(mockEmailService.Object);
    var order = new Order { CustomerId = 123 };

    // Act
    notificationHandler.OnOrderConfirmed(order);

    // Assert - verify the mock was called correctly
    mockEmailService.Verify(
        x => x.Send(It.Is<Email>(e => e.CustomerId == 123)),
        Times.Once);
}

//  Poor - depends on database, not isolated
[Fact]
public void SendNotification_OnOrderConfirmed_RecordsInDatabase()
{
    var realDb = new SqlDatabase("production-connection");
    var order = realDb.Orders.First();
    // ... test continues, depending on database state
}
```

## Mocking and Dependencies

Distinguish between different types of test doubles:

- **Mock**: Verifies interactions and behavior (what was called)
- **Stub**: Provides predetermined responses (what it returns)
- **Fake**: Working implementation suitable for testing (in-memory database)

```csharp
// Mock - verify interactions
var mockLogger = new Mock<ILogger>();
handler.DoSomething();
mockLogger.Verify(x => x.Log(It.IsAny<string>()), Times.Once);

// Stub - return fake data
var stubRepository = new Mock<IUserRepository>();
stubRepository.Setup(x => x.GetUser(123)).Returns(new User { Id = 123 });

// Fake - working implementation
var fakeDatabase = new InMemoryDatabase();
fakeDatabase.AddUser(new User { Id = 123 });
```

## Edge Cases and Boundaries

Test not just the happy path, but also:

- **Null/empty inputs**: Does the method handle null parameters?
- **Boundary values**: First item, last item, zero, maximum values?
- **Error conditions**: What happens when dependencies fail?
- **Concurrency**: Are there race conditions?

```csharp
[Theory]
[InlineData(null)]
[InlineData("")]
[InlineData("   ")]
public void ValidateEmail_WithEmptyInput_ReturnsFalse(string email)
{
    Assert.False(EmailValidator.IsValid(email));
}

[Theory]
[InlineData(0)]
[InlineData(1)]
[InlineData(int.MaxValue)]
public void CalculateBonus_WithVariousSalaries_ReturnsCorrectAmount(int salary)
{
    var bonus = BonusCalculator.Calculate(salary);
    Assert.True(bonus >= 0);
}
```

## Testing Frameworks

The enterprise standard is **xUnit.v3**, paired with **Moq** for mocking:

```csharp
using Xunit;
using Moq;

public class OrderServiceTests
{
    [Fact]
    public void PlaceOrder_WithValidData_SavesOrder()
    {
        // xUnit uses [Fact] and [Theory] attributes
        // Moq provides fluent mocking syntax
    }
}
```

**Other common frameworks:**

- **NUnit**: Similar to xUnit.v3, still widely used
- **TUnit**: Similar to xUnit.v3, very fast
- **NSubstitute**: Alternative to Moq, elegant syntax
- **FluentAssertions**: Chainable assertions for readability

## Common Pitfalls

### 1. Testing Implementation, Not Behavior

```csharp
//  Tests implementation detail
[Fact]
public void List_WhenCreated_HasCountOfZero()
{
    var list = new List<int>();
    Assert.Equal(0, list.Count);
}
```

### 2. Over-Mocking

```csharp
//  Mocks too much, brittle test
[Fact]
public void Calculate_CallsHelper()
{
    var mockHelper = new Mock<IHelper>();
    var calculator = new Calculator(mockHelper.Object);
    calculator.Add(2, 3);
    // 20 lines verifying every call to mockHelper...
}
```

### 3. Slow Tests

```csharp
//  Tests hit real database, slow and unreliable
[Fact]
public void FindUser_WithId_ReturnsUser()
{
    using (var context = new RealDatabaseContext())
    {
        var user = context.Users.First();
        // ...
    }
}
```

### 4. Unclear Test Setup

```csharp
//  Magic values, unclear intent
[Fact]
public void Calculate_Returns42()
{
    var result = Calculator.Process(7, 6);
    Assert.Equal(42, result);
}
```

## Installation

Install the Testing Essentials plugin:

```bash
copilot plugin install testing-essentials@IntelliPlugins
```

Once installed, reference these guides when:

- Setting up a new test project
- Writing unit tests for business logic
- Designing test data and fixtures
- Implementing mocking strategies
- Reviewing test quality

## Example Test Scenario

Here's a complete, professional test example:

```csharp
public class PaymentProcessorTests
{
    private Mock<IPaymentGateway> _mockGateway;
    private Mock<ILogger> _mockLogger;
    private PaymentProcessor _processor;

    public PaymentProcessorTests()
    {
        _mockGateway = new Mock<IPaymentGateway>();
        _mockLogger = new Mock<ILogger>();
        _processor = new PaymentProcessor(_mockGateway.Object, _mockLogger.Object);
    }

    [Fact]
    public void ProcessPayment_WithValidCard_ChargesCustomerSuccessfully()
    {
        // Arrange
        var payment = new Payment
        {
            Amount = 99.99m,
            CardToken = "valid-token-123",
            CustomerId = 456
        };

        _mockGateway
            .Setup(x => x.Charge(It.IsAny<string>(), It.IsAny<decimal>()))
            .Returns(new ChargeResult { Success = true, TransactionId = "txn-789" });

        // Act
        var result = _processor.ProcessPayment(payment);

        // Assert
        Assert.True(result.IsSuccessful);
        Assert.Equal("txn-789", result.TransactionId);

        _mockGateway.Verify(
            x => x.Charge("valid-token-123", 99.99m),
            Times.Once);

        _mockLogger.Verify(
            x => x.Log(It.Is<string>(m => m.Contains("Payment processed"))),
            Times.Once);
    }

    [Fact]
    public void ProcessPayment_WithDeclinedCard_ReturnsFailure()
    {
        // Arrange
        var payment = new Payment { CardToken = "declined-token" };

        _mockGateway
            .Setup(x => x.Charge(It.IsAny<string>(), It.IsAny<decimal>()))
            .Returns(new ChargeResult { Success = false, Error = "Card declined" });

        // Act
        var result = _processor.ProcessPayment(payment);

        // Assert
        Assert.False(result.IsSuccessful);
        Assert.Contains("declined", result.Error, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void ProcessPayment_WhenGatewayUnavailable_LogsErrorAndThrows()
    {
        // Arrange
        var payment = new Payment { CardToken = "any-token" };

        _mockGateway
            .Setup(x => x.Charge(It.IsAny<string>(), It.IsAny<decimal>()))
            .Throws<ServiceUnavailableException>();

        // Act & Assert
        Assert.Throws<ServiceUnavailableException>(() => _processor.ProcessPayment(payment));

        _mockLogger.Verify(
            x => x.LogError(It.IsAny<Exception>()),
            Times.Once);
    }
}
```

## Related Plugins

- **SOLID Principles & Architecture**: Design principles that make code testable
- **C# Best Practices**: Language patterns that support test-driven development
- **Enterprise Bug Fixing Workflow**: Structured bug resolution with test-first approach

## Additional Resources

For detailed testing patterns, strategies, and advanced mocking techniques, see:

- `instructions/testing-best-practices.md` — Testing philosophy and core patterns
- `instructions/unit-testing-patterns.md` — Advanced patterns, data-driven tests, and infrastructure
