package com.example.orders.api;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;

/** Request body for POST /orders. */
public record OrderRequest(@NotEmpty List<@Valid Line> lines, String promoCode) {

  public record Line(
      @NotBlank String sku,
      @Min(1) int quantity,
      @NotNull @DecimalMin(value = "0.01") BigDecimal unitPrice) {}
}
