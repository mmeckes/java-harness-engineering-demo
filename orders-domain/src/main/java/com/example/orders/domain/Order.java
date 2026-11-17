package com.example.orders.domain;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

/** An order as submitted by a customer. The promo code is optional. */
public record Order(String id, List<OrderLine> lines, String promoCode) {

  public Order {
    Objects.requireNonNull(id, "id");
    lines = List.copyOf(Objects.requireNonNull(lines, "lines"));
  }

  public Optional<String> promo() {
    return Optional.ofNullable(promoCode).filter(code -> !code.isBlank());
  }
}
