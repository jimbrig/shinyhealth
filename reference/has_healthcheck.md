# Healthcheck Introspection

- `has_healthcheck()`: does the app have at least one registered
  healthcheck endpoint?

- `healthcheck_paths()`: which paths are registered?

## Usage

``` r
has_healthcheck(app)

healthcheck_paths(app)
```

## Arguments

- app:

  A shiny application object, typically created using
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

## Value

- `has_healthcheck()`: a logical scalar.

- `healthcheck_paths()`: a character vector of registered paths
  (`character(0)` if none).

## Examples

``` r
app <- shiny::shinyApp(shiny::fluidPage(), function(input, output, session) {})
has_healthcheck(app)
#> [1] FALSE

app <- add_healthcheck(app)
has_healthcheck(app)
#> [1] TRUE
healthcheck_paths(app)
#> [1] "/health"
```
