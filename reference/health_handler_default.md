# Default Healthcheck Handler

The default handler used by
[`add_healthcheck()`](http://docs.jimbrig.com/shinyhealth/reference/add_healthcheck.md).
Returns a healthy
[`health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md)
with no additional fields or checks.

This function also documents the *handler contract*: a healthcheck
handler is any function that accepts the incoming request object (`req`)
and returns one of:

- a `health_response` (see
  [`health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md))

- a plain
  [`shiny::httpResponse()`](https://rdrr.io/pkg/shiny/man/httpResponse.html)
  (passed through untouched)

- a named `list`, treated as the complete response body. If it contains
  a `status_code` field, that value is used as the HTTP status code (and
  removed from the body); a `timestamp` field is added when absent.

Handler return values are normalized via
[`as_health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md).
If a handler throws an error,
[`add_healthcheck()`](http://docs.jimbrig.com/shinyhealth/reference/add_healthcheck.md)
converts it into a `503` response with `status = "fail"` and the
condition message under `output` – the endpoint stays machine-readable
even when a check is broken.

## Usage

``` r
health_handler_default(req)
```

## Arguments

- req:

  A shiny request object

## Value

A `health_response` object.

## See also

[`add_healthcheck()`](http://docs.jimbrig.com/shinyhealth/reference/add_healthcheck.md),
[`health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md)

## Examples

``` r
health_handler_default(req = NULL)
```
