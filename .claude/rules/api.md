---
paths:
  - "orders-api/**/*.java"
---
- Request bodies are records with Bean Validation annotations; validate with @Valid, don't hand-roll null checks.
- Business rules belong in orders-domain (OrderValidator, PricingService), not in controllers.
- Status codes: 400 for malformed input, 422 for a well-formed order that breaks a business rule, 404 for unknown ids.
- Every endpoint change needs a request/expected pair in docs/api-examples/ so ./scripts/smoke-test.sh covers it.
