# shinyhealth (development version)

## New Features

- `add_healthcheck()` registers healthcheck endpoints on any Shiny app object by decorating its internal HTTP handler -- no `uiPattern` changes, no plumber sidecar, no second port. Registrations stack for separate liveness/readiness endpoints, handler errors are converted into machine-readable `503` responses, and `verbose` (default: `shiny::in_devmode()`) logs probe hits to the console.
- `health_response()` creates `health_response` objects (classed `shiny::httpResponse()`s) with best practice defaults: `application/health+json` content type, `Cache-Control: no-store`, RFC 3339 UTC timestamps, and independent body `status` / HTTP `status_code` semantics. Includes the full S3 triad (`new_health_response()`, `validate_health_response()`, `is_health_response()`), coercion via `as_health_response()`, and cli-formatted `print()`/`format()`/`str()` methods.
- `health_handler_default()` documents and implements the healthcheck handler contract: any `function(req)` returning a `health_response`, a `shiny::httpResponse`, or a named list.
- `has_healthcheck()` and `healthcheck_paths()` introspect registered endpoints; `print()` on a decorated app announces its endpoints before launching.
- `ts_utc()` formats RFC 3339 / ISO 8601 UTC timestamps.
- A runnable example app ships under `inst/shiny/hello`.

## Testing

- Three-tier test suite: pure unit tests, app-object introspection tests, and live wire tests against a real running app (non-blocking `shiny::startApp()` with promise-based requests), including a cross-process probe test matching real orchestrator behavior.
