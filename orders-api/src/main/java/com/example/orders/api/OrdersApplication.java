package com.example.orders.api;

import com.example.orders.domain.OrderValidator;
import com.example.orders.domain.PricingService;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class OrdersApplication {

  public static void main(String[] args) {
    SpringApplication.run(OrdersApplication.class, args);
  }

  @Bean
  PricingService pricingService() {
    return new PricingService();
  }

  @Bean
  OrderValidator orderValidator() {
    return new OrderValidator();
  }
}
