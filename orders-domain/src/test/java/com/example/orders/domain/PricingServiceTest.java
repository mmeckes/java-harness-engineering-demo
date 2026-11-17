package com.example.orders.domain;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;

class PricingServiceTest {

  private final PricingService pricing = new PricingService();

  private static Order order(String promo, OrderLine... lines) {
    return new Order("o-1", List.of(lines), promo);
  }

  private static OrderLine line(String sku, int qty, String price) {
    return new OrderLine(sku, qty, new BigDecimal(price));
  }

  @Test
  void subtotalSumsLines() {
    PriceBreakdown p = pricing.price(order(null, line("A", 2, "10.00"), line("B", 1, "5.50")));
    assertThat(p.subtotal()).isEqualByComparingTo("25.50");
    assertThat(p.discount()).isEqualByComparingTo("0.00");
  }

  @Test
  void shippingChargedBelowThreshold() {
    PriceBreakdown p = pricing.price(order(null, line("A", 1, "49.99")));
    assertThat(p.shipping()).isEqualByComparingTo("4.95");
    assertThat(p.total()).isEqualByComparingTo("54.94");
  }

  @Test
  void shippingFreeAtExactlyThreshold() {
    PriceBreakdown p = pricing.price(order(null, line("A", 5, "10.00")));
    assertThat(p.shipping()).isEqualByComparingTo("0.00");
    assertThat(p.total()).isEqualByComparingTo("50.00");
  }

  @Test
  void promoCodeDiscountsSubtotal() {
    PriceBreakdown p = pricing.price(order("WELCOME10", line("A", 10, "10.00")));
    assertThat(p.discount()).isEqualByComparingTo("10.00");
    assertThat(p.total()).isEqualByComparingTo("90.00");
  }

  @Test
  void unknownPromoCodeIsIgnored() {
    PriceBreakdown p = pricing.price(order("NOPE", line("A", 10, "10.00")));
    assertThat(p.discount()).isEqualByComparingTo("0.00");
  }

  @Test
  void freeShippingThresholdUsesDiscountedSubtotal() {
    // 52.00 - 10% = 46.80, which is under the threshold, so shipping is charged.
    PriceBreakdown p = pricing.price(order("WELCOME10", line("A", 4, "13.00")));
    assertThat(p.discount()).isEqualByComparingTo("5.20");
    assertThat(p.shipping()).isEqualByComparingTo("4.95");
    assertThat(p.total()).isEqualByComparingTo("51.75");
  }

  @Test
  void discountRoundsHalfEven() {
    // 0.25 * 10% = 0.025 -> 0.02 with HALF_EVEN (HALF_UP would give 0.03).
    PriceBreakdown p = pricing.price(order("WELCOME10", line("A", 1, "0.25")));
    assertThat(p.discount()).isEqualByComparingTo("0.02");
  }
}
