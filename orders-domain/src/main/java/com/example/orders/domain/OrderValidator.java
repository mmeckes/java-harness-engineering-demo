package com.example.orders.domain;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/** Business validation that the API layer can't express with annotations alone. */
public class OrderValidator {

  public static final int MAX_LINES = 100;
  public static final int MAX_QUANTITY_PER_LINE = 999;

  public List<String> validate(Order order) {
    List<String> errors = new ArrayList<>();
    if (order.lines().isEmpty()) {
      errors.add("order must have at least one line");
    }
    if (order.lines().size() > MAX_LINES) {
      errors.add("order must have at most " + MAX_LINES + " lines");
    }
    Set<String> seen = new HashSet<>();
    for (OrderLine line : order.lines()) {
      if (!seen.add(line.sku())) {
        errors.add("duplicate sku " + line.sku() + ": merge quantities into one line");
      }
      if (line.quantity() < 1 || line.quantity() > MAX_QUANTITY_PER_LINE) {
        errors.add("quantity for " + line.sku() + " must be 1.." + MAX_QUANTITY_PER_LINE);
      }
      if (line.unitPrice().compareTo(BigDecimal.ZERO) <= 0) {
        errors.add("unit price for " + line.sku() + " must be positive");
      }
    }
    return errors;
  }
}
