package com.example.orders.domain;

import java.math.BigDecimal;

/** The result of pricing an order. All amounts are EUR, rounded to cents. */
public record PriceBreakdown(
    BigDecimal subtotal, BigDecimal discount, BigDecimal shipping, BigDecimal total) {}
