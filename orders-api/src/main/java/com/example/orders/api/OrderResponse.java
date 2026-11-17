package com.example.orders.api;

import com.example.orders.domain.PriceBreakdown;
import java.math.BigDecimal;

/** Response body for the orders endpoints. */
public record OrderResponse(
    String id, BigDecimal subtotal, BigDecimal discount, BigDecimal shipping, BigDecimal total) {

  static OrderResponse of(String id, PriceBreakdown p) {
    return new OrderResponse(id, p.subtotal(), p.discount(), p.shipping(), p.total());
  }
}
