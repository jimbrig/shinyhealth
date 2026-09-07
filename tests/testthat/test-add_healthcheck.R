
new_test_app <- function() {
  shiny::shinyApp(
    ui = shiny::fluidPage("hello"),
    server = function(input, output, session) {}
  )
}

# decoration ------------------------------------------------------------------------------------------------------

test_that("add_healthcheck() decorates the app and records metadata", {
  app <- new_test_app()
  old_handler <- app$httpHandler

  out <- add_healthcheck(app)

  expect_s3_class(out, c("shinyhealth_app", "shiny.appobj"))
  expect_identical(class(out)[[1]], "shinyhealth_app")
  expect_true(has_healthcheck(out))
  expect_identical(healthcheck_paths(out), "/health")
  expect_false(identical(out$httpHandler, old_handler))
})

test_that("vector paths register together", {
  app <- add_healthcheck(new_test_app(), path = c("/health", "/healthz"))
  expect_identical(healthcheck_paths(app), c("/health", "/healthz"))
})

test_that("registrations stack without duplicating the class", {
  app <- new_test_app() |>
    add_healthcheck(path = "/livez") |>
    add_healthcheck(path = "/readyz")

  expect_identical(healthcheck_paths(app), c("/livez", "/readyz"))
  expect_identical(sum(class(app) == "shinyhealth_app"), 1L)
})

test_that("re-registering an existing path warns and still returns a valid app", {
  app <- add_healthcheck(new_test_app())
  expect_warning(
    app <- add_healthcheck(app, path = "/health"),
    class = "shinyhealth_warning"
  )
  expect_true(has_healthcheck(app))
})

# introspection ---------------------------------------------------------------------------------------------------

test_that("plain apps report no healthcheck", {
  app <- new_test_app()
  expect_false(has_healthcheck(app))
  expect_identical(healthcheck_paths(app), character(0))
})

test_that("format.shinyhealth_app() lists registered endpoints", {
  app <- add_healthcheck(new_test_app())
  fmt <- format(app)
  expect_true(any(grepl("/health", fmt)))
  expect_true(any(grepl("health_handler_default", fmt)))
})

# validation ------------------------------------------------------------------------------------------------------

test_that("invalid inputs throw check errors", {
  app <- new_test_app()
  expect_error(add_healthcheck(list()), class = "check_error")
  expect_error(add_healthcheck(app, path = "health"), class = "check_error")
  expect_error(add_healthcheck(app, path = character(0)), class = "check_error")
  expect_error(add_healthcheck(app, handler = "not a function"), class = "check_error")
})
