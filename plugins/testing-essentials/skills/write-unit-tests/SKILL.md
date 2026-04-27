---
name: write-unit-tests
description: Write xUnit unit tests for a C# class or method following Arrange-Act-Assert and enterprise testing patterns
---

# Write Unit Tests Skill

Generate comprehensive xUnit unit tests for a specified C# class or method, covering the happy path, error conditions, boundary values, and edge cases.

## When to Use

Invoke this skill when you:
- Need to add tests to an existing untested class or method
- Are practicing TDD and want to write tests before implementation
- Want comprehensive coverage before a refactor
- Are reviewing a PR and need to add missing test cases

## Required Information

Provide:
1. **Class and method to test** — e.g., `OrderService.PlaceOrder`
2. **What it does** — brief description of the behavior
3. **Key scenarios** — happy path, failure cases, edge cases you want covered

## Test File Structure

```csharp
using FluentAssertions;
using Moq;
using Xunit;

namespace MyApp.Tests.Services;

public class OrderServiceTests
{
    // Shared mocks/fixtures
    private readonly Mock<IOrderRepository> _repositoryMock = new();
    private readonly Mock<IEmailService> _emailMock = new();
    private OrderService CreateSut() =>
        new(_repositoryMock.Object, _emailMock.Object);

    [Fact]
    public async Task PlaceOrder_WithValidInput_CreatesOrderAndSendsConfirmation()
    {
        // Arrange
        var order = new Order { CustomerId = 1, Items = [new OrderItem { ProductId = 5, Qty = 2 }] };
        _repositoryMock.Setup(r => r.SaveAsync(It.IsAny<Order>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(order with { OrderId = 42 });
        var sut = CreateSut();

        // Act
        var result = await sut.PlaceOrderAsync(order);

        // Assert
        result.OrderId.Should().Be(42);
        _emailMock.Verify(e => e.SendConfirmationAsync(order.CustomerId, 42, It.IsAny<CancellationToken>()), Times.Once);
    }

    [Fact]
    public async Task PlaceOrder_WithEmptyItems_ThrowsValidationException()
    {
        // Arrange
        var order = new Order { CustomerId = 1, Items = [] };
        var sut = CreateSut();

        // Act
        var act = () => sut.PlaceOrderAsync(order);

        // Assert
        await act.Should().ThrowAsync<ValidationException>()
            .WithMessage("*at least one item*");
    }
}
```

## Test Categories to Cover

For each method, generate tests for:

| Category | Description |
|----------|-------------|
| **Happy path** | Valid input, expected output |
| **Null / empty input** | `null`, empty string, empty collection |
| **Boundary values** | Min/max values, limits |
| **Invalid state** | Precondition failures |
| **Exception handling** | What throws and what is caught |
| **Dependency interactions** | Verify mocks called correctly |

## Test Naming Convention

```
MethodName_WhenCondition_ExpectedOutcome
```

Examples:
- `PlaceOrder_WithValidInput_CreatesOrderAndSendsConfirmation`
- `GetUser_WhenUserNotFound_ReturnsNull`
- `ProcessPayment_WhenAmountExceedsLimit_ThrowsException`

## Mocking Guidelines

- Use `Moq` for interface mocks
- Prefer `Mock<T>.Setup(...).ReturnsAsync(...)` over `.Returns(Task.FromResult(...))`
- Verify interactions with `.Verify(...)` only when the call itself is the behavior under test
- Use `It.IsAny<T>()` for parameters you don't care about; use specific values when the value matters

## Assertions

- Use `FluentAssertions` (`.Should().Be(...)`, `.Should().Contain(...)`) for readable assertions
- One logical assertion per test — multiple `.Should()` calls on the same object are fine
- For exceptions: use `act.Should().ThrowAsync<T>()` instead of `Assert.ThrowsAsync`
