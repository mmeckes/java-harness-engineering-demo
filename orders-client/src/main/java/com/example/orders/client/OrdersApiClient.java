// GENERATED CODE - DO NOT EDIT.
// Generated from openapi.yaml by scripts/generate-client.sh. Edit the spec and regenerate instead.
package com.example.orders.client;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public final class OrdersApiClient {

  private final HttpClient http = HttpClient.newHttpClient();
  private final URI baseUri;

  public OrdersApiClient(URI baseUri) {
    this.baseUri = baseUri;
  }

  /** POST /orders. Returns the raw JSON response body. */
  public String createOrder(String orderJson) throws IOException, InterruptedException {
    HttpRequest request =
        HttpRequest.newBuilder(baseUri.resolve("/orders"))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(orderJson))
            .build();
    return http.send(request, HttpResponse.BodyHandlers.ofString()).body();
  }

  /** GET /orders/{id}. Returns the raw JSON response body. */
  public String getOrder(String id) throws IOException, InterruptedException {
    HttpRequest request = HttpRequest.newBuilder(baseUri.resolve("/orders/" + id)).GET().build();
    return http.send(request, HttpResponse.BodyHandlers.ofString()).body();
  }
}
