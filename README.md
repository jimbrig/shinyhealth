
# shinyhealth <img src="man/figures/logo.png" align="right" height="139" alt="" />

<!-- badges: start -->
[![DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/jimbrig/shinyhealth)

[![Automate Changelog](https://github.com/jimbrig/shinyhealth/actions/workflows/changelog.yml/badge.svg)](https://github.com/jimbrig/shinyhealth/actions/workflows/changelog.yml)
[![pkgdown](https://github.com/jimbrig/shinyhealth/actions/workflows/pkgdown.yml/badge.svg)](https://github.com/jimbrig/shinyhealth/actions/workflows/pkgdown.yml)
[![R Universe Version](https://jimbrig.r-universe.dev/shinyhealth/badges/version)](https://jimbrig.r-universe.dev/shinyhealth)
<!-- badges: end -->

`shinyhealth` provides best practice, production-grade health check endpoints for R [Shiny][shiny] applications with a single function call.

Deployment platforms ([Kubernetes][k8s-probes], [Google Cloud Run][cloudrun-probes], [Azure Container Apps][aca-probes], AWS load balancers, etc.) rely on HTTP health probes to decide whether your app is alive, ready for traffic, or needs a restart. Shiny has no native concept of a health endpoint -- `shinyhealth` adds one without a plumber sidecar, a second port, or any changes to your UI or server code.

See the [package documentation site][docs] for full reference and articles.

## Installation

You can install the development version of shinyhealth from [GitHub][repo] with:

``` r
# install.packages("pak")
pak::pak("jimbrig/shinyhealth")
```

## Usage

Pipe any Shiny app object through [`add_healthcheck()`][ref-add-healthcheck]:

``` r
library(shiny)
library(shinyhealth)

shinyApp(ui = fluidPage("hello"), server = function(input, output, session) {}) |>
  add_healthcheck()
```

That's it. The app now answers `GET /health` before any UI rendering, session creation, or authentication occurs:

``` sh
$ curl -i http://127.0.0.1:8080/health
HTTP/1.1 200 OK
Content-Type: application/health+json
Cache-Control: no-store

{"status":"pass","timestamp":"2026-09-06T23:00:17Z"}
```

All other requests fall through to your app unchanged -- no `uiPattern` adjustments required, and it works regardless of how the app was constructed (plain `shinyApp()`, [golem][golem], authentication wrappers like [polished][polished], etc.).

### Custom handlers and multiple endpoints

Registrations stack, and handlers are plain functions of the request (see [`health_response()`][ref-health-response] and the handler contract in [`health_handler_default()`][ref-health-handler]):

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

Handler errors never break the endpoint -- they are converted into a machine-readable `503` response with `status: "fail"`.

### Learn more

- The [Getting Started vignette][vignette] walks through the full handler contract, status semantics, and deployment probe configuration for common platforms.
- A runnable [example app][example-app] ships with the package: `shiny::runApp(system.file("shiny", "hello", package = "shinyhealth"))`

<!-- links: start -->
[shiny]: https://shiny.posit.co/
[repo]: https://github.com/jimbrig/shinyhealth
[docs]: https://docs.jimbrig.com/shinyhealth/
[vignette]: https://docs.jimbrig.com/shinyhealth/articles/shinyhealth.html
[ref-add-healthcheck]: https://docs.jimbrig.com/shinyhealth/reference/add_healthcheck.html
[ref-health-response]: https://docs.jimbrig.com/shinyhealth/reference/health_response.html
[ref-health-handler]: https://docs.jimbrig.com/shinyhealth/reference/health_handler_default.html
[example-app]: https://github.com/jimbrig/shinyhealth/blob/main/inst/shiny/hello/app.R
[k8s-probes]: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
[cloudrun-probes]: https://cloud.google.com/run/docs/configuring/healthchecks
[aca-probes]: https://learn.microsoft.com/en-us/azure/container-apps/health-probes
[golem]: https://thinkr-open.github.io/golem/
[polished]: https://polished.tech/
<!-- links: end -->
