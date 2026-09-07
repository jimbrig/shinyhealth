
# end-to-end tests against a live app served by shiny::startApp() with real
# http requests from httr2

test_that("registered endpoints respond over http with json", {
  skip_on_cran()
  skip_if_no_wire_deps()

  app <- new_wire_app() |>
    add_healthcheck(verbose = FALSE) |>
    add_healthcheck(
      path = "/readyz",
      handler = function(req) {
        health_response(checks = list(db = list(status = "pass", latency_ms = 1.5)))
      },
      verbose = FALSE
    )

  handle <- local_health_app(app)
  base <- handle$url()

  resp <- fetch_url(paste0(base, "/health"))
  expect_identical(httr2::resp_status(resp), 200L)
  expect_identical(httr2::resp_content_type(resp), "application/health+json")
  expect_identical(httr2::resp_header(resp, "Cache-Control"), "no-store")

  body <- httr2::resp_body_json(resp)
  expect_identical(body$status, "pass")
  expect_match(body$timestamp, "Z$")

  ready <- httr2::resp_body_json(fetch_url(paste0(base, "/readyz")))
  expect_identical(ready$checks$db$status, "pass")
  expect_equal(ready$checks$db$latency_ms, 1.5)
})

test_that("non-health requests fall through to the app", {
  skip_on_cran()
  skip_if_no_wire_deps()

  handle <- local_health_app(add_healthcheck(new_wire_app(), verbose = FALSE))
  base <- handle$url()

  root <- fetch_url(base)
  expect_identical(httr2::resp_status(root), 200L)
  expect_match(httr2::resp_content_type(root), "text/html")
  expect_match(httr2::resp_body_string(root), "wire test ui")

  expect_identical(httr2::resp_status(fetch_url(paste0(base, "/nope"))), 404L)
  expect_identical(httr2::resp_status(fetch_url(paste0(base, "/health"), method = "POST")), 404L)
})

test_that("a failing handler yields a machine-readable 503", {
  skip_on_cran()
  skip_if_no_wire_deps()

  app <- add_healthcheck(
    new_wire_app(),
    handler = function(req) stop("boom"),
    verbose = FALSE
  )
  handle <- local_health_app(app)

  resp <- fetch_url(paste0(handle$url(), "/health"))
  expect_identical(httr2::resp_status(resp), 503L)
  expect_identical(httr2::resp_content_type(resp), "application/health+json")

  body <- httr2::resp_body_json(resp)
  expect_identical(body$status, "fail")
  expect_match(body$output, "boom")
})

test_that("a handler returning a named list controls the http status", {
  skip_on_cran()
  skip_if_no_wire_deps()

  app <- add_healthcheck(
    new_wire_app(),
    handler = function(req) list(status = "degraded", status_code = 503L),
    verbose = FALSE
  )
  handle <- local_health_app(app)

  resp <- fetch_url(paste0(handle$url(), "/health"))
  expect_identical(httr2::resp_status(resp), 503L)
  expect_identical(httr2::resp_body_json(resp)$status, "degraded")
})

test_that("verbose mode logs probe hits to the console", {
  skip_on_cran()
  skip_if_no_wire_deps()

  handle <- local_health_app(add_healthcheck(new_wire_app(), verbose = TRUE))

  expect_message(
    fetch_url(paste0(handle$url(), "/health")),
    "shinyhealth"
  )
})
