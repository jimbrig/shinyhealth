# Getting Started

``` r

library(shinyhealth)
```

## Why health check endpoints?

Deployment platforms decide whether your application is working by
probing an HTTP endpoint:

- **Kubernetes** uses [liveness and readiness
  probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/);
  any status code \>= 200 and \< 400 counts as success, anything else as
  failure.
- **[Google Cloud
  Run](https://cloud.google.com/run/docs/configuring/healthchecks)**,
  **[Azure Container
  Apps](https://learn.microsoft.com/en-us/azure/container-apps/health-probes)**,
  and **AWS load balancers** behave the same way – the HTTP status code
  is the contract.

A failing liveness probe restarts your container; a failing readiness
probe stops routing traffic to it. Shiny has no native concept of a
health endpoint, and the common workarounds (wrapping the UI function,
adjusting `uiPattern`, running a plumber sidecar) are easy to get wrong
– a misconfigured `uiPattern` silently 404s every probe, and a health
check behind an authentication wrapper bounces probes to a sign-in page.

`shinyhealth` solves this at the right layer: the app object’s own HTTP
handler, where requests can be intercepted before any UI rendering,
session creation, or authentication.

## Adding a health check

Pipe any Shiny app object through
[`add_healthcheck()`](http://docs.jimbrig.com/shinyhealth/reference/add_healthcheck.md):

``` r

app <- shiny::shinyApp(
  ui = shiny::fluidPage("hello"),
  server = function(input, output, session) {}
) |>
  add_healthcheck()

has_healthcheck(app)
#> [1] TRUE
healthcheck_paths(app)
#> [1] "/health"
```

The decorated app answers `GET /health` with a JSON response and passes
every other request through to your app unchanged. No `uiPattern`
adjustment is needed, and construction method does not matter – plain
[`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html),
golem, or apps wrapped by authentication packages like polished all
work, because the interception happens after the app object is fully
constructed.

Probing the endpoint returns:

``` sh
$ curl -i http://127.0.0.1:8080/health
HTTP/1.1 200 OK
Content-Type: application/health+json
Cache-Control: no-store

{"status":"pass","timestamp":"2026-09-06T23:00:17Z"}
```

## Health responses

[`health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md)
builds the response objects served from health endpoints. The defaults
produce a healthy response:

``` r

health_response()
```

Two fields are deliberately independent:

- **`status_code`** (the HTTP transport status) is what orchestrators
  interpret. `200` means healthy; `503` (Service Unavailable) is the
  standard choice for unhealthy.
- **`status`** (the body field) is a convention for humans and tooling.
  The default vocabulary (`"pass"`, and by convention `"warn"` /
  `"fail"`) follows the [IETF health check response format
  draft](https://datatracker.ietf.org/doc/html/draft-inadarei-api-health-check),
  but any value is accepted.

The response defaults follow the relevant standards:
[`application/health+json`](https://datatracker.ietf.org/doc/html/draft-inadarei-api-health-check)
content type (safe for any JSON consumer per [RFC
6839](https://www.rfc-editor.org/rfc/rfc6839)’s `+json` suffix rule),
[`Cache-Control: no-store`](https://www.rfc-editor.org/rfc/rfc9111) so
probe responses are never cached, and [RFC
3339](https://www.rfc-editor.org/rfc/rfc3339) UTC timestamps.

``` r

health_response(status = "fail", status_code = 503L)
```

Additional named fields merge into the body, and `checks` carries
arbitrarily nested check results:

``` r

health_response(
  version = "1.0.0",
  checks = list(
    database = list(status = "pass", latency_ms = 2.3),
    upstream_api = list(status = "warn", output = "slow response times")
  )
)
```

## The handler contract

A handler is any function that accepts the request object and returns
one of:

1.  a
    [`health_response()`](http://docs.jimbrig.com/shinyhealth/reference/health_response.md)
2.  a plain
    [`shiny::httpResponse()`](https://rdrr.io/pkg/shiny/man/httpResponse.html)
    (passed through untouched)
3.  a named list, treated as the complete response body – a
    `status_code` field, if present, controls the HTTP status

``` r

handler <- function(req) {
  list(status = "degraded", status_code = 503L, reason = "cache warming")
}

as_health_response(handler(req = NULL))
```

If a handler throws an error, the endpoint stays machine-readable: the
error is converted into a `503` response with `status = "fail"` and the
condition message under `output`.

## Liveness and readiness endpoints

Registrations stack, so separate endpoints with different handlers are
just repeated calls:

``` r

app <- shiny::shinyApp(
  ui = shiny::fluidPage("hello"),
  server = function(input, output, session) {}
) |>
  add_healthcheck(path = "/livez") |>
  add_healthcheck(path = "/readyz", handler = function(req) {
    health_response(
      checks = list(database = list(status = "pass"))
    )
  })

healthcheck_paths(app)
#> [1] "/livez"  "/readyz"
```

A common pattern: keep the liveness handler trivial (the default – if
the process can answer, it is alive) and put dependency checks on the
readiness endpoint, so a database blip stops traffic routing without
triggering container restarts.

## Console feedback during development

[`add_healthcheck()`](http://docs.jimbrig.com/shinyhealth/reference/add_healthcheck.md)’s
`verbose` argument (default:
[`shiny::in_devmode()`](https://shiny.posit.co/r/reference/shiny/latest/devmode.html))
logs each probe hit to the console running the app. Enable
[devmode](https://shiny.posit.co/r/reference/shiny/latest/devmode.html)
during development to watch probes arrive:

``` r

shiny::devmode()
shiny::runApp(app)
#> i [shinyhealth] GET /health (2026-09-06T23:00:17Z)
```

## Configuring platform probes

With the endpoint in place, point your platform’s probes at it.
[Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/):

``` yaml
livenessProbe:
  httpGet:
    path: /livez
    port: 8080
  periodSeconds: 30
readinessProbe:
  httpGet:
    path: /readyz
    port: 8080
  periodSeconds: 10
```

[Google Cloud
Run](https://cloud.google.com/run/docs/configuring/healthchecks)
(`gcloud run services update` or service YAML):

``` yaml
startupProbe:
  httpGet:
    path: /health
    port: 8080
livenessProbe:
  httpGet:
    path: /health
    port: 8080
```

[Azure Container
Apps](https://learn.microsoft.com/en-us/azure/container-apps/health-probes)
(bicep/ARM `probes` block or the portal):

``` yaml
probes:
  - type: Liveness
    httpGet:
      path: /livez
      port: 8080
  - type: Readiness
    httpGet:
      path: /readyz
      port: 8080
```

## Example app

A runnable example ships with the package:

``` r

shiny::runApp(system.file("shiny", "hello", package = "shinyhealth"))
```

It exposes `/health` (default handler) and `/readyz` (custom handler
with checks) – open either path in a browser or probe them with curl
while the app runs.
