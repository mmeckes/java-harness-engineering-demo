package com.example.orders.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class OrderControllerTest {

  @Autowired MockMvc mvc;

  @Test
  void createsAndPricesAnOrder() throws Exception {
    mvc.perform(
            post("/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    """
                    {"lines":[{"sku":"A","quantity":10,"unitPrice":10.00}],"promoCode":"WELCOME10"}
                    """))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.subtotal").value(100.00))
        .andExpect(jsonPath("$.discount").value(10.00))
        .andExpect(jsonPath("$.shipping").value(0.00))
        .andExpect(jsonPath("$.total").value(90.00));
  }

  @Test
  void rejectsEmptyOrder() throws Exception {
    mvc.perform(post("/orders").contentType(MediaType.APPLICATION_JSON).content("{\"lines\":[]}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void rejectsDuplicateSku() throws Exception {
    mvc.perform(
            post("/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content(
                    """
                    {"lines":[{"sku":"A","quantity":1,"unitPrice":1.00},
                              {"sku":"A","quantity":2,"unitPrice":1.00}]}
                    """))
        .andExpect(status().isUnprocessableContent());
  }
}
