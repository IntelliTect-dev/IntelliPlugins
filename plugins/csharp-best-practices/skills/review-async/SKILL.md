---
name: review-async
description: Review async/await usage in a C# file or selection for common pitfalls and anti-patterns
---

# Review Async Skill

Audit async/await usage in the current file or selected code for correctness, safety, and adherence to C# async best practices.

## When to Use

Invoke this skill when you:
- Want to check a file for async anti-patterns before code review
- Suspect a deadlock or performance issue caused by improper async usage
- Are migrating synchronous code to async and want a validation pass
- Added new async methods and want them reviewed

## What This Skill Checks

### 1. Blocking on async (deadlock risk)
```csharp
// ❌ Dangerous — can deadlock in non-console contexts
var result = GetDataAsync().Result;
var result = GetDataAsync().GetAwaiter().GetResult();
Task.Run(() => GetDataAsync()).Wait();

// ✅ Correct
var result = await GetDataAsync();
```

### 2. async void (fire-and-forget danger)
```csharp
// ❌ Exceptions are unobservable
public async void LoadData() { ... }

// ✅ Use Task return type; async void only for event handlers
public async Task LoadDataAsync() { ... }
```

### 3. Missing ConfigureAwait(false) in library code
```csharp
// ❌ In a library — may cause deadlocks in UI/ASP.NET contexts
await _client.GetAsync(url);

// ✅ In library code
await _client.GetAsync(url).ConfigureAwait(false);
```

### 4. Unnecessary async wrapper
```csharp
// ❌ Unnecessary state machine overhead
public async Task<int> GetCountAsync() => await _repo.CountAsync();

// ✅ Just return the Task directly
public Task<int> GetCountAsync() => _repo.CountAsync();
```

### 5. Missing CancellationToken propagation
```csharp
// ❌ Ignores cancellation
public async Task ProcessAsync() { await _db.SaveChangesAsync(); }

// ✅ Propagates cancellation
public async Task ProcessAsync(CancellationToken ct = default)
    { await _db.SaveChangesAsync(ct); }
```

### 6. Unobserved task (fire-and-forget without handling)
```csharp
// ❌ Exception is swallowed
_ = DoWorkAsync();

// ✅ If fire-and-forget is intentional, handle exceptions
_ = DoWorkAsync().ContinueWith(t => _logger.LogError(t.Exception, "Background task failed"),
    TaskContinuationOptions.OnlyOnFaulted);
```

## Review Output

For each issue found, report:
- **Location**: file name and line number
- **Issue type**: one of the categories above
- **Severity**: Warning or Error
- **Suggested fix**: corrected code snippet
