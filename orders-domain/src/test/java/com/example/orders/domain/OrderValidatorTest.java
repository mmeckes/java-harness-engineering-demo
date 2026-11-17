package com.example.orders.domain;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.util.List;
import org.junit.jupiter.api.Test;

class OrderValidatorTest {

  private final OrderValidator validator = new OrderValidator();

  @Test
  void validOrderHasNoErrors() {
    Order order = new Order("o-1", List.of(new OrderLine("A", 1, new BigDecimal("1.00"))), null);
    assertThat(validator.validate(order)).isEmpty();
  }

  @Test
  void emptyOrderIsRejected() {
    assertThat(validator.validate(new Order("o-1", List.of(), null)))
        .containsExactly("order must have at least one line");
  }

  @Test
  void duplicateSkuIsRejected() {
    Order order =
        new Order(
            "o-1",
            List.of(
                new OrderLine("A", 1, new BigDecimal("1.00")),
                new OrderLine("A", 2, new BigDecimal("1.00"))),
            null);
    assertThat(validator.validate(order)).anyMatch(e -> e.startsWith("duplicate sku A"));
  }

  @Test
  void quantityOutOfRangeIsRejected() {
    Order order = new Order("o-1", List.of(new OrderLine("A", 0, new BigDecimal("1.00"))), null);
    assertThat(validator.validate(order)).containsExactly("quantity for A must be 1..999");
  }
}
