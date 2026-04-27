---
name: write-bug-tests
description: Write xUnit tests that reproduce a specific bug before the fix is implemented (test-first approach)
---

# Write Bug Tests Skill

Write failing xUnit tests that precisely reproduce a bug's behavior, following the test-first methodology. Tests should fail before the fix and pass after it.

## When to Use

Invoke this skill when you:
- Have identified the root cause of a bug and need to write tests before fixing it
- Want to ensure the fix doesn't regress later
- Need to document the expected behavior through tests

## Inputs Required

- Description of the bug (what happens vs. what should happen)
- The class/method where the bug occurs
- Any known reproduction steps

## Test Structure

Each bug-reproduction test must follow Arrange-Act-Assert:

```csharp
[Fact]
public void ClassName_WhenBugCondition_ShouldExpectedBehavior()
{
    // Arrange — set up the bug-triggering scenario
    var sut = new ServiceUnderTest();
    var input = CreateBugTriggeringInput();

    // Act — perform the action that triggers the bug
    var result = sut.MethodUnderTest(input);

    // Assert — verify the CORRECT (post-fix) behavior
    Assert.Equal(expectedValue, result);
}
```

## Test Naming Convention

Name tests to describe the business scenario, not the implementation:

- ✅ `Order_WhenCancelledAfterShipment_ShouldNotRefundCustomer`
- ✅ `Invoice_WhenTaxRateIsZero_ShouldNotThrowException`
- ❌ `TestMethod1`, `FixBug123`, `CheckNull`

## Steps

1. **Identify the affected class and method**
2. **Locate or create the test file** — follow existing test project naming conventions
3. **Write a test that reproduces the bug** — it must fail with the current code
4. **Run the test to confirm it fails**:
   ```bash
   dotnet test --filter "FullyQualifiedName~TestClassName"
   ```
5. **Write additional tests** for:
   - The happy path (normal behavior)
   - Edge cases mentioned in the work item
   - Related scenarios that could regress

## Guidelines

- Test business requirements, not implementation details
- Use realistic test data (not `"test"`, `0`, or `null` unless that's the bug trigger)
- Each test verifies exactly one business requirement
- Avoid complex test logic — if the test is hard to read, simplify it
- Do not use `Assert.True(result != null)` — use `Assert.NotNull(result)`
