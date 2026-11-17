package com.example.orders.api;

import java.util.List;
import org.springframework.http.HttpStatus;

/** The only exception the web layer throws. {@link ApiErrorHandler} maps it to a response. */
public class ApiException extends RuntimeException {

  private final HttpStatus status;
  private final List<String> errors;

  public ApiException(HttpStatus status, List<String> errors) {
    super(String.join("; ", errors));
    this.status = status;
    this.errors = List.copyOf(errors);
  }

  public HttpStatus status() {
    return status;
  }

  public List<String> errors() {
    return errors;
  }
}
