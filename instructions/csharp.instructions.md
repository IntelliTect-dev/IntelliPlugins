---
description: 'Guidelines for building C# applications'
applyTo: '**/*.cs'
---

# C# Development

## C# Instructions
- Always use the latest version C#, currently C# 13 features.
- Write clear and concise comments for each function.

## General Instructions
- Make only high confidence suggestions when reviewing code changes.
- Write code with good maintainability practices, including comments on why certain design decisions were made.
- Handle edge cases and write clear exception handling.
- For libraries or external dependencies, mention their usage and purpose in comments.

## Naming Conventions

- Favor clarity over brevity when naming identifiers.
- Do not use abbreviations or contractions within identifier names.

## Formatting

- Apply code-formatting style defined in `.editorconfig`.
- Use file-scoped namespace declarations (C# 10.0 or later).
- Insert a newline before the opening curly brace of any code block.
- Avoid omitting braces, except for the simplest single-line if statements.
- Use pattern matching and switch expressions wherever possible.
- Use `nameof` instead of string literals when referring to member names.
- Provide XML doc comments on public APIs when they add more context than the signature alone.

## Nullable Reference Types

- Declare variables non-nullable, and check for `null` at entry points.
- Always use `is null` or `is not null` instead of `== null` or `!= null`.
- Trust the C# null annotations and don't add null checks when the type system says a value cannot be null.
- Use nullable check for all reference type properties and fields not initialized before instantiation completes.
- Implement non-nullable reference type automatically implemented properties as read-only.

## Structs and Records

- Use record struct when declaring a struct (C# 10.0).
- Use readonly modifier on struct definitions to make value types immutable.
- Use read-only or init-only setter automatically implemented properties within structs.
- Ensure the default value of a struct is valid.

## Exception Handling

- Favor try/finally over try/catch for cleanup code.
- Throw exceptions that describe the exceptional circumstance and how to prevent it.
- Use empty throw when catching and rethrowing to preserve call stack.
- Verify non-null reference type parameters and throw ArgumentNullException when null.
- Use ArgumentException.ThrowIfNull() in .NET 7.0 or later.
- Avoid using exceptions for normal, expected conditions.
- Catch specific exceptions when you understand the context and can respond programmatically.

## Properties and Fields

- Declare all instance fields as private and expose via properties.
- Use PascalCase for property names.
- Favor automatically implemented properties over fields.
- Create read-only properties if the property value should not be changed.
- Use appropriate accessibility modifiers on property getters and setters.
- Assign non-nullable reference type properties before instantiation completes.

## Methods and Parameters

- Use a collection's Count property instead of calling Enumerable.Count() method.
- Avoid anonymous method syntax; prefer lambda expressions.
- Use `nameof()` instead of string literals when referring to member names.

## Testing

- Always include test cases for critical paths of the application.
- Guide users through creating unit tests using appropriate testing frameworks.
- Copy existing style in nearby files for test method names and capitalization.
- Write tests that verify behavior, not implementation details.
- Use meaningful test method names that describe the scenario being tested.
- Demonstrate effective use of mocking for dependencies.
