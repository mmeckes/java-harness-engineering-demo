package com.example.orders.domain;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;

/**
 * Prices an order: subtotal, promo discount, shipping, total.
 *
 * <p>Rules (see SPEC.md for the next change):
 *
 * <ul>
 *   <li>Promo codes give a percentage off the subtotal.
 *   <li>Shipping is free when the discounted subtotal is at least {@link #FREE_SHIPPING_THRESHOLD}.
 *   <li>Every amount is rounded to cents with {@link RoundingMode#HALF_EVEN}.
 * </ul>
 */
public class PricingService {

  public static final BigDecimal FREE_SHIPPING_THRESHOLD = new BigDecimal("50.00");
  public static final BigDecimal SHIPPING_FEE = new BigDecimal("4.95");

  private static final Map<String, BigDecimal> PROMO_RATES =
      Map.of(
          "WELCOME10", new BigDecimal("0.10"),
          "SPRING5", new BigDecimal("0.05"));

  public PriceBreakdown price(Order order) {
    BigDecimal subtotal =
        order.lines().stream().map(OrderLine::lineTotal).reduce(BigDecimal.ZERO, BigDecimal::add);
    subtotal = cents(subtotal);

    BigDecimal discount = cents(subtotal.multiply(promoRate(order)));
    BigDecimal discounted = subtotal.subtract(discount);

    BigDecimal shipping =
        discounted.compareTo(FREE_SHIPPING_THRESHOLD) >= 0 ? cents(BigDecimal.ZERO) : SHIPPING_FEE;

    return new PriceBreakdown(subtotal, discount, shipping, cents(discounted.add(shipping)));
  }

  private BigDecimal promoRate(Order order) {
    return order.promo().map(PROMO_RATES::get).orElse(BigDecimal.ZERO);
  }

  static BigDecimal cents(BigDecimal amount) {
    return amount.setScale(2, RoundingMode.HALF_EVEN);
  }
}
