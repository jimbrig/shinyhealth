# Add a Health Check to a Shiny App

Registers one or more healthcheck endpoints on a Shiny app by decorating
the app object's internal HTTP handler. Requests matching a registered
`path` (via `GET`) are answered by `handler` before any UI rendering,
session creation, or authentication occurs; all other requests fall
through to the app unchanged.

Because the interception happens on the app object's own handler, no
`uiPattern` adjustment is required and the endpoint works regardless of
how the app was constructed (plain
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html),
golem, UI wrappers, etc.).

Registrations stack: call `add_healthcheck()` multiple times with
different paths to expose e.g. separate liveness (`/livez`) and
readiness (`/readyz`) endpoints with their own handlers.

## Usage

``` r
add_healthcheck(
  app,
  path = "/health",
  handler = health_handler_default,
  verbose = shiny::in_devmode()
)
```

## Arguments

- app:

  A shiny application object, typically created using
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

- path:

  Character vector of URL paths to register (each must begin with `/`).
  Default `"/health"`.

- handler:

  A healthcheck handler: a function of `req` returning a
  [`health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md),
  a
  [`shiny::httpResponse()`](https://rdrr.io/pkg/shiny/man/httpResponse.html),
  or a named list. See
  [`health_handler_default()`](http://docs.jimbrig.com/shinyhealth/reference/health_handler_default.md)
  for the full contract. Errors thrown by the handler are converted into
  a `503` "fail" response.

- verbose:

  Logical; log a console message for each healthcheck request received.
  Evaluated once at registration time. Defaults to
  [`shiny::in_devmode()`](https://rdrr.io/pkg/shiny/man/devmode.html).

## Value

The modified app object, classed `c("shinyhealth_app", "shiny.appobj")`,
with registration metadata stored in the `shinyhealth` attribute.

## See also

[`health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md),
[`health_handler_default()`](http://docs.jimbrig.com/shinyhealth/reference/health_handler_default.md),
[`has_healthcheck()`](http://docs.jimbrig.com/shinyhealth/reference/has_healthcheck.md),
[`healthcheck_paths()`](http://docs.jimbrig.com/shinyhealth/reference/has_healthcheck.md)

## Examples

``` r
app <- shiny::shinyApp(
  ui = shiny::fluidPage("hello"),
  server = function(input, output, session) {}
)

app <- add_healthcheck(app)
has_healthcheck(app)
#> [1] TRUE
healthcheck_paths(app)
#> [1] "/health"

# stack a second endpoint with a custom handler
app <- add_healthcheck(app, path = "/readyz", handler = function(req) {
  health_response(checks = list(database = list(status = "pass")))
})
healthcheck_paths(app)
#> [1] "/health" "/readyz"
```
