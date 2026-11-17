# Commands
- Fast check (formats, compiles, tests changed modules; the Stop hook runs it): ./scripts/fast-check.sh
- One module: ./mvnw -q -pl <module> -am test
- One test: ./mvnw -q -pl <module> test -Dtest=<Class>#<method>
- Behaviour check for pricing or API changes: ./scripts/smoke-test.sh
- Full build only when asked: ./mvnw -q verify

# Layout
- orders-domain: pricing and validation rules, plain Java. Most changes land here.
- orders-api: Spring Boot REST layer. Rules for it are in .claude/rules/api.md.
- orders-client: generated from openapi.yaml. Never edit by hand.

# Conventions
- Money is BigDecimal in EUR, rounded with PricingService.cents() (HALF_EVEN, 2 dp). Never double.
- The web layer throws ApiException only; ApiErrorHandler maps it to a response.
- New behaviour comes with a test in the same module.

# Gotchas
- If a test was red before your change, say so and show the output. Don't skip it or edit it to pass.
- SPEC.md describes the next pricing change. Read it before touching PricingService.
