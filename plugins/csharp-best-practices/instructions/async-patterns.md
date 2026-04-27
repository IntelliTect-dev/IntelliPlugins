# C# Async/Await Best Practices

Comprehensive guide to asynchronous programming in C# using async/await, Tasks, and cancellation patterns.

## Table of Contents
1. [Async Fundamentals](#async-fundamentals)
2. [ConfigureAwait](#configureawait)
3. [Cancellation Tokens](#cancellation-tokens)
4. [Exception Handling](#exception-handling)
5. [Avoiding Common Pitfalls](#avoiding-common-pitfalls)
6. [Parallel Execution](#parallel-execution)
7. [Task Composition](#task-composition)
8. [Performance Considerations](#performance-considerations)

---

## Async Fundamentals

### Understanding async/await

The `async/await` keywords make asynchronous code readable by allowing you to write it almost like synchronous code.

```csharp
//  Good: Basic async/await pattern
public async Task<User> GetUserAsync(int userId)
{
    var user = await _repository.GetUserAsync(userId);
    return user;
}

//  Good: Async method returning Task (fire-and-forget with await)
public async Task SendEmailAsync(string recipient, string subject, string body)
{
    var message = new EmailMessage { To = recipient, Subject = subject, Body = body };
    await _emailService.SendAsync(message);
}

//  Good: Async method returning Task<T>
public async Task<bool> ValidateEmailAsync(string email)
{
    var result = await _emailService.CheckAsync(email);
    return result.IsValid;
}
```

### Task vs Task<T>

- **Task** - For async methods that don't return a value
- **Task<T>** - For async methods that return a value of type T

```csharp
//  Good: Task for void-like async operations
public async Task ProcessOrderAsync(Order order)
{
    await _repository.UpdateOrderAsync(order);
    await _notificationService.NotifyAsync(order.CustomerId);
    // No return value needed
}

//  Good: Task<T> for operations returning values
public async Task<decimal> CalculateTotalAsync(IEnumerable<OrderItem> items)
{
    var prices = await Task.WhenAll(items.Select(i => GetPriceAsync(i.ProductId)));
    return prices.Sum();
}
```

### Naming Convention: Async Suffix

Always add **Async** suffix to methods returning Task or Task<T>.

```csharp
//  Good: Async methods with Async suffix
public async Task<User?> GetUserAsync(int userId) { }
public async Task SendEmailAsync(string recipient) { }
public async Task<string> ReadFileAsync(string path) { }

//  Good: Synchronous version without suffix
public User? GetUser(int userId) { }  // Blocking

//  Avoid: Missing Async suffix
public async Task<User> GetUser(int userId) { }  // Confusing - looks sync

//  Avoid: Async suffix on non-async methods
public Task<User> GetUserAsync(int userId)  // Should use async/await
{
    return _repository.GetUserAsync(userId);
}
```

### Async vs Sync Methods

Provide both when beneficial, but prefer async versions for I/O operations.

```csharp
//  Good: Both sync and async versions
public class DataService
{
    public User? GetUser(int userId)  // Synchronous (blocking)
    {
        return _repository.GetUser(userId);
    }
    
    public async Task<User?> GetUserAsync(int userId)  // Asynchronous (non-blocking)
    {
        return await _repository.GetUserAsync(userId);
    }
}

//  Good: Async-only for modern applications
public class ModernDataService
{
    public async Task<User?> GetUserAsync(int userId)
    {
        return await _repository.GetUserAsync(userId);
    }
}

//  Avoid: Blocking on async (see Avoiding Common Pitfalls)
```

---

## ConfigureAwait

### Library Code vs Application Code

Use **ConfigureAwait(false)** in library code to avoid UI context capture.

```csharp
//  Good: Library code with ConfigureAwait(false)
public class UserRepository : IUserRepository
{
    public async Task<User?> GetUserAsync(int userId)
    {
        using var response = await _httpClient.GetAsync($"/users/{userId}")
            .ConfigureAwait(false);
        
        var json = await response.Content.ReadAsStringAsync()
            .ConfigureAwait(false);
        
        return JsonSerializer.Deserialize<User>(json);
    }
}

//  Good: UI application code (can use ConfigureAwait(true) or omit)
public partial class UserPage : Page
{
    private async void OnLoad()
    {
        // ConfigureAwait behavior depends on UI framework expectations
        var users = await _userService.GetUsersAsync();
        RefreshUI(users);
    }
}

//  Avoid: Forgetting ConfigureAwait(false) in libraries
public async Task<Data> FetchDataAsync()
{
    var response = await _httpClient.GetAsync(url);  // Can deadlock in UI contexts
    var content = await response.Content.ReadAsStringAsync();  // Capturing UI context
}
```

### When ConfigureAwait(true) vs (false)

```csharp
// ConfigureAwait(false) - Return to default thread pool (recommended for libraries)
public async Task<int> ComputeAsync()
{
    var data = await FetchDataAsync().ConfigureAwait(false);
    var result = await ProcessAsync(data).ConfigureAwait(false);
    return result;
}

// ConfigureAwait(true) or omitted - Preserve context (for UI frameworks)
// Only use if you need to return to specific context (UI thread, custom context)
```

### Chain ConfigureAwait Throughout

Once you use ConfigureAwait(false), continue through the chain.

```csharp
//  Good: Consistent ConfigureAwait(false) throughout
public async Task<List<User>> GetActiveUsersAsync()
{
    var users = await _repository.GetAllUsersAsync()
        .ConfigureAwait(false);
    
    var activeUsers = users
        .Where(u => u.IsActive)
        .ToList();
    
    foreach (var user in activeUsers)
    {
        user.LastAccessed = await GetLastAccessTimeAsync(user.Id)
            .ConfigureAwait(false);
    }
    
    return activeUsers;
}

//  Avoid: Inconsistent ConfigureAwait usage
public async Task<List<User>> GetActiveUsersAsync()
{
    var users = await _repository.GetAllUsersAsync().ConfigureAwait(false);
    var activeUsers = users.Where(u => u.IsActive).ToList();
    
    foreach (var user in activeUsers)
    {
        user.LastAccessed = await GetLastAccessTimeAsync(user.Id);  // Missing ConfigureAwait
    }
    
    return activeUsers;
}
```

---

## Cancellation Tokens

### Accepting CancellationTokens

Always accept CancellationToken parameters in async methods that can be long-running.

```csharp
//  Good: Accept CancellationToken with default value
public async Task<User> GetUserAsync(int userId, CancellationToken cancellationToken = default)
{
    var response = await _httpClient.GetAsync($"/users/{userId}", cancellationToken)
        .ConfigureAwait(false);
    
    var json = await response.Content.ReadAsStringAsync(cancellationToken)
        .ConfigureAwait(false);
    
    return JsonSerializer.Deserialize<User>(json)!;
}

//  Good: Propagating cancellation token through await chain
public async Task<List<User>> GetAllUsersAsync(CancellationToken cancellationToken = default)
{
    var users = new List<User>();
    
    for (int i = 0; i < totalPages; i++)
    {
        cancellationToken.ThrowIfCancellationRequested();
        
        var pageUsers = await GetPageAsync(i, cancellationToken)
            .ConfigureAwait(false);
        
        users.AddRange(pageUsers);
    }
    
    return users;
}

//  Avoid: Ignoring cancellation requests
public async Task<User> GetUserAsync(int userId)
{
    var response = await _httpClient.GetAsync($"/users/{userId}");
    // No cancellation support - cannot be cancelled
}
```

### Checking Cancellation

Check for cancellation in loops or before long operations.

```csharp
//  Good: Explicit cancellation check
public async Task ProcessItemsAsync(List<Item> items, CancellationToken cancellationToken = default)
{
    foreach (var item in items)
    {
        cancellationToken.ThrowIfCancellationRequested();  // Check before processing
        await ProcessItemAsync(item, cancellationToken).ConfigureAwait(false);
    }
}

//  Good: Using ThrowIfCancellationRequested in operations
public async Task<string> FetchWithTimeoutAsync(string url, int timeoutMs)
{
    using var cts = new CancellationTokenSource(timeoutMs);
    
    try
    {
        var response = await _httpClient.GetAsync(url, cts.Token)
            .ConfigureAwait(false);
        
        return await response.Content.ReadAsStringAsync(cts.Token)
            .ConfigureAwait(false);
    }
    catch (OperationCanceledException)
    {
        throw new TimeoutException($"Request to {url} timed out");
    }
}

//  Avoid: Ignoring cancellation tokens
public async Task ProcessItemsAsync(List<Item> items, CancellationToken cancellationToken = default)
{
    foreach (var item in items)
    {
        // Never checks cancellationToken
        await ProcessItemAsync(item).ConfigureAwait(false);
    }
}
```

### Creating CancellationTokenSources

```csharp
//  Good: Creating timeout-based CancellationTokenSource
public async Task<string> FetchWithTimeoutAsync(string url)
{
    using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
    var response = await _httpClient.GetAsync(url, cts.Token);
    return await response.Content.ReadAsStringAsync(cts.Token);
}

//  Good: Combining multiple tokens
public async Task<Result> ExecuteWithCombinedCancellationAsync(
    CancellationToken externalToken)
{
    using var cts = CancellationTokenSource.CreateLinkedTokenSource(externalToken);
    cts.CancelAfter(TimeSpan.FromSeconds(60));
    
    return await DoWorkAsync(cts.Token);
}

//  Avoid: Not disposing CancellationTokenSource
public async Task BadMethodAsync()
{
    var cts = new CancellationTokenSource(30000);
    await SomeAsync(cts.Token);  // Memory leak - never disposed
}
```

---

## Exception Handling

### Exception Propagation in Async Code

Exceptions in async methods are wrapped in Task. They're thrown when awaited.

```csharp
//  Good: Exceptions propagate naturally
public async Task<User> GetUserAsync(int userId)
{
    try
    {
        var user = await _repository.GetUserAsync(userId)
            .ConfigureAwait(false);
        
        if (user == null)
            throw new UserNotFoundException(userId);
        
        return user;
    }
    catch (HttpRequestException ex)
    {
        _logger.LogError(ex, "Failed to fetch user {UserId}", userId);
        throw;  // Re-throw to caller
    }
}

//  Good: Caller handles exceptions
public async Task ProcessUserAsync(int userId)
{
    try
    {
        var user = await GetUserAsync(userId);
        await UpdateUserAsync(user);
    }
    catch (UserNotFoundException)
    {
        _logger.LogWarning("User not found");
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Unexpected error processing user");
        throw;
    }
}

//  Avoid: Swallowing exceptions silently
public async Task<User?> GetUserAsync(int userId)
{
    try
    {
        return await _repository.GetUserAsync(userId).ConfigureAwait(false);
    }
    catch
    {
        return null;  // Silently failing is dangerous
    }
}
```

### Aggregate Exception Handling

When using Task.WhenAll, exceptions are wrapped in AggregateException.

```csharp
//  Good: Handling multiple async operations
public async Task<List<User>> GetUsersAsync(List<int> userIds)
{
    var tasks = userIds.Select(id => _repository.GetUserAsync(id)).ToList();
    
    try
    {
        await Task.WhenAll(tasks).ConfigureAwait(false);
        return tasks.Select(t => t.Result).ToList();
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Error fetching users");
        throw;  // AggregateException if multiple tasks failed
    }
}

//  Good: Flattening aggregate exceptions
public async Task<List<User>> GetUsersAsync(List<int> userIds)
{
    var tasks = userIds.Select(id => _repository.GetUserAsync(id)).ToList();
    
    try
    {
        await Task.WhenAll(tasks).ConfigureAwait(false);
    }
    catch (Exception ex) when (ex is AggregateException agg)
    {
        foreach (var innerException in agg.InnerExceptions)
        {
            _logger.LogError(innerException, "Individual fetch failed");
        }
        throw;
    }
    
    return tasks.Select(t => t.Result).ToList();
}

//  Good: Partial success handling with Task.WhenEach (C# 13+)
public async Task<List<User>> GetUsersWithFallbackAsync(List<int> userIds)
{
    var results = new List<User>();
    var tasks = userIds.Select(id => _repository.GetUserAsync(id)).ToList();
    
    await foreach (var task in Task.WhenEach(tasks))
    {
        try
        {
            var user = await task;
            results.Add(user);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to fetch single user");
        }
    }
    
    return results;
}
```

---

## Avoiding Common Pitfalls

### Pitfall 1: Blocking on Async Code

Never use `.Result` or `.Wait()` on async methods - causes deadlocks.

```csharp
//  DANGER: Can cause deadlock
public User GetUser(int userId)
{
    var user = _service.GetUserAsync(userId).Result;  // DEADLOCK!
    return user;
}

//  DANGER: Same deadlock risk
public void ProcessUser(int userId)
{
    _service.ProcessUserAsync(userId).Wait();  // DEADLOCK!
}

//  Good: Make the caller async instead
public async Task<User> GetUserAsync(int userId)
{
    return await _service.GetUserAsync(userId);
}

//  Good: If async cannot propagate (rare), use RunSynchronously (only in tests/console apps)
public User GetUserBlocking(int userId)
{
    // Only use in special cases like console apps or tests
    var task = _service.GetUserAsync(userId);
    return task.GetAwaiter().GetResult();  // Preserve exception details
}
```

### Pitfall 2: Async Void (Except Event Handlers)

Never use `async void` except for event handlers - uncaught exceptions will crash.

```csharp
//  DANGER: async void - cannot catch exceptions
public async void ProcessOrderAsync(Order order)
{
    try
    {
        await _repository.SaveAsync(order);
        await _notificationService.NotifyAsync(order.CustomerId);
    }
    catch (Exception ex)
    {
        // Exception not caught by caller!
        _logger.LogError(ex, "Order processing failed");
    }
}

//  Good: Use async Task instead
public async Task ProcessOrderAsync(Order order)
{
    await _repository.SaveAsync(order);
    await _notificationService.NotifyAsync(order.CustomerId);
}

//  Acceptable: async void only for event handlers
public async void OnButtonClickAsync(object? sender, EventArgs e)
{
    await ProcessOrderAsync(order);  // Event handler - async void acceptable
}

//  Good: Task-returning event handlers
public event Func<EventArgs, Task>? OrderProcessed;

private async void OnOrderChanged(EventArgs e)
{
    if (OrderProcessed != null)
        await OrderProcessed(e);
}
```

### Pitfall 3: Fire-and-Forget Tasks

Always await async operations or properly handle unawaited tasks.

```csharp
//  DANGER: Fire-and-forget without tracking
public async Task CreateOrderAsync(Order order)
{
    await _repository.SaveAsync(order);
    _notificationService.NotifyAsync(order.CustomerId);  // Fire and forget!
}

//  Good: Properly await all async operations
public async Task CreateOrderAsync(Order order)
{
    await _repository.SaveAsync(order);
    await _notificationService.NotifyAsync(order.CustomerId);
}

//  Good: If fire-and-forget is intentional, handle failures
public async Task CreateOrderAsync(Order order)
{
    await _repository.SaveAsync(order);
    
    // Fire-and-forget with error handling
    _ = _notificationService.NotifyAsync(order.CustomerId)
        .ContinueWith(t =>
        {
            if (t.IsFaulted)
                _logger.LogError(t.Exception, "Notification failed");
        });
}
```

### Pitfall 4: Race Conditions

Be careful with shared state in concurrent async code.

```csharp
//  DANGER: Race condition on shared list
public async Task ProcessUsersAsync(List<User> users)
{
    var tasks = users.Select(async u =>
    {
        var profile = await _service.GetProfileAsync(u.Id);
        users.Add(profile);  // Race condition!
    });
    
    await Task.WhenAll(tasks);
}

//  Good: Collect results safely
public async Task<List<UserProfile>> GetProfilesAsync(List<User> users)
{
    var tasks = users.Select(u => _service.GetProfileAsync(u.Id));
    var profiles = await Task.WhenAll(tasks).ConfigureAwait(false);
    return profiles.ToList();
}

//  Good: Use thread-safe collections if mutation needed
public async Task ProcessUsersAsync(List<User> users)
{
    var profiles = new ConcurrentBag<UserProfile>();
    
    var tasks = users.Select(async u =>
    {
        var profile = await _service.GetProfileAsync(u.Id);
        profiles.Add(profile);  // Thread-safe
    });
    
    await Task.WhenAll(tasks).ConfigureAwait(false);
}
```

---

## Parallel Execution

### Task.WhenAll - Wait for All Tasks

Use Task.WhenAll when you need results from multiple operations.

```csharp
//  Good: Parallel fetching of independent data
public async Task<OrderSummary> GetOrderDetailsAsync(int orderId)
{
    var orderTask = _orderService.GetOrderAsync(orderId);
    var itemsTask = _orderService.GetItemsAsync(orderId);
    var shippingTask = _shippingService.GetShippingInfoAsync(orderId);
    
    await Task.WhenAll(orderTask, itemsTask, shippingTask)
        .ConfigureAwait(false);
    
    return new OrderSummary
    {
        Order = orderTask.Result,
        Items = itemsTask.Result,
        Shipping = shippingTask.Result
    };
}

//  Good: Processing multiple items in parallel
public async Task<List<User>> GetUsersAsync(List<int> userIds)
{
    var tasks = userIds.Select(id => _repository.GetUserAsync(id)).ToArray();
    await Task.WhenAll(tasks).ConfigureAwait(false);
    return tasks.Select(t => t.Result).ToList();
}

//  Caution: Too much parallelism can overwhelm resources
public async Task<List<User>> GetManyUsersAsync(List<int> userIds)
{
    // Limit parallel operations to avoid resource exhaustion
    var semaphore = new SemaphoreSlim(10);  // Max 10 concurrent
    
    var tasks = userIds.Select(async id =>
    {
        await semaphore.WaitAsync();
        try
        {
            return await _repository.GetUserAsync(id);
        }
        finally
        {
            semaphore.Release();
        }
    });
    
    return (await Task.WhenAll(tasks)).ToList();
}
```

### Task.WhenAny - Wait for First Task

Use Task.WhenAny for implementing timeouts or competitive operations.

```csharp
//  Good: Racing multiple providers
public async Task<string> GetDataFromFastestProviderAsync()
{
    var tasks = new[]
    {
        _provider1.FetchAsync(),
        _provider2.FetchAsync(),
        _provider3.FetchAsync()
    };
    
    var completed = await Task.WhenAny(tasks).ConfigureAwait(false);
    return completed.Result;
}

//  Good: Implementing timeout with WhenAny
public async Task<string?> FetchWithTimeoutAsync(string url, int timeoutMs)
{
    var fetchTask = _httpClient.GetStringAsync(url);
    var timeoutTask = Task.Delay(timeoutMs);
    
    var completed = await Task.WhenAny(fetchTask, timeoutTask)
        .ConfigureAwait(false);
    
    if (completed == timeoutTask)
        return null;  // Timeout occurred
    
    return await fetchTask;
}

//  Good: Sequential processing with early exit
public async Task<User?> FindUserInSourcesAsync(string email)
{
    var sources = new[]
    {
        _cache.FindAsync(email),
        _database.FindAsync(email),
        _api.FindAsync(email)
    };
    
    while (sources.Length > 0)
    {
        var completed = await Task.WhenAny(sources).ConfigureAwait(false);
        var user = await (Task<User?>)completed;
        
        if (user != null)
            return user;
        
        sources = sources.Where(t => t != completed).ToArray();
    }
    
    return null;
}
```

---

## Task Composition

### Combining Multiple Operations

```csharp
//  Good: Sequential composition with readability
public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
{
    var customer = await ValidateCustomerAsync(request.CustomerId);
    var items = await ValidateItemsAsync(request.Items);
    var order = await _repository.CreateAsync(new Order 
    { 
        Customer = customer, 
        Items = items 
    });
    await _notificationService.NotifyAsync(customer.Email);
    return order;
}

//  Good: ContinueWith for chaining
public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
{
    return await ValidateCustomerAsync(request.CustomerId)
        .ContinueWith(async customerTask =>
        {
            var customer = await customerTask;
            var items = await ValidateItemsAsync(request.Items);
            return await _repository.CreateAsync(new Order
            {
                Customer = customer,
                Items = items
            });
        }, TaskScheduler.Default)
        .Unwrap()
        .ContinueWith(async orderTask =>
        {
            var order = await orderTask;
            await _notificationService.NotifyAsync(order.Customer.Email);
            return order;
        }, TaskScheduler.Default)
        .Unwrap();
}

//  Good: Clear sequential logic with async/await (preferred)
public async Task ProcessBatchAsync(List<Item> items)
{
    foreach (var item in items)
    {
        await ProcessItemAsync(item);
        await LogProcessingAsync(item);
    }
}

//  Good: Parallel then sequential
public async Task<Result> AnalyzeDataAsync(List<DataSet> datasets)
{
    var analyzedTasks = datasets.Select(d => AnalyzeAsync(d)).ToArray();
    var results = await Task.WhenAll(analyzedTasks).ConfigureAwait(false);
    
    var combined = CombineResults(results);
    return await FinalizeAsync(combined);
}
```

---

## Performance Considerations

### Avoiding Unnecessary Async

Not everything needs to be async - only I/O operations benefit.

```csharp
//  Avoid: Unnecessary async overhead
public async Task<int> CalculateSumAsync(List<int> numbers)
{
    await Task.Delay(0);  // Unnecessary
    return numbers.Sum();
}

//  Good: Synchronous for CPU-bound operations
public int CalculateSum(List<int> numbers)
{
    return numbers.Sum();
}

//  Good: Async only for I/O-bound operations
public async Task<decimal> GetPriceAsync(int productId)
{
    return await _priceService.FetchAsync(productId);
}
```

### Reducing Allocations

Reuse tasks and avoid unnecessary allocations in high-throughput scenarios.

```csharp
//  Good: Using Task.CompletedTask for completed tasks
public async Task ValidateAsync(User user)
{
    if (user.IsValid)
        return;  // Returns Task.CompletedTask
    
    await _emailService.SendInvalidNoticeAsync(user);
}

//  Good: Using ValueTask for hot paths (low allocation)
public async ValueTask<User?> GetUserAsync(int userId)
{
    if (_cache.TryGetValue(userId, out var user))
        return user;  // Returns ValueTask - no allocation
    
    return await _repository.GetUserAsync(userId);
}

//  Good: Avoiding Task allocation when synchronously completed
public ValueTask<int> ParseAsync(string value)
{
    if (int.TryParse(value, out var result))
        return new ValueTask<int>(result);  // No async overhead
    
    return new ValueTask<int>(ParseFromServiceAsync(value));
}
```

### Monitoring Async Performance

```csharp
//  Good: Tracking async operation timing
public async Task<User> GetUserAsync(int userId)
{
    using var timer = _telemetry.StartTimer("GetUser");
    
    var user = await _repository.GetUserAsync(userId)
        .ConfigureAwait(false);
    
    timer.Stop();
    return user;
}

//  Good: Detecting deadlocks and long waits
public async Task<User> GetUserWithTimeoutAsync(int userId)
{
    using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(30));
    
    try
    {
        return await _repository.GetUserAsync(userId, cts.Token)
            .ConfigureAwait(false);
    }
    catch (OperationCanceledException)
    {
        _logger.LogError("GetUser timed out for userId={UserId}", userId);
        throw;
    }
}
```

---

## Summary

Async/await best practices:

1. **Always use async/await** for I/O-bound operations
2. **Add Async suffix** to Task-returning methods
3. **Use ConfigureAwait(false)** in library code
4. **Accept and propagate** CancellationTokens
5. **Never block on async** code (no .Result or .Wait())
6. **Avoid async void** except for event handlers
7. **Handle exceptions** properly in async code
8. **Use Task.WhenAll** for parallel operations
9. **Check for cancellation** in loops
10. **Test for deadlocks** when integrating async code

Following these patterns ensures your async code is safe, performant, and maintainable.
