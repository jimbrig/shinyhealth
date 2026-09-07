
# construction ----------------------------------------------------------------------------------------------------

test_that("health_response() builds a valid healthy response by default", {
  resp <- health_response()

  expect_s3_class(resp, c("health_response", "httpResponse"))
  expect_true(is_health_response(resp))
  expect_identical(resp$status, 200L)
  expect_identical(resp$content_type, "application/health+json")
  expect_identical(resp$headers[["Cache-Control"]], "no-store")

  body <- attr(resp, "body")
  expect_identical(body$status, "pass")
  expect_match(body$timestamp, "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$")
})

test_that("body status and http status code are independent", {
  resp <- health_response(status = "HEALTHY", status_code = 299L)
  expect_identical(resp$status, 299L)
  expect_identical(attr(resp, "body")$status, "HEALTHY")

  resp <- health_response(status = "fail", status_code = 503L)
  expect_identical(resp$status, 503L)
  expect_identical(attr(resp, "body")$status, "fail")
})

test_that("dots and nested checks serialize into the body", {
  resp <- health_response(
    version = "1.0.0",
    checks = list(
      db = list(status = "pass", latency_ms = 2.5),
      api = list(status = "warn", output = "slow")
    )
  )

  body <- json_read_str(resp$content)
  expect_identical(body$version, "1.0.0")
  expect_identical(body$checks$db$status, "pass")
  expect_equal(body$checks$db$latency_ms, 2.5)
  expect_identical(body$checks$api$output, "slow")
})

test_that("custom headers merge over defaults with caller winning", {
  resp <- health_response(headers = list("X-Custom" = "1", "Cache-Control" = "max-age=5"))
  expect_identical(resp$headers[["Cache-Control"]], "max-age=5")
  expect_identical(resp$headers[["X-Custom"]], "1")
})

test_that("custom content type is respected", {
  resp <- health_response(content_type = "application/json")
  expect_identical(resp$content_type, "application/json")
})

# validation ------------------------------------------------------------------------------------------------------

test_that("invalid inputs throw check errors", {
  expect_error(health_response(status = c("a", "b")), class = "check_error")
  expect_error(health_response(status = 1L), class = "check_error")
  expect_error(health_response(status_code = 42L), class = "check_error")
  expect_error(health_response(status_code = "200"), class = "check_error")
  expect_error(health_response(checks = list("unnamed")), class = "check_error")
  expect_error(health_response(1), class = "check_error")
})

test_that("validate_health_response() catches malformed objects", {
  resp <- health_response()
  expect_invisible(validate_health_response(resp))
  expect_error(validate_health_response(list()), class = "check_error")
})

# coercion --------------------------------------------------------------------------------------------------------

test_that("as_health_response() passes health_response objects through", {
  resp <- health_response()
  expect_identical(as_health_response(resp), resp)
})

test_that("as_health_response() upgrades plain httpResponse objects", {
  raw <- shiny::httpResponse(
    status = 200L,
    content_type = "application/json",
    content = '{"status": "ok"}'
  )
  coerced <- as_health_response(raw)
  expect_s3_class(coerced, c("health_response", "httpResponse"))
  expect_identical(attr(coerced, "body")$status, "ok")
})

test_that("as_health_response() treats a named list as the response body", {
  coerced <- as_health_response(list(status = "degraded", status_code = 503L))
  expect_identical(coerced$status, 503L)

  body <- attr(coerced, "body")
  expect_identical(body$status, "degraded")
  expect_false("status_code" %in% names(body))
  expect_true(nzchar(body$timestamp))
})

test_that("as_health_response() rejects unsupported types with contract error", {
  expect_error(as_health_response("nope"), class = "handler_contract_error")
  expect_error(as_health_response(42), class = "handler_contract_error")
  expect_error(as_health_response(list("unnamed")), class = "check_error")
})

# methods ---------------------------------------------------------------------------------------------------------

test_that("format() and print() produce readable output", {
  resp <- health_response(checks = list(db = list(status = "pass")))
  fmt <- format(resp)

  expect_type(fmt, "character")
  expect_true(any(grepl("health_response", fmt)))
  expect_true(any(grepl("200", fmt)))
  expect_true(any(grepl("checks", fmt)))
  expect_output(print(resp), "health_response")
})

test_that("str() summarizes the response structure", {
  resp <- health_response()
  expect_output(str(resp), "<health_response>")
})

# timestamps ------------------------------------------------------------------------------------------------------

test_that("ts_utc() formats times as rfc 3339 utc", {
  expect_match(ts_utc(), "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$")

  known <- as.POSIXct("2026-01-02 08:30:00", tz = "America/New_York")
  expect_identical(ts_utc(known), "2026-01-02T13:30:00Z")
})
