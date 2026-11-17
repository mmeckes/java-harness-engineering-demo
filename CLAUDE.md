# Order Service – Project Guide for AI Assistants

IMPORTANT: READ THIS ENTIRE FILE BEFORE DOING ANYTHING. These rules are MANDATORY.

## Commands

- Fast check: ./scripts/fast-check.sh
- One test: ./mvnw -q -pl <module> test -Dtest=<Class>#<method>

## Overview

This is the Order Service, a Spring Boot microservice that handles customer orders. It receives
orders over a REST API, validates them, prices them (including promo codes and shipping), and
stores them. It is part of our wider commerce platform and is consumed by the web shop and by
the mobile app through the generated client in `orders-client`.

The service is written in Java 17 and uses Spring Boot 3.2. We use Maven as our build tool.
It was originally created in 2023 and has been extended many times since then.

## Architecture

The service follows a hexagonal (ports and adapters) architecture. This means that the domain
logic is kept separate from the infrastructure. The domain module contains the core business
logic. The API module contains the REST controllers. The client module contains the client.

- `orders-domain` contains the domain model: `Order`, `OrderLine`, `PriceBreakdown`.
- `orders-domain` also contains `PricingService` which calculates prices.
- `orders-domain` also contains `OrderValidator` which validates orders.
- `orders-api` contains `OrderController`, which exposes `POST /orders` and `GET /orders/{id}`.
- `orders-api` contains `OrderRequest` and `OrderResponse`, which are the DTOs.
- `orders-api` contains `ApiException` and `ApiErrorHandler` for error handling.
- `orders-api` contains `OrdersApplication`, which is the Spring Boot main class.
- `orders-client` contains `OrdersApiClient`, which is used by other services.
- Orders are stored in an in-memory map for now. We plan to move to a database.
- We use MapStruct for mapping between DTOs and domain objects.
- Utility methods for dates are in `utils/DateUtil.java`. Use them for all date handling.

The domain module must not depend on Spring. The API module depends on the domain module.
The client module does not depend on anything. Please respect these dependencies.

## Tech stack

- Java 17
- Spring Boot 3.2
- Maven 3.8
- JUnit 5 and AssertJ for tests
- Mockito for mocks
- Lombok (we are phasing this out, do not use it in new code, but it is OK in old code)
- Jackson for JSON

## Code style

- Use `final` for fields where possible.
- Write clean, maintainable code and follow SOLID principles.
- Use meaningful variable names.
- Don't write long methods.
- Prefer records for immutable data.
- Use Optional instead of returning null.
- Never use `double` or `float` for money, always use BigDecimal.
- Always round money with HALF_EVEN to 2 decimal places.

## Safety

- NEVER read or edit the .env file. It contains secrets.
- NEVER EVER edit anything in orders-client/. It is GENERATED. Changes will be overwritten.
- Don't push to main.
- Be careful with destructive commands.
- Don't delete files unless you are sure.

## Testing

- Always write tests first (TDD).
- Don't add tests unless they are needed.
- Use AssertJ, not JUnit assertions.
- Tests for the controller use MockMvc.
- Never change a test to make it pass.

## Pricing rules

- Promo codes give a percentage off the subtotal.
- WELCOME10 gives 10% off. SPRING5 gives 5% off.
- Shipping costs 4.95.
- Shipping is free when the subtotal is at least 50.00.
- The free-shipping check uses the subtotal after the promo discount.
- Unknown promo codes are ignored.

## API rules

- All REST handlers in orders-api must validate request bodies with Bean Validation.
- Use @Valid on @RequestBody parameters.
- Don't hand-roll null checks in controllers.
- Business rules belong in the domain module, not in controllers.
- Return 400 for malformed input.
- Return 422 for orders that are well-formed but break a business rule.
- Return 404 for unknown order ids.
- Return 201 for created orders.
- The web layer must only throw ApiException.
- ApiErrorHandler maps exceptions to responses.
- Error responses have the shape {"errors": [...]}.
- Every new endpoint needs an example in docs/api-examples/.
- Keep the response shape backwards compatible because the mobile app depends on it.
- Don't add new endpoints without asking.
- Use constructor injection, never field injection.

## Release process

1. Make sure you are on main and the tree is clean.
2. Run the full build with `./mvnw -q verify`.
3. Run `./mvnw versions:set -DnewVersion=<version>` to set the version.
4. Remove the backup POM files that versions:set creates.
5. Update CHANGELOG.md with a new section for the version.
6. List all commits since the last tag in the changelog.
7. Commit with the message "release: <version>".
8. Tag the commit with v<version>.
9. Push the commit.
10. Push the tag.
11. Check that the pipeline has started.
12. Announce the release in the team channel.

## Git

- Write good commit messages.
- Use conventional commits (feat:, fix:, chore:, docs:, test:, refactor:).
- Keep commits small.
- Don't commit generated files.
- Don't commit secrets.

## How to work

- Think step by step.
- Always double-check your answer before responding.
- Be thorough.
- Ask if anything is unclear.
- Don't make assumptions.
- Don't over-engineer.
- Explain what you changed at the end.
- IMPORTANT: Follow ALL of the rules in this file at ALL times.
