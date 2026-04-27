# Testing Best Practices

This guide covers the fundamental philosophy and patterns for writing sustainable unit tests in enterprise C# applications.

## Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Arrange-Act-Assert Structure](#arrange-act-assert-structure)
3. [Test Naming Conventions](#test-naming-conventions)
4. [Test Independence and Isolation](#test-independence-and-isolation)
5. [xUnit Fundamentals](#xunit-fundamentals)
6. [Assertion Strategies](#assertion-strategies)
7. [Common Pitfalls](#common-pitfalls)

## Testing Philosophy

### Tests Document Business Requirements

The primary purpose of a unit test is to **validate a business requirement**, not to achieve code coverage metrics. Tests should answer the question: "What should this code do from the user's perspective?"

```csharp
//  Good - validates a business requirement
// "A premium customer should receive a 20% discount"
[Fact]
public void CalculatePrice_ForPremiumCustomer_AppliesTwentyPercentDiscount()
{
    // Arrange
    var customer = new Customer { Type = CustomerType.Premium };
    var product = new Product { BasePrice = 100m };
    var calculator = new PricingEngine();
    
    // Act
    var finalPrice = calculator.CalculatePrice(product, customer);
    
    // Assert
    Assert.Equal(80m, finalPrice);
}

//  Poor - tests implementation detail, not business value
[Fact]
public void GetPremiumDiscount_ReturnsDecimal()
{
    var result = Pricing.GetPremiumDiscount();
    Assert.IsType<decimal>(result);
}
```

### Business-Focused Scenario Testing

Structure tests around business scenarios, not technical implementation:

```csharp
//  Business scenarios
[Fact]
public void PlaceOrder_WithInsufficientInventory_CancelsOrderAndNotifiesCustomer()
{
}

[Fact]
public void ApplyDiscount_WhenCouponExpired_RejectsDiscount()
{
}

[Fact]
public void ProcessRefund_WithinThirtyDays_RefundsFull()
{
}

//  Technical implementations
[Fact]
public void SetOrderStatus()
{
}

[Fact]
public void CallValidationMethod()
{
}
```

### Tests Should Be Independent

Each test must work in isolation:

- Tests can run in any order
- Tests don't share state or setup
- External dependencies are mocked
- Each test is self-documenting

```csharp
//  Good - independent tests
[Fact]
public void FirstTest_SetUpAllNeededData()
{
    var data = CreateTestData(); // Setup is local to this test
    // ...
}

[Fact]
public void SecondTest_SetUpAllNeededData()
{
    var data = CreateTestData(); // Doesn't depend on FirstTest
    // ...
}

//  Poor - tests depend on each other
private static List<Item> _sharedList = new();

[Fact]
public void FirstTest_PopulatesList()
{
    _sharedList.Add(new Item()); // Shared state
}

[Fact]
public void SecondTest_UsesList()
{
    Assert.True(_sharedList.Count > 0); // Depends on FirstTest running first
}
```

## Arrange-Act-Assert Structure

Every test follows this three-part pattern:

### Arrange: Set Up the Test

Prepare all necessary data and dependencies:

```csharp
[Fact]
public void TransferFunds_WithSufficientBalance_DeductsFromSourceAccount()
{
    // Arrange - set up the scenario
    var sourceAccount = new BankAccount { Balance = 1000m };
    var targetAccount = new BankAccount { Balance = 500m };
    var transferService = new TransferService();
    
    // Act
    transferService.Transfer(sourceAccount, targetAccount, 200m);
    
    // Assert
    Assert.Equal(800m, sourceAccount.Balance);
    Assert.Equal(700m, targetAccount.Balance);
}
```

### Act: Execute the Behavior

Call the method or action being tested. Keep this concise:

```csharp
// Arrange
var service = new OrderService();
var order = new Order { Items = new[] { new OrderItem { Quantity = 5 } } };

// Act - one clear action
var total = service.CalculateTotal(order);

// Assert
Assert.Equal(expectedTotal, total);
```

### Assert: Verify the Results

Check that the behavior produced the expected outcome:

```csharp
// Arrange
var validator = new EmailValidator();

// Act
var isValid = validator.Validate("user@example.com");

// Assert - verify the result
Assert.True(isValid);
```

## Test Naming Conventions

### Naming Pattern

Use the pattern: `[UnitOfWork]_[Scenario]_[ExpectedResult]`

```csharp
[MethodName]_[Condition]_[ExpectedOutcome]

// Examples:
[Fact]
public void CalculateDiscount_WithPremiumCustomer_ReturnsPercentageDiscount()
{
}

[Fact]
public void ValidateEmail_WithInvalidFormat_ReturnsFalse()
{
}

[Fact]
public void ProcessOrder_WhenOutOfStock_ThrowsInventoryException()
{
}

[Fact]
public void FindUser_WithNullId_ReturnsNull()
{
}
```

### Naming Guidelines

- **Be Descriptive**: The test name should explain what's being tested and what's expected
- **Avoid "Test" in the Name**: Don't call it `TestCalculateDiscount` or `DiscountTest`
- **Use Business Language**: Use terms from the domain (customers, orders, discounts)
- **Make It Readable**: A developer should understand the test without reading the code

```csharp
//  Clear and specific
[Fact]
public void CalculateShippingCost_WithInternationalAddress_AppliesInternationalRate()
{
}

//  Too vague
[Fact]
public void Test()
{
}

//  Uses implementation detail
[Fact]
public void CallCalculateMethod()
{
}

//  Hard to understand
[Fact]
public void Calc_Ship_Cost()
{
}
```

## Test Independence and Isolation

### No Shared Test State

Each test must be completely independent:

```csharp
//  Good - no shared state
public class CalculatorTests
{
    [Fact]
    public void Add_WithTwoNumbers_ReturnSum()
    {
        var calculator = new Calculator(); // Fresh instance
        var result = calculator.Add(2, 3);
        Assert.Equal(5, result);
    }

    [Fact]
    public void Subtract_WithTwoNumbers_ReturnDifference()
    {
        var calculator = new Calculator(); // Fresh instance
        var result = calculator.Subtract(5, 3);
        Assert.Equal(2, result);
    }
}

//  Poor - shared state
public class CalculatorTests
{
    private static Calculator _calculator = new(); // Shared!

    [Fact]
    public void Add_WithTwoNumbers_ReturnSum()
    {
        var result = _calculator.Add(2, 3); // Depends on state
        Assert.Equal(5, result);
    }

    [Fact]
    public void Subtract_WithTwoNumbers_ReturnDifference()
    {
        var result = _calculator.Subtract(5, 3); // State may be affected by Add test
        Assert.Equal(2, result);
    }
}
```

### Mock External Dependencies

Replace external dependencies with mocks to isolate the code under test:

```csharp
//  Good - mocked dependency, isolated test
[Fact]
public void SendOrderConfirmation_OnOrderCreated_SendsEmail()
{
    // Arrange
    var mockEmailService = new Mock<IEmailService>();
    var orderService = new OrderService(mockEmailService.Object);
    var order = new Order { CustomerEmail = "user@example.com" };
    
    // Act
    orderService.CreateOrder(order);
    
    // Assert
    mockEmailService.Verify(
        x => x.Send(It.Is<Email>(e => e.To == "user@example.com")),
        Times.Once);
}

//  Poor - depends on real email service
[Fact]
public void SendOrderConfirmation_OnOrderCreated_SendsEmail()
{
    var orderService = new OrderService(); // Uses real email service!
    var order = new Order { CustomerEmail = "user@example.com" };
    
    orderService.CreateOrder(order); // Sends real email in test!
    
    // How do we verify without checking actual mailbox?
}
```

### One Logical Assertion Per Test

Each test should verify one business behavior. You may have multiple physical assertions, but they should all relate to one logical outcome:

```csharp
//  Good - one logical assertion (all parts of same behavior)
[Fact]
public void CreateAccount_WithValidData_CreatesAccountAndSendsWelcomeEmail()
{
    var mockEmailService = new Mock<IEmailService>();
    var accountService = new AccountService(mockEmailService.Object);
    
    accountService.CreateAccount(new Account { Email = "user@example.com", Name = "John" });
    
    // Multiple related assertions about the same business behavior
    var account = accountService.GetAccount("user@example.com");
    Assert.NotNull(account);
    Assert.Equal("John", account.Name);
    
    mockEmailService.Verify(
        x => x.Send(It.Is<Email>(e => e.Subject == "Welcome")),
        Times.Once);
}

//  Poor - multiple unrelated assertions
[Fact]
public void CreateAccount_DoesMultipleThings()
{
    var accountService = new AccountService();
    accountService.CreateAccount(new Account { Email = "user@example.com" });
    
    // Unrelated assertions
    Assert.NotNull(accountService);
    var random = new Random();
    Assert.True(random.Next() > 0);
    Assert.False(string.IsNullOrEmpty("test"));
    // These don't test the behavior!
}
```

## xUnit Fundamentals

### [Fact] Attribute

Use `[Fact]` for single-scenario tests:

```csharp
[Fact]
public void Divide_WhenDivisorIsZero_ThrowsDivideByZeroException()
{
    var calculator = new Calculator();
    
    Assert.Throws<DivideByZeroException>(() => calculator.Divide(10, 0));
}
```

### [Theory] and [InlineData]

Use `[Theory]` to test multiple scenarios:

```csharp
[Theory]
[InlineData(0, 0, 0)]
[InlineData(1, 1, 2)]
[InlineData(5, 3, 8)]
[InlineData(-1, 1, 0)]
public void Add_WithVariousInputs_ReturnCorrectSum(int x, int y, int expected)
{
    var calculator = new Calculator();
    var result = calculator.Add(x, y);
    Assert.Equal(expected, result);
}
```

### [MemberData] for Complex Data

Use `[MemberData]` to provide complex test data:

```csharp
public static IEnumerable<object[]> GetOrderTestData()
{
    yield return new object[] { new Order { Items = new[] { new Item { Price = 100 } } }, 100 };
    yield return new object[] { new Order { Items = new[] { new Item { Price = 50 }, new Item { Price = 50 } } }, 100 };
}

[Theory]
[MemberData(nameof(GetOrderTestData))]
public void CalculateTotal_WithVariousOrders_ReturnCorrectTotal(Order order, decimal expectedTotal)
{
    var result = order.CalculateTotal();
    Assert.Equal(expectedTotal, result);
}
```

### Test Fixtures for Setup

Use constructors or IAsyncLifetime for test initialization:

```csharp
public class UserServiceTests
{
    private Mock<IUserRepository> _mockRepository;
    private UserService _userService;
    
    public UserServiceTests()
    {
        // This runs before each test
        _mockRepository = new Mock<IUserRepository>();
        _userService = new UserService(_mockRepository.Object);
    }
    
    [Fact]
    public void GetUser_WithValidId_ReturnsUser()
    {
        // Setup is already done from constructor
        _mockRepository.Setup(x => x.FindById(1)).Returns(new User { Id = 1 });
        
        var user = _userService.GetUser(1);
        
        Assert.NotNull(user);
    }
}
```

## Assertion Strategies

### Standard xUnit Assertions

```csharp
// Equality
Assert.Equal(expected, actual);
Assert.NotEqual(notExpected, actual);

// Null checking
Assert.Null(obj);
Assert.NotNull(obj);

// Boolean
Assert.True(condition);
Assert.False(condition);

// Collections
Assert.Contains(item, collection);
Assert.DoesNotContain(item, collection);
Assert.Empty(collection);
Assert.NotEmpty(collection);
Assert.Single(collection);

// Exceptions
Assert.Throws<InvalidOperationException>(() => method());
Assert.ThrowsAsync<InvalidOperationException>(async () => await asyncMethod());

// Type checking
Assert.IsType<string>(obj);
Assert.IsNotType<int>(obj);
```

### Using FluentAssertions for Readability

FluentAssertions provides chainable, readable assertions:

```csharp
using FluentAssertions;

[Fact]
public void GetUsers_ReturnsValidList()
{
    var users = userService.GetUsers();
    
    // More readable than xUnit's built-in assertions
    users.Should().NotBeEmpty();
    users.Should().HaveCount(3);
    users.Should().AllSatisfy(u => u.Name.Should().NotBeNullOrEmpty());
    users.First().Age.Should().BeGreaterThan(18);
}
```

### Verifying Mock Interactions

```csharp
var mockService = new Mock<IService>();

// Verify a method was called
mockService.Verify(x => x.DoSomething(), Times.Once);

// Verify with specific arguments
mockService.Verify(x => x.Save(It.Is<User>(u => u.Id == 123)), Times.Once);

// Verify it was NOT called
mockService.Verify(x => x.Delete(It.IsAny<int>()), Times.Never);

// Verify call count
mockService.Verify(x => x.Log(It.IsAny<string>()), Times.Exactly(3));
```

## Common Pitfalls

### 1. Testing Implementation Instead of Behavior

```csharp
//  Tests implementation detail
[Fact]
public void User_WhenConstructed_HasIdOfZero()
{
    var user = new User();
    Assert.Equal(0, user.Id);
}

//  Tests business behavior
[Fact]
public void CreateUser_WithValidData_PersistsAndReturnsId()
{
    var user = new User { Name = "John" };
    var id = userService.Create(user);
    
    Assert.True(id > 0);
}
```

### 2. Over-Mocking

```csharp
//  Mocks too much, test is brittle
[Fact]
public void Calculate_CallsHelperCorrectly()
{
    var mockHelper = new Mock<IHelper>();
    mockHelper.Setup(x => x.Validate(It.IsAny<int>())).Returns(true);
    mockHelper.Setup(x => x.Transform(It.IsAny<int>())).Returns(42);
    mockHelper.Setup(x => x.Log(It.IsAny<string>())).Returns(Task.CompletedTask);
    
    var calc = new Calculator(mockHelper.Object);
    var result = calc.Calculate(10);
    
    mockHelper.Verify(x => x.Validate(10), Times.Once);
    mockHelper.Verify(x => x.Transform(10), Times.Once);
    mockHelper.Verify(x => x.Log(It.IsAny<string>()), Times.Exactly(2));
    // 20+ lines of mock setup and verification
}

//  Mock only what's necessary
[Fact]
public void Calculate_WithValidInput_ReturnsResult()
{
    var mockLogger = new Mock<ILogger>(); // Only mock external dependency
    var calc = new Calculator(mockLogger.Object);
    
    var result = calc.Calculate(10);
    
    Assert.Equal(expectedValue, result);
}
```

### 3. Slow Tests

```csharp
//  Hits real database, test is slow
[Fact]
public void FindUser_WithId_ReturnsUser()
{
    using (var context = new ApplicationDbContext())
    {
        var user = context.Users.FirstOrDefault(u => u.Id == 1);
        Assert.NotNull(user);
    }
}

//  Uses in-memory fake or mock
[Fact]
public void FindUser_WithId_ReturnsUser()
{
    var fakeUsers = new List<User> { new User { Id = 1, Name = "John" } };
    var mockRepo = new Mock<IUserRepository>();
    mockRepo.Setup(x => x.FindById(1)).Returns(fakeUsers.FirstOrDefault(u => u.Id == 1));
    
    var service = new UserService(mockRepo.Object);
    var user = service.FindUser(1);
    
    Assert.NotNull(user);
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

//  Clear, meaningful values
[Fact]
public void Calculate_WithStandardInput_ReturnsExpectedResult()
{
    const decimal hourlyRate = 50m;
    const int hoursWorked = 40;
    const decimal expectedTotal = 2000m;
    
    var calculator = new PayrollCalculator();
    var total = calculator.CalculatePay(hourlyRate, hoursWorked);
    
    Assert.Equal(expectedTotal, total);
}
```

### 5. Testing Unrelated Things

```csharp
//  Test mixed concerns
[Fact]
public void ProcessOrder()
{
    var order = new Order { Id = 1 };
    
    // Testing multiple unrelated things
    Assert.NotNull(order);
    Assert.True(order.Id > 0);
    var random = new Random();
    Assert.True(random.Next() > -1);
    var now = DateTime.Now;
    Assert.True(now.Year >= 2000);
}

//  Test one business behavior
[Fact]
public void ProcessOrder_WithValidData_RecordsOrderInSystem()
{
    var order = new Order { Id = 1, CustomerId = 123 };
    var mockRepository = new Mock<IOrderRepository>();
    var service = new OrderService(mockRepository.Object);
    
    service.ProcessOrder(order);
    
    mockRepository.Verify(x => x.Save(order), Times.Once);
}
```

## Summary

Effective unit tests:

1. **Validate business requirements** - not just code coverage
2. **Follow Arrange-Act-Assert** - clear structure
3. **Have descriptive names** - explain the scenario
4. **Are independent** - can run in any order
5. **Mock external dependencies** - isolate the behavior
6. **Avoid common pitfalls** - over-mocking, slow tests, unclear setup

Write tests that future developers will thank you for maintaining.
