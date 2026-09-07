# shinyhealth

[![Automate
Changelog](https://github.com/jimbrig/shinyhealth/actions/workflows/changelog.yml/badge.svg)](https://github.com/jimbrig/shinyhealth/actions/workflows/changelog.yml)
[![pkgdown](https://github.com/jimbrig/shinyhealth/actions/workflows/pkgdown.yml/badge.svg)](https://github.com/jimbrig/shinyhealth/actions/workflows/pkgdown.yml)
[![R Universe
Version](https://jimbrig.r-universe.dev/shinyhealth/badges/version)](https://jimbrig.r-universe.dev/shinyhealth)

## Overview

`shinyhealth` provides best practice, production-grade health check
endpoints for R [Shiny](https://shiny.posit.co/) applications with a
single function call.

See the [package documentation
site](https://docs.jimbrig.com/shinyhealth/) for full reference and
articles.

## Installation

You can install the development version of shinyhealth from
[GitHub](https://github.com/jimbrig/shinyhealth) with:

``` r

# install.packages("pak")
pak::pak("jimbrig/shinyhealth")
```

or via [R Universe](https://jimbrig.r-universe.dev/shinyhealth) with:

``` r

install.packages('shinyhealth', repos = c('https://jimbrig.r-universe.dev', 'https://cloud.r-project.org'))
```

## Usage

Pipe any Shiny app object through
[`add_healthcheck()`](https://docs.jimbrig.com/shinyhealth/reference/add_healthcheck.html):

``` r

library(shiny)
library(shinyhealth)

shinyApp(ui = fluidPage("hello"), server = function(input, output, session) {}) |>
  add_healthcheck()
```

That’s it. The app now answers `GET /health` before any UI rendering,
session creation, or authentication occurs:

``` sh
$ curl -i http://127.0.0.1:8080/health
HTTP/1.1 200 OK
Content-Type: application/health+json
Cache-Control: no-store

{"status":"pass","timestamp":"2026-09-06T23:00:17Z"}
```

All other requests fall through to your app unchanged – no `uiPattern`
adjustments required, and it works regardless of how the app was
constructed (plain
[`shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html),
[golem](https://thinkr-open.github.io/golem/), authentication wrappers
like [polished](https://polished.tech/), etc.).

### Custom handlers and multiple endpoints

Registrations stack, and handlers are plain functions of the request
(see
[`health_response()`](https://docs.jimbrig.com/shinyhealth/reference/health_response.html)
and the handler contract in
[`health_handler_default()`](https://docs.jimbrig.com/shinyhealth/reference/health_handler_default.html)):

``` r

shinyApp(ui, server) |>
  add_healthcheck(path = "/livez") |>
  add_healthcheck(path = "/readyz", handler = function(req) {
    health_response(
      version = "1.0.0",
      checks = list(
        database = list(status = "pass", latency_ms = 2.3),
        upstream_api = list(status = "pass")
      )
    )
  })
```

Handler errors never break the endpoint – they are converted into a
machine-readable `503` response with `status: "fail"`.

### Learn more

- The [Getting Started
  vignette](https://docs.jimbrig.com/shinyhealth/articles/shinyhealth.html)
  walks through the full handler contract, status semantics, and
  deployment probe configuration for common platforms.
- A runnable [example
  app](https://github.com/jimbrig/shinyhealth/blob/main/inst/shiny/hello/app.R)
  ships with the package:
  `shiny::runApp(system.file("shiny", "hello", package = "shinyhealth"))`
