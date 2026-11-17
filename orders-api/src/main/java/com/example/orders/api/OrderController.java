package com.example.orders.api;

import com.example.orders.domain.Order;
import com.example.orders.domain.OrderLine;
import com.example.orders.domain.OrderValidator;
import com.example.orders.domain.PricingService;
import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/orders")
class OrderController {

  private final PricingService pricing;
  private final OrderValidator validator;
  private final Map<String, OrderResponse> store = new ConcurrentHashMap<>();

  OrderController(PricingService pricing, OrderValidator validator) {
    this.pricing = pricing;
    this.validator = validator;
  }

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  OrderResponse create(@Valid @RequestBody OrderRequest request) {
    List<OrderLine> lines =
        request.lines().stream()
            .map(l -> new OrderLine(l.sku(), l.quantity(), l.unitPrice()))
            .toList();
    Order order = new Order(UUID.randomUUID().toString(), lines, request.promoCode());

    List<String> errors = validator.validate(order);
    if (!errors.isEmpty()) {
      throw new ApiException(HttpStatus.UNPROCESSABLE_CONTENT, errors);
    }

    OrderResponse response = OrderResponse.of(order.id(), pricing.price(order));
    store.put(order.id(), response);
    return response;
  }

  @GetMapping("/{id}")
  OrderResponse get(@PathVariable String id) {
    OrderResponse response = store.get(id);
    if (response == null) {
      throw new ApiException(HttpStatus.NOT_FOUND, List.of("order " + id + " not found"));
    }
    return response;
  }
}
