# Enterprise Bug Fixing Workflow Plugin

A professional-grade bug fixing plugin that enforces a systematic, test-first approach to resolving production issues. This plugin integrates with Azure DevOps, automates feature branch workflows, and ensures comprehensive validation before completion.

## Key Features

- **Test-First Methodology**: Write tests that reproduce the bug before implementing fixes
- **Azure DevOps Integration**: Direct access to work items and issue tracking
- **Automated Workflows**: Feature branch naming from work items with git automation
- **Root Cause Analysis**: Structured approach to identifying the underlying problem
- **Comprehensive Validation**: Multi-stage validation including builds, tests, and code quality checks
- **Model Generation Support**: Automatic Coalesce model regeneration when data models change
- **Pre-Completion Checklists**: Ensures no critical steps are missed

## Installation

Install this plugin into Copilot CLI:

```bash
copilot plugin install enterprise-bug-fixing@IntelliPlugins
```

## Core Philosophy

Enterprise bug fixing is not just about making changes to code—it's about:

1. **Understanding** the business impact and requirements
2. **Reproducing** the issue with automated tests
3. **Isolating** the root cause through systematic analysis
4. **Validating** that the fix works correctly
5. **Preventing** regression with comprehensive test coverage

## Test-First Methodology

Tests should validate **business requirements**, not just code coverage:

### Good Test
```csharp
public void Order_WhenCancelledAfterShipment_ShouldNotRefundCustomer()
{
    // Arrange
    var order = CreateShippedOrder();
    
    // Act
    var result = order.Cancel();
    
    // Assert
    Assert.False(result.IsRefundApproved);
}
```

### Bad Test
```csharp
public void CancelOrder_SetsStatusToCancelled()
{
    // Only tests implementation detail, not business requirement
}
```

## Azure DevOps Integration

The plugin works seamlessly with Azure DevOps work items:

- Queries bug and issue work items from your project
- Extracts requirements, acceptance criteria, and reproduction steps
- Automatically creates feature branches with work item numbers
- Links commits and pull requests to work items

## Feature Branch Workflow

Branches follow a consistent naming convention:

```
{user_initials}/pbi{work_item_number}
```

**Examples:**
- `kb/pbi12345` - Kevin Barnes fixing work item 12345
- `jd/pbi67890` - Jane Doe fixing work item 67890

Benefits:
- Easy to identify the work item associated with a branch
- Consistent naming across teams
- Automatic correlation with Azure DevOps

## Validation & Verification

Every bug fix goes through comprehensive validation:

### Stage 1: Build Validation
- `dotnet build` succeeds
- No compiler errors or warnings
- All project references resolve correctly

### Stage 2: Test Validation
- Unit tests pass
- Business requirement tests pass
- No regressions in related tests

### Stage 3: Code Quality
- Architecture principles adhered to (SOLID, DRY)
- No code quality violations
- Proper error handling and logging

### Stage 4: Model Regeneration (if applicable)
- Coalesce models regenerated
- DTOs updated
- TypeScript definitions generated

### Stage 5: Pre-Completion Checklist
- [ ] Work item understood and requirements clear
- [ ] Feature branch created with correct naming
- [ ] Bug fix implemented following project conventions
- [ ] Tests written validating the business requirement
- [ ] Solution builds successfully
- [ ] All relevant tests pass
- [ ] Code quality checks passed
- [ ] Coalesce regenerated (if model changes made)
- [ ] Ready for code review

## Typical Bug Fix Scenarios

### Scenario 1: Logic Error
**Problem**: A calculation is returning incorrect results

**Approach**:
1. Write a test that reproduces the incorrect calculation with sample data
2. Identify the root cause in the logic
3. Fix the calculation
4. Validate the test passes and no other tests break

### Scenario 2: Missing Validation
**Problem**: Invalid data is being accepted

**Approach**:
1. Write a test that demonstrates the invalid data being accepted
2. Add validation logic
3. Ensure error handling is appropriate
4. Test error messages are user-friendly

### Scenario 3: Data Model Issue
**Problem**: Entity relationships are incorrect or incomplete

**Approach**:
1. Analyze the Coalesce model structure
2. Write tests that demonstrate the issue
3. Modify the EF Core model
4. Run `coalesce_generate` to update DTOs and TypeScript
5. Validate tests pass and UI reflects changes

### Scenario 4: Performance Problem
**Problem**: A query is taking too long

**Approach**:
1. Write a performance test with realistic data
2. Analyze the query execution plan
3. Add indexes or optimize the query
4. Verify performance test passes
5. Ensure no new regressions

## Integration with Testing Plugins

This plugin works best with the **testing-essentials** plugin:

- Use testing patterns from testing-essentials for consistency
- Leverage test fixtures and helpers
- Apply testing best practices from the testing-essentials workflow

## Integration with Architecture Plugins

Follow architecture guidelines from **solid-principles** and **csharp-best-practices**:

- Apply SOLID principles to new code
- Follow C# naming conventions
- Use proper dependency injection patterns
- Implement correct async/await patterns

## Handling Model Changes (Coalesce)

When fixing bugs related to data models:

1. **Modify the EF Core Model**: Update C# entities as needed
2. **Update Coalesce Metadata**: Adjust Coalesce attributes if necessary
3. **Generate Code**: Run `coalesce_generate` to regenerate:
   - Data Transfer Objects (DTOs)
   - TypeScript service layer
   - Api controllers and endpoints
4. **Validate Generated Code**: Review generated code for correctness
5. **Update UI**: Modify Vue components if necessary
6. **Test End-to-End**: Verify the fix works through the full stack

## Code Generation Workflow

### When to Regenerate Models
- After modifying EF Core entities
- After changing Coalesce attributes
- After adding new properties or relationships

### Generation Process
```bash
coalesce_generate
```

This regenerates:
- `Generated/` directory with DTOs
- TypeScript services
- API controllers
- Query endpoints

### Validation After Generation
1. Review new generated code
2. Ensure custom code in `*.Custom.cs` files is preserved
3. Run all tests
4. Verify UI bindings still work

## Best Practices

### Do's
-  Write tests before or immediately after understanding the bug
-  Keep fixes minimal and focused on the specific issue
-  Follow existing project conventions and patterns
-  Document why the fix works, not just what changed
-  Consider edge cases and potential regressions
-  Review requirements thoroughly before coding
-  Use feature branches for all work
-  Run validation checks before requesting review

### Don'ts
-  Don't modify unrelated code
-  Don't skip the test-first approach
-  Don't commit directly to main
-  Don't ignore compiler warnings
-  Don't merge without passing all tests
-  Don't assume the fix is correct without validation
-  Don't create overly complex fixes

## Resources

- **Azure DevOps Documentation**: [Azure DevOps Docs](https://docs.microsoft.com/en-us/azure/devops/)
- **Entity Framework Core**: [EF Core Documentation](https://docs.microsoft.com/en-us/ef/core/)
- **Coalesce Framework**: [Coalesce Documentation](https://intellitect.com/coalesce/)
- **Testing Best Practices**: See testing-essentials plugin
- **Architecture Guidelines**: See solid-principles plugin

## Pre-Bug-Fix Checklist

Before starting work:

- [ ] Have Azure DevOps work item number
- [ ] Understood the issue description and requirements
- [ ] Read acceptance criteria and reproduction steps
- [ ] Identified affected components
- [ ] Checked for related work items or dependencies
- [ ] Confirmed feature branch naming convention
- [ ] Have necessary tools installed (dotnet, npm, git)

## Support & Contributing

For issues or suggestions:

1. Check existing documentation
2. Review similar bug fixes
3. Consult architecture and testing guidelines
4. Reach out to the IntelliTect team

## License

MIT License - See LICENSE file for details

---

**IntelliTect** - Enterprise Software Solutions
