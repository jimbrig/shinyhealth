# Health Check Response

Functions for creating and working with `health_response` objects, the
responses served from registered healthcheck endpoints:

- `health_response()`: user-facing helper that assembles a response
  body, applies defaults, validates inputs, and constructs the object.

- `new_health_response()`: low-level constructor for developers
  extending the class. Performs no validation or defaulting beyond
  serialization.

- `validate_health_response()`: structural validator.

- `is_health_response()`: predicate.

- `as_health_response()`: coercion generic used to normalize healthcheck
  handler return values.

A `health_response` *is* a
[`shiny::httpResponse()`](https://rdrr.io/pkg/shiny/man/httpResponse.html)
(classed `c("health_response", "httpResponse")`), so shiny's internal
HTTP machinery serves it like any other response. The structured
(pre-serialization) response body is retained in the `body` attribute
for printing, inspection, and testing.

## Usage

``` r
health_response(
  status = "pass",
  ...,
  checks = NULL,
  status_code = 200L,
  timestamp = ts(),
  headers = list(),
  content_type = "application/health+json"
)

new_health_response(
  body = list(),
  status_code = 200L,
  content_type = "application/health+json",
  headers = list()
)

validate_health_response(
  x,
  arg = rlang::caller_arg(x),
  call = rlang::caller_env()
)

is_health_response(x)

as_health_response(x, ...)
```

## Arguments

- status:

  Character string reported as the body `status` field. Default
  `"pass"`.

- ...:

  Additional named fields merged into the response body at the top level
  (e.g. `version`, `description`, `output`).

- checks:

  Optional named list of check results, serialized under the body's
  `checks` field. Elements may be arbitrarily nested lists; their
  structure is not interpreted.

- status_code:

  Integer HTTP status code between `100` and `599`. Default `200L`.

- timestamp:

  Character timestamp for the body's `timestamp` field. Default
  [`ts()`](http://docs.jimbrig.com/shinyhealth/reference/ts.md).

- headers:

  Named list of HTTP headers merged over the defaults (caller wins).

- content_type:

  MIME type for the response. Default `"application/health+json"`.

- body:

  Named list representing the structured response body (low-level
  constructor).

- x:

  An object to coerce or test.

## Value

- `health_response()`, `new_health_response()`, and
  `as_health_response()` return a `health_response` object (a classed
  [`shiny::httpResponse()`](https://rdrr.io/pkg/shiny/man/httpResponse.html)).

- `validate_health_response()` invisibly returns its input if valid,
  otherwise throws a `check_error` condition.

- `is_health_response()` returns a logical scalar.

## Details

### Status Semantics

The HTTP transport status (`status_code`) and the body `status` field
are deliberately independent:

- Orchestrators and load balancers (Kubernetes, Cloud Run, Azure
  Container Apps, etc.) interpret only the *HTTP status code*: codes \>=
  200 and \< 400 indicate success, anything else indicates failure.

- The body `status` string is a convention for humans and tooling. The
  default value (`"pass"`) follows the IETF health check response format
  draft (`draft-inadarei-api-health-check`, which also suggests `"warn"`
  and `"fail"`), but any value is accepted – use whatever vocabulary
  fits your conventions.

The defaults compose into a healthy response (`status = "pass"`,
`status_code = 200L`). For an unhealthy response, `503L` (Service
Unavailable) is the standard choice, typically paired with
`status = "fail"`. How individual `checks` aggregate into an overall
status is intentionally *not* decided here – that policy belongs to the
handler that builds the response.

### Headers, Content Type, & Timestamps

- Default headers are `Cache-Control: no-store` (RFC 9111) so probe
  responses are never cached. The legacy `Pragma`/`Expires` response
  headers are deprecated by RFC 9111 and intentionally omitted. CORS
  headers are not sent by default (probes are server-to-server); supply
  them via `headers` if a browser client on another origin needs access.

- The default content type is `application/health+json` per the IETF
  draft. The `+json` structured syntax suffix (RFC 6839) guarantees any
  JSON processor handles it; use `content_type` to override (e.g. plain
  `application/json`).

- Timestamps use RFC 3339 / ISO 8601 format in UTC (see
  [`ts()`](http://docs.jimbrig.com/shinyhealth/reference/ts.md)).

## Examples

``` r
# healthy response with defaults
health_response()

# unhealthy response (standard choice: 503 + "fail")
health_response(status = "fail", status_code = 503L)

# custom vocabulary, extra fields, and nested checks
health_response(
  status = "HEALTHY",
  version = "1.0.0",
  checks = list(
    database = list(status = "pass", latency_ms = 2.3),
    api = list(status = "warn", output = "slow response times")
  )
)
```
