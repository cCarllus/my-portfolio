# AGENTS.md

## 1. Purpose

This document defines how AI agents must write, modify, and review code in this repository. Its purpose is to keep all generated changes consistent, maintainable, testable, and aligned with strong Ruby on Rails engineering practices.

Every AI-generated change must prioritize:

- SOLID design
- DRY code
- Clean Code
- Ruby best practices
- Rails best practices
- Maintainability
- Readability

---

## 2. Development Workflow

### Research Existing Patterns

Before writing code:

1. Search for similar services, components, or patterns already implemented.
2. Reuse existing patterns whenever possible.
3. Prefer consistency over introducing new abstractions.

---

### Implementation Flow

1. Read AGENTS.md
2. Read feature spec
3. Read patchs and increments (if any)
4. Understand requirements fully
5. Write tests
6. Implement code
7. Validate changes

---

## 3. Core Principles

### SOLID

- Single Responsibility: one reason to change
- Open/Closed: extend instead of modifying
- Liskov: predictable behavior
- Interface Segregation: small, focused APIs
- Dependency Inversion: depend on abstractions

---

### DRY

- Avoid duplication
- Reuse logic where appropriate
- Extract only when it improves clarity

---

### Clean Code

- Small methods
- Clear naming
- Low nesting
- Readability over cleverness

---

### KISS

- Prefer simple solutions over complex architectures.
- Do not introduce patterns, abstractions, or indirection without a clear need.
- If a plain service object solves the problem cleanly, do not build a framework around it.

---

### YAGNI

- Do not build features, hooks, abstractions, or configuration that are not required by the current need.
- Avoid speculative generalization.
- Implement the current requirement well, and only generalize when duplication or change pressure is real.

---

## 4. Ruby Best Practices

- Write idiomatic Ruby that is easy for another Ruby developer to read.
- Prefer expressive Ruby constructs when they improve clarity.
- Keep methods small and focused.
- Keep classes cohesive.
- Avoid deep nesting; extract guard clauses and private methods when needed.
- Use explicit, descriptive naming for classes, methods, variables, and scopes.
- Avoid unnecessary metaprogramming.
- Avoid monkey patches unless absolutely necessary and clearly justified.
- Prefer plain Ruby objects for business logic.
- Make side effects obvious.
- Keep public APIs small and intentional.

---

## 5. Rails Best Practices

### Models

- Persistence
- Associations
- Validations
- Simple domain logic

---

### Controllers

Controllers must be thin:

- receive request
- load data
- authorize
- permit params
- delegate logic
- render response

No business logic in controllers.

---

### Services

All business logic must live in `app/services`.

Use for:

- workflows
- orchestration
- complex rules
- external integrations

---

### Jobs

- Use for async tasks
- Keep thin
- Delegate to services

---

### Views

- No business logic
- Only rendering and simple formatting
- Use helpers/components

---

## 6. Architecture Guidelines

### app/services

Business logic

### app/policies

Authorization rules

### app/presenters

Formatting and display logic

### app/components

Reusable UI (ViewComponent)

---

## 7. Testing Philosophy

- Tests are mandatory
- Test business logic first
- Focus on services
- Use RSpec
- Avoid brittle tests
- Test behavior, not implementation

---

## 8. Test Execution

After implementing:

1. Run relevant specs
2. Add tests for bug fixes
3. Ensure critical flows are covered

---

## 9. Internationalization (i18n)

All user-facing text must use I18n.

Rules:

- No hardcoded strings
- Use translation keys
- Keep files organized
- Default locale: Portuguese
- Support:
  - Portuguese (pt)
  - English (en)
  - Spanish (es)

Applies to:

- views
- components
- mailers
- flash messages

---

## 10. Security Rules

- Never hardcode secrets
- Use ENV or credentials
- Use strong parameters
- Keep CSRF enabled
- Do not expose internal errors
- Always use policies for authorization
- Validate user input properly

---

## 11. Performance Guidelines

- Avoid N+1 queries
- Use eager loading
- Use background jobs for heavy tasks
- Keep requests fast

---

## 12. Naming Conventions

- Use descriptive names
- Avoid vague names (Manager, Utils, Helper)
- Services must describe actions:
  - Users::Create
  - Auth::VerifyCode

---

## 13. Error Handling

- Never fail silently
- Do not rescue without reason
- Return meaningful errors
- Log failures when needed
- Do not swallow exceptions

---

## 14. Anti-patterns (FORBIDDEN)

- Fat models
- Fat controllers
- Business logic in views
- Code duplication
- God objects
- Deep nesting
- Hidden side effects
- Premature abstraction

---

## 15. Validation Before Completion

Before finishing a task:

1. Ensure implementation matches specs
2. Run tests
3. Review readability
4. Ensure no unrelated changes
5. Confirm architecture rules are followed

---

## 16. AI Behavior Rules

When generating code:

- Prefer clarity over cleverness
- Keep changes minimal
- Follow existing patterns
- Extract logic into services
- Keep code testable
- Avoid unnecessary complexity
- Do not invent requirements
- Do not break existing behavior
- Respect spec-driven approach

---

## Guiding Principle

> AGENTS.md defines how to build

---

**Any code that does not follow this document must be considered incorrect.**
