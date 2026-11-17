package com.example.orders.domain;

import java.math.BigDecimal;
import java.util.Objects;

/** One SKU on an order. Prices are in EUR. */
public record OrderLine(String sku, int quantity, BigDecimal unitPrice) {

  public OrderLine {
    Objects.requireNonNull(sku, "sku");
    Objects.requireNonNull(unitPrice, "unitPrice");
  }

  public BigDecimal lineTotal() {
    return unitPrice.multiply(BigDecimal.valueOf(quantity));
  }
}
