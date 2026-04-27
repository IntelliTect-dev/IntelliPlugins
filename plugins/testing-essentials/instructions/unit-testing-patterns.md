# Unit Testing Patterns

Advanced patterns and strategies for comprehensive test coverage in enterprise C# applications.

## Table of Contents

1. [Common Test Patterns](#common-test-patterns)
2. [Happy Path Testing](#happy-path-testing)
3. [Error Condition Testing](#error-condition-testing)
4. [Boundary and Edge Case Testing](#boundary-and-edge-case-testing)
5. [Null and Empty Input Testing](#null-and-empty-input-testing)
6. [Mocking Strategies](#mocking-strategies)
7. [Test Doubles: Fake, Stub, and Mock](#test-doubles-fake-stub-and-mock)
8. [Setting Up Test Infrastructure](#setting-up-test-infrastructure)
9. [Data-Driven Tests](#data-driven-tests)
10. [Parameterized Tests](#parameterized-tests)

## Common Test Patterns

### Pattern: Arrange-Act-Assert

The foundation of all unit tests:

```csharp
[Fact]
public void Example_Pattern_Demonstrated()
{
    // Arrange - set up the test scenario
    var service = new MyService();
    var input = new MyInput { Value = 100 };
    
    // Act - execute the behavior
    var result = service.ProcessInput(input);
    
    // Assert - verify the expected outcome
    Assert.NotNull(result);
    Assert.Equal(200, result.Value);
}
```

## Happy Path Testing

Happy path tests verify that the system behaves correctly under normal circumstances.

```csharp
public class OrderServiceTests
{
    [Fact]
    public void PlaceOrder_WithValidCustomerAndItems_SuccessfullyCreatesOrder()
    {
        // Arrange
        var customer = new Customer 
        { 
            Id = 1, 
            Name = "John Doe", 
            Email = "john@example.com" 
        };
        
        var items = new[]
        {
            new OrderItem { ProductId = 1, Quantity = 2, Price = 50m },
            new OrderItem { ProductId = 2, Quantity = 1, Price = 75m }
        };
        
        var mockRepository = new Mock<IOrderRepository>();
        var mockNotificationService = new Mock<INotificationService>();
        var orderService = new OrderService(mockRepository.Object, mockNotificationService.Object);
        
        // Act
        var order = orderService.PlaceOrder(customer, items);
        
        // Assert - verify successful creation
        Assert.NotNull(order);
        Assert.Equal(customer.Id, order.CustomerId);
        Assert.Equal(3, order.TotalItems);
        Assert.Equal(175m, order.Total);
        
        // Verify dependencies were called correctly
        mockRepository.Verify(x => x.Save(order), Times.Once);
        mockNotificationService.Verify(
            x => x.SendOrderConfirmation(It.Is<Order>(o => o.Id == order.Id)),
            Times.Once);
    }

    [Fact]
    public void RetrieveOrder_WithValidOrderId_ReturnsOrderDetails()
    {
        // Arrange
        var orderId = 123;
        var expectedOrder = new Order 
        { 
            Id = orderId, 
            CustomerId = 1, 
            Total = 250m,
            Status = OrderStatus.Confirmed
        };
        
        var mockRepository = new Mock<IOrderRepository>();
        mockRepository.Setup(x => x.GetById(orderId)).Returns(expectedOrder);
        
        var orderService = new OrderService(mockRepository.Object, new Mock<INotificationService>().Object);
        
        // Act
        var result = orderService.GetOrder(orderId);
        
        // Assert
        Assert.NotNull(result);
        Assert.Equal(orderId, result.Id);
        Assert.Equal(OrderStatus.Confirmed, result.Status);
    }
}
```

## Error Condition Testing

Test how the system handles failures and exceptional situations.

```csharp
public class PaymentProcessorTests
{
    [Fact]
    public void ProcessPayment_WhenInsufficientFunds_ThrowsInsufficientFundsException()
    {
        // Arrange
        var mockBankService = new Mock<IBankService>();
        mockBankService
            .Setup(x => x.Charge(It.IsAny<string>(), It.IsAny<decimal>()))
            .Throws<InsufficientFundsException>();
        
        var processor = new PaymentProcessor(mockBankService.Object);
        var payment = new Payment { Amount = 1000m, CardToken = "token123" };
        
        // Act & Assert
        Assert.Throws<InsufficientFundsException>(() => processor.ProcessPayment(payment));
    }

    [Fact]
    public void ProcessPayment_WhenPaymentGatewayUnresponsive_RetriesAndThrows()
    {
        // Arrange
        var mockBankService = new Mock<IBankService>();
        var callCount = 0;
        
        mockBankService
            .Setup(x => x.Charge(It.IsAny<string>(), It.IsAny<decimal>()))
            .Callback(() => callCount++)
            .Throws<TimeoutException>();
        
        var processor = new PaymentProcessor(mockBankService.Object);
        var payment = new Payment { Amount = 100m, CardToken = "token123" };
        
        // Act & Assert
        Assert.Throws<PaymentFailedException>(() => processor.ProcessPayment(payment));
        
        // Verify retry logic (e.g., 3 attempts)
        mockBankService.Verify(x => x.Charge(It.IsAny<string>(), It.IsAny<decimal>()), Times.Exactly(3));
    }

    [Fact]
    public void ProcessPayment_WhenCardInvalid_ReturnsDeclineResult()
    {
        // Arrange
        var mockBankService = new Mock<IBankService>();
        mockBankService
            .Setup(x => x.Charge(It.IsAny<string>(), It.IsAny<decimal>()))
            .Returns(new ChargeResult { Success = false, Reason = "Invalid card" });
        
        var processor = new PaymentProcessor(mockBankService.Object);
        var payment = new Payment { Amount = 100m, CardToken = "invalid" };
        
        // Act
        var result = processor.ProcessPayment(payment);
        
        // Assert
        Assert.False(result.Success);
        Assert.Equal("Invalid card", result.Reason);
    }

    [Fact]
    public void ProcessPayment_OnFailure_LogsErrorForAudit()
    {
        // Arrange
        var mockBankService = new Mock<IBankService>();
        var mockLogger = new Mock<ILogger>();
        
        mockBankService
            .Setup(x => x.Charge(It.IsAny<string>(), It.IsAny<decimal>()))
            .Throws<ServiceException>();
        
        var processor = new PaymentProcessor(mockBankService.Object);
        processor.Logger = mockLogger.Object;
        
        var payment = new Payment { Amount = 100m, CardToken = "token123" };
        
        // Act
        try
        {
            processor.ProcessPayment(payment);
        }
        catch (ServiceException)
        {
            // Expected
        }
        
        // Assert - verify error was logged for audit trail
        mockLogger.Verify(
            x => x.LogError(It.Is<string>(msg => msg.Contains("Payment failed"))),
            Times.Once);
    }
}
```

## Boundary and Edge Case Testing

Test values at boundaries and extreme conditions.

```csharp
public class DiscountCalculatorTests
{
    [Theory]
    [InlineData(0, 0.00)]
    [InlineData(1, 0.00)]
    [InlineData(99.99, 0.00)]
    [InlineData(100.00, 5.00)] // Boundary: minimum for 5% discount
    [InlineData(500.00, 25.00)]
    [InlineData(1000.00, 100.00)]
    [InlineData(999999.99, 99999.99)]
    [InlineData(decimal.MaxValue - 1, decimal.MaxValue - 1)] // Large value
    public void CalculateDiscount_WithVariousPricePoints_ReturnsCorrectDiscount(
        decimal price, 
        decimal expectedDiscount)
    {
        // Arrange
        var calculator = new DiscountCalculator();
        
        // Act
        var discount = calculator.Calculate(price);
        
        // Assert
        Assert.Equal(expectedDiscount, discount);
    }

    [Theory]
    [InlineData(0, 0)] // Boundary: minimum
    [InlineData(1, 1)]
    [InlineData(int.MaxValue - 1, int.MaxValue - 1)]
    [InlineData(int.MaxValue, int.MaxValue)] // Boundary: maximum
    public void ComputeFactorial_WithBoundaryValues_ReturnsCorrectResult(int input, int expected)
    {
        var calculator = new FactorialCalculator();
        var result = calculator.Compute(input);
        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("", 0)]
    [InlineData("1", 1)]
    [InlineData("10", 10)]
    [InlineData("999", 999)]
    [InlineData(int.MaxValue.ToString(), int.MaxValue)]
    public void ParseInteger_WithBoundaryStrings_ReturnsCorrectValue(string input, int expected)
    {
        var parser = new IntegerParser();
        var result = parser.Parse(input);
        Assert.Equal(expected, result);
    }
}
```

## Null and Empty Input Testing

Test robustness when handling null, empty, or undefined inputs.

```csharp
public class UserValidationTests
{
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public void ValidateEmail_WithNullOrEmptyInput_ReturnsFalse(string email)
    {
        // Arrange
        var validator = new EmailValidator();
        
        // Act
        var result = validator.IsValid(email);
        
        // Assert
        Assert.False(result);
    }

    [Theory]
    [InlineData(null)]
    [InlineData(new int[0])]
    public void CalculateAverage_WithNullOrEmptyArray_ThrowsArgumentException(int[] numbers)
    {
        // Arrange
        var calculator = new AverageCalculator();
        
        // Act & Assert
        Assert.Throws<ArgumentException>(() => calculator.Calculate(numbers));
    }

    [Fact]
    public void FindUser_WithNullRepository_ThrowsArgumentNullException()
    {
        // Arrange
        var service = new UserService(null); // Pass null dependency
        
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => service.FindUser(1));
    }

    [Fact]
    public void ProcessOrder_WithNullOrder_ThrowsArgumentNullException()
    {
        // Arrange
        var mockRepository = new Mock<IOrderRepository>();
        var service = new OrderService(mockRepository.Object);
        
        // Act & Assert
        Assert.Throws<ArgumentNullException>(() => service.ProcessOrder(null));
    }

    [Fact]
    public void CreateUser_WithNullName_ThrowsValidationException()
    {
        // Arrange
        var service = new UserService();
        var user = new User { Email = "user@example.com", Name = null };
        
        // Act & Assert
        Assert.Throws<ValidationException>(() => service.Create(user));
    }

    [Theory]
    [InlineData(new int[0])] // Empty array
    [InlineData(new[] { 0 })] // Single zero
    public void FindMaximum_WithEmptyOrZeroArray_ReturnsZeroOrThrows(int[] numbers)
    {
        // Arrange
        var finder = new MaximumFinder();
        
        // Act & Assert - verify graceful handling
        if (numbers.Length == 0)
        {
            Assert.Throws<InvalidOperationException>(() => finder.Find(numbers));
        }
        else
        {
            var result = finder.Find(numbers);
            Assert.Equal(0, result);
        }
    }
}
```

## Mocking Strategies

### When to Mock

Mock when you need to:
- Isolate external dependencies (databases, APIs, file systems)
- Verify interactions (what was called)
- Control behavior (set up return values)
- Make tests fast and reliable

```csharp
[Fact]
public void SendEmail_OnOrderConfirmed_CallsEmailService()
{
    // Arrange
    var mockEmailService = new Mock<IEmailService>();
    var orderService = new OrderService(mockEmailService.Object);
    var order = new Order { Id = 1, CustomerEmail = "user@example.com" };
    
    // Act
    orderService.ConfirmOrder(order);
    
    // Assert
    mockEmailService.Verify(
        x => x.Send(It.Is<Email>(e => e.To == "user@example.com")),
        Times.Once);
}
```

### Mock Setup Patterns

```csharp
// Setup with return value
mockService.Setup(x => x.GetUser(1)).Returns(new User { Id = 1, Name = "John" });

// Setup with callback
mockService.Setup(x => x.LogEvent(It.IsAny<string>()))
    .Callback<string>(msg => Console.WriteLine(msg));

// Setup with exception
mockService.Setup(x => x.Charge(It.IsAny<decimal>()))
    .Throws<PaymentFailedException>();

// Setup with multiple calls returning different values
mockService
    .SetupSequence(x => x.GetNextItem())
    .Returns("first")
    .Returns("second")
    .Throws<InvalidOperationException>();

// Setup with conditional logic
mockService.Setup(x => x.ValidateUser(It.Is<User>(u => u.Id == 123)))
    .Returns(true);
```

### Verification Patterns

```csharp
// Verify called exactly once
mockService.Verify(x => x.DoSomething(), Times.Once);

// Verify never called
mockService.Verify(x => x.Delete(It.IsAny<int>()), Times.Never);

// Verify called specific number of times
mockService.Verify(x => x.Log(It.IsAny<string>()), Times.Exactly(3));

// Verify called with specific arguments
mockService.Verify(
    x => x.Save(It.Is<User>(u => u.Id == 123 && u.Active)),
    Times.Once);

// Verify any method matching a condition
mockService.Verify(x => x.It.IsAny<int>(), Times.AtLeast(2));
```

## Test Doubles: Fake, Stub, and Mock

Understanding the differences helps you choose the right testing tool.

### Fake: A Working Implementation

A fake is a working implementation suitable for testing, but not production use.

```csharp
// Fake implementation of IUserRepository for testing
public class FakeUserRepository : IUserRepository
{
    private readonly List<User> _users = new();

    public User GetById(int id)
    {
        return _users.FirstOrDefault(u => u.Id == id);
    }

    public void Add(User user)
    {
        _users.Add(user);
    }

    public void Remove(int id)
    {
        var user = _users.FirstOrDefault(u => u.Id == id);
        if (user != null)
            _users.Remove(user);
    }
}

// Usage in tests
[Fact]
public void FindUser_WithFakeRepository_ReturnsUserWhenExists()
{
    // Arrange
    var fakeRepo = new FakeUserRepository();
    fakeRepo.Add(new User { Id = 1, Name = "John" });
    var service = new UserService(fakeRepo);
    
    // Act
    var user = service.GetUser(1);
    
    // Assert
    Assert.NotNull(user);
    Assert.Equal("John", user.Name);
}
```

### Stub: Predetermined Responses

A stub provides predetermined responses to method calls.

```csharp
[Fact]
public void GetUserAge_WithStub_ReturnsPresetValue()
{
    // Arrange
    var mockUserRepository = new Mock<IUserRepository>();
    mockUserRepository
        .Setup(x => x.GetById(1))
        .Returns(new User { Id = 1, Age = 30 }); // Stubbed response
    
    var service = new UserService(mockUserRepository.Object);
    
    // Act
    var age = service.GetUserAge(1);
    
    // Assert
    Assert.Equal(30, age);
}
```

### Mock: Verify Interactions

A mock verifies that methods were called as expected.

```csharp
[Fact]
public void PublishEvent_OnOrderCreated_CallsEventPublisher()
{
    // Arrange
    var mockEventPublisher = new Mock<IEventPublisher>();
    var orderService = new OrderService(mockEventPublisher.Object);
    var order = new Order { Id = 1 };
    
    // Act
    orderService.CreateOrder(order);
    
    // Assert - verify the mock was called correctly
    mockEventPublisher.Verify(
        x => x.Publish(It.Is<OrderCreatedEvent>(e => e.OrderId == 1)),
        Times.Once);
}
```

## Setting Up Test Infrastructure

### Creating Test Base Classes

```csharp
public abstract class ServiceTestBase
{
    protected Mock<ILogger> MockLogger { get; set; }
    protected Mock<IRepository> MockRepository { get; set; }

    public ServiceTestBase()
    {
        MockLogger = new Mock<ILogger>();
        MockRepository = new Mock<IRepository>();
    }

    protected void VerifyErrorLogged(string errorMessage)
    {
        MockLogger.Verify(
            x => x.LogError(It.Is<string>(msg => msg.Contains(errorMessage))),
            Times.Once);
    }
}

public class UserServiceTests : ServiceTestBase
{
    [Fact]
    public void GetUser_WithException_LogsError()
    {
        MockRepository.Setup(x => x.GetById(It.IsAny<int>())).Throws<Exception>();
        var service = new UserService(MockRepository.Object, MockLogger.Object);
        
        Assert.Throws<Exception>(() => service.GetUser(1));
        
        VerifyErrorLogged("Failed to retrieve user");
    }
}
```

### Using Builder Pattern for Test Data

```csharp
public class UserBuilder
{
    private int _id = 1;
    private string _name = "Test User";
    private string _email = "test@example.com";
    private bool _active = true;

    public UserBuilder WithId(int id)
    {
        _id = id;
        return this;
    }

    public UserBuilder WithName(string name)
    {
        _name = name;
        return this;
    }

    public UserBuilder Inactive()
    {
        _active = false;
        return this;
    }

    public User Build()
    {
        return new User
        {
            Id = _id,
            Name = _name,
            Email = _email,
            Active = _active
        };
    }
}

// Usage
[Fact]
public void GetActiveUsers_ReturnsOnlyActiveUsers()
{
    var activeUser = new UserBuilder().Build();
    var inactiveUser = new UserBuilder().WithId(2).Inactive().Build();
    
    var service = new UserService();
    var result = service.GetActiveUsers(new[] { activeUser, inactiveUser });
    
    Assert.Single(result);
    Assert.Equal(activeUser.Id, result.First().Id);
}
```

## Data-Driven Tests

Use data-driven tests to verify behavior across multiple scenarios.

```csharp
public class CalculatorDataDrivenTests
{
    [Theory]
    [InlineData(2, 3, 5)]
    [InlineData(0, 0, 0)]
    [InlineData(-1, 1, 0)]
    [InlineData(100, 50, 150)]
    public void Add_WithVariousInputs_ReturnsCorrectSum(int a, int b, int expected)
    {
        var calculator = new Calculator();
        var result = calculator.Add(a, b);
        Assert.Equal(expected, result);
    }

    public static IEnumerable<object[]> GetDiscountScenarios()
    {
        yield return new object[] { 50m, 0m, "No discount" };
        yield return new object[] { 100m, 5m, "5% discount" };
        yield return new object[] { 500m, 50m, "10% discount" };
        yield return new object[] { 1000m, 150m, "15% discount" };
    }

    [Theory]
    [MemberData(nameof(GetDiscountScenarios))]
    public void CalculateDiscount_WithVariousPrices_AppliesCorrectDiscount(
        decimal price,
        decimal expectedDiscount,
        string scenario)
    {
        var calculator = new DiscountCalculator();
        var result = calculator.Calculate(price);
        
        Assert.Equal(expectedDiscount, result);
    }
}
```

## Parameterized Tests

Use parameterized tests to reduce duplication.

```csharp
public class EmailValidationTests
{
    [Theory]
    [InlineData("valid@example.com", true)]
    [InlineData("also.valid+tag@example.co.uk", true)]
    [InlineData("invalid.email@", false)]
    [InlineData("@invalid.com", false)]
    [InlineData("no-at-symbol.com", false)]
    [InlineData("", false)]
    [InlineData(null, false)]
    public void ValidateEmail_WithVariousFormats_ReturnsCorrectResult(string email, bool expected)
    {
        var validator = new EmailValidator();
        var result = validator.IsValid(email);
        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("password", true)] // Length >= 8
    [InlineData("short", false)]
    [InlineData("P@ssw0rd", true)] // Has upper, lower, number, special
    [InlineData("NoSpecialChar1", false)]
    [InlineData("nouppercase1!", false)]
    [InlineData("NOLOWERCASE1!", false)]
    public void ValidatePassword_WithVariousPatterns_EnforcesRules(string password, bool expected)
    {
        var validator = new PasswordValidator();
        var result = validator.IsStrong(password);
        Assert.Equal(expected, result);
    }
}
```

## Summary

Effective test patterns:

1. **Happy Path**: Verify normal operation
2. **Error Conditions**: Test failure scenarios
3. **Boundaries**: Test edge cases and limits
4. **Null/Empty**: Verify robustness
5. **Mocking**: Isolate external dependencies
6. **Data-Driven**: Reduce duplication with multiple scenarios
7. **Parameterized**: Flexible test variations

Use these patterns to build comprehensive, maintainable test suites that catch bugs early and document business requirements clearly.
