# Changelog

## shinyhealth (development version)

### New Features

- [`add_healthcheck()`](http://docs.jimbrig.com/shinyhealth/reference/add_healthcheck.md)
  registers healthcheck endpoints on any Shiny app object by decorating
  its internal HTTP handler – no `uiPattern` changes, no plumber
  sidecar, no second port. Registrations stack for separate
  liveness/readiness endpoints, handler errors are converted into
  machine-readable `503` responses, and `verbose` (default:
  [`shiny::in_devmode()`](https://rdrr.io/pkg/shiny/man/devmode.html))
  logs probe hits to the console.
- [`health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md)
  creates `health_response` objects (classed
  [`shiny::httpResponse()`](https://rdrr.io/pkg/shiny/man/httpResponse.html)s)
  with best practice defaults: `application/health+json` content type,
  `Cache-Control: no-store`, RFC 3339 UTC timestamps, and independent
  body `status` / HTTP `status_code` semantics. Includes the full S3
  triad
  ([`new_health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md),
  [`validate_health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md),
  [`is_health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md)),
  coercion via
  [`as_health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md),
  and cli-formatted
  [`print()`](https://rdrr.io/r/base/print.html)/[`format()`](https://rdrr.io/r/base/format.html)/[`str()`](https://rdrr.io/r/utils/str.html)
  methods.
- [`health_handler_default()`](http://docs.jimbrig.com/shinyhealth/reference/health_handler_default.md)
  documents and implements the healthcheck handler contract: any
  `function(req)` returning a `health_response`, a
  [`shiny::httpResponse`](https://rdrr.io/pkg/shiny/man/httpResponse.html),
  or a named list.
- [`has_healthcheck()`](http://docs.jimbrig.com/shinyhealth/reference/has_healthcheck.md)
  and
  [`healthcheck_paths()`](http://docs.jimbrig.com/shinyhealth/reference/has_healthcheck.md)
  introspect registered endpoints;
  [`print()`](https://rdrr.io/r/base/print.html) on a decorated app
  announces its endpoints before launching.
- [`ts_utc()`](http://docs.jimbrig.com/shinyhealth/reference/ts_utc.md)
  formats RFC 3339 / ISO 8601 UTC timestamps.
- A runnable example app ships under `inst/shiny/hello`.

### Testing

- Three-tier test suite: pure unit tests, app-object introspection
  tests, and live wire tests against a real running app (non-blocking
  [`shiny::startApp()`](https://rdrr.io/pkg/shiny/man/startApp.html)
  with promise-based requests), including a cross-process probe test
  matching real orchestrator behavior.
