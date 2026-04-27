# Usage Examples

Real-world scenarios for using IntelliPlugins in your development work.

## Architecture Review

**You ask:**

```
@solid-principles
This UserService handles authentication, data access, and email notifications.
Does it violate SOLID principles? How should I refactor it?
```

**Copilot response:** Analyzes the code and recommends separating concerns into AuthenticationService, UserRepository, and NotificationService.

---

## Testing Strategy

**You ask:**

```
@testing-essentials
I have a DiscountCalculator service. What test cases should I write?
```

**Copilot response:** Provides test structure, edge cases, and naming conventions using Arrange-Act-Assert pattern.

---

## Modern C# Code

**You ask:**

```
@csharp-best-practices
Is this async code handling cancellation and exceptions correctly?
```

**Copilot response:** Reviews async patterns, exception handling, cancellation tokens, and ConfigureAwait usage.

---

## Full-Stack Development

**You ask:**

```
@coalesce-accelerator @vuetify-components
I need to add an Order feature with a sortable table and edit dialog. What's the full workflow?
```

**Copilot response:** Guides through model design, EF Core relationships, Coalesce generation, and Vuetify components.

---

## Bug Fixing with Azure DevOps

**You ask:**

```
@enterprise-bug-fixing
Help me fix Azure DevOps work item #12345 about incorrect cart totals.
```

**Copilot response:**

1. Fetches work item details
2. Suggests feature branch name
3. Guides root cause analysis
4. Recommends test-first approach

**Follow-up:**

```
@enterprise-bug-fixing @testing-essentials
What edge cases should I test?
```

**Copilot response:** Provides comprehensive test scenarios (standard total, discounts, taxes, partial refunds, multi-currency).

---

## Tips for Best Results

**Be specific** - Include code snippets or file paths
**Provide context** - Framework versions, what's your goal?
**Ask follow-ups** - "How would I test this?" works great
**Combine plugins** - More context = better guidance
