# SPEC: Bulk discount

Status: not implemented. This is the next change to `PricingService`.

## Requirement

Customers buying in bulk get a discount on the lines they buy in bulk.

1. A line with quantity **10 to 49** gets **5%** off that line's total.
2. A line with quantity **50 or more** gets **10%** off that line's total.
3. Bulk discounts are per line. Other lines on the same order are unaffected.
4. **Bulk discounts and promo codes don't stack.** Compute both the total bulk discount and the
   promo discount for the order and apply **whichever is larger**. On a tie, apply the promo code.
5. The free-shipping threshold (50.00) is checked against the subtotal **after** the applied discount,
   as it is today for promo codes.
6. Each line's bulk discount is rounded to cents (HALF_EVEN) before lines are summed.
7. `PriceBreakdown.discount` holds the applied discount, whichever kind it is.

## Edge cases that need tests

- Quantity exactly 9, 10, 49 and 50.
- An order with one bulk line and one non-bulk line.
- Bulk discount larger than the promo, smaller than the promo, and exactly equal (tie goes to promo).
- A bulk discount that pushes the order below the free-shipping threshold, so shipping is charged.
- Rounding: a line whose 5% discount ends in a half cent.

## Out of scope

- Changing promo codes or their rates.
- Any change to orders-client or the API contract. The response shape stays the same.
