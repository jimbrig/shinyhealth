# UTC Timestamp

Formats a time as an RFC 3339 / ISO 8601 timestamp in UTC (e.g.
`"2026-09-06T21:15:30Z"`), the interchange format expected in
machine-readable API responses.

Named `ts_utc()` (rather than [`ts()`](https://rdrr.io/r/stats/ts.html))
to avoid masking [`stats::ts()`](https://rdrr.io/r/stats/ts.html).

## Usage

``` r
ts_utc(time = Sys.time())
```

## Arguments

- time:

  A [POSIXct](https://rdrr.io/r/base/DateTimeClasses.html) time.
  Defaults to [`Sys.time()`](https://rdrr.io/r/base/Sys.time.html).

## Value

A character string containing the formatted timestamp.

## Examples

``` r
ts_utc()
#> [1] "2026-09-07T03:15:23Z"
```
