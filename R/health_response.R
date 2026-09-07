
#  ------------------------------------------------------------------------
#
# Title : Healthcheck Response
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

# class -----------------------------------------------------------------------------------------------------------

#' Health Check Response
#'
#' @description
#' Functions for creating and working with `health_response` objects, the responses served from
#' registered healthcheck endpoints:
#'
#' - `health_response()`: user-facing helper that assembles a response body, applies defaults, validates
#'   inputs, and constructs the object.
#' - `new_health_response()`: low-level constructor for developers extending the class. Performs no
#'   validation or defaulting beyond serialization.
#' - `validate_health_response()`: structural validator.
#' - `is_health_response()`: predicate.
#' - `as_health_response()`: coercion generic used to normalize healthcheck handler return values.
#'
#' A `health_response` *is* a [shiny::httpResponse()] (classed `c("health_response", "httpResponse")`),
#' so shiny's internal HTTP machinery serves it like any other response. The structured (pre-serialization)
#' response body is retained in the `body` attribute for printing, inspection, and testing.
#'
#' @details
#' ## Status Semantics
#'
#' The HTTP transport status (`status_code`) and the body `status` field are deliberately independent:
#'
#' - Orchestrators and load balancers (Kubernetes, Cloud Run, Azure Container Apps, etc.) interpret only
#'   the *HTTP status code*: codes >= 200 and < 400 indicate success, anything else indicates failure.
#' - The body `status` string is a convention for humans and tooling. The default value (`"pass"`) follows
#'   the IETF health check response format draft (`draft-inadarei-api-health-check`, which also suggests
#'   `"warn"` and `"fail"`), but any value is accepted -- use whatever vocabulary fits your conventions.
#'
#' The defaults compose into a healthy response (`status = "pass"`, `status_code = 200L`). For an
#' unhealthy response, `503L` (Service Unavailable) is the standard choice, typically paired with
#' `status = "fail"`. How individual `checks` aggregate into an overall status is intentionally *not*
#' decided here -- that policy belongs to the handler that builds the response.
#'
#' ## Headers, Content Type, & Timestamps
#'
#' - Default headers are `Cache-Control: no-store` (RFC 9111) so probe responses are never cached.
#'   The legacy `Pragma`/`Expires` response headers are deprecated by RFC 9111 and intentionally omitted.
#'   CORS headers are not sent by default (probes are server-to-server); supply them via `headers` if a
#'   browser client on another origin needs access.
#' - The default content type is `application/health+json` per the IETF draft. The `+json` structured
#'   syntax suffix (RFC 6839) guarantees any JSON processor handles it; use `content_type` to override
#'   (e.g. plain `application/json`).
#' - Timestamps use RFC 3339 / ISO 8601 format in UTC (see [ts_utc()]).
#'
#' @param status Character string reported as the body `status` field. Default `"pass"`.
#' @param ... Additional named fields merged into the response body at the top level
#'   (e.g. `version`, `description`, `output`).
#' @param checks Optional named list of check results, serialized under the body's `checks` field.
#'   Elements may be arbitrarily nested lists; their structure is not interpreted.
#' @param status_code Integer HTTP status code between `100` and `599`. Default `200L`.
#' @param timestamp Character timestamp for the body's `timestamp` field. Default [ts_utc()].
#' @param headers Named list of HTTP headers merged over the defaults (caller wins).
#' @param content_type MIME type for the response. Default `"application/health+json"`.
#' @param body Named list representing the structured response body (low-level constructor).
#' @param x An object to coerce or test.
#' @inheritParams rlang::args_error_context
#'
#' @returns
#' - `health_response()`, `new_health_response()`, and `as_health_response()` return a `health_response`
#'   object (a classed [shiny::httpResponse()]).
#' - `validate_health_response()` invisibly returns its input if valid, otherwise throws a
#'   `check_error` condition.
#' - `is_health_response()` returns a logical scalar.
#'
#' @export
#'
#' @importFrom rlang list2 %||%
#' @importFrom utils modifyList
#'
#' @examples
#' # healthy response with defaults
#' health_response()
#'
#' # unhealthy response (standard choice: 503 + "fail")
#' health_response(status = "fail", status_code = 503L)
#'
#' # custom vocabulary, extra fields, and nested checks
#' health_response(
#'   status = "HEALTHY",
#'   version = "1.0.0",
#'   checks = list(
#'     database = list(status = "pass", latency_ms = 2.3),
#'     api = list(status = "warn", output = "slow response times")
#'   )
#' )
health_response <- function(
  status = "pass",
  ...,
  checks = NULL,
  status_code = 200L,
  timestamp = ts_utc(),
  headers = list(),
  content_type = "application/health+json"
) {
  check_string(status)
  check_status_code(status_code)
  check_string(timestamp)
  check_string(content_type)
  check_list(headers)

  dots <- rlang::list2(...)
  if (length(dots) > 0) check_named(dots)
  if (!is.null(checks)) {
    check_list(checks)
    check_named(checks)
  }

  body <- c(
    list(status = status, timestamp = timestamp),
    dots,
    if (!is.null(checks)) list(checks = checks)
  )

  headers <- utils::modifyList(.health_headers_default, headers)

  validate_health_response(
    new_health_response(
      body = body,
      status_code = status_code,
      content_type = content_type,
      headers = headers
    )
  )
}

#' @rdname health_response
#' @export
#' @importFrom shiny httpResponse
new_health_response <- function(
  body = list(),
  status_code = 200L,
  content_type = "application/health+json",
  headers = list()
) {
  resp <- shiny::httpResponse(
    status = as.integer(status_code),
    content_type = content_type,
    content = json_write_str(body),
    headers = headers
  )
  structure(resp, body = body, class = c("health_response", class(resp)))
}

#' @rdname health_response
#' @export
#' @importFrom rlang is_integerish caller_arg caller_env
validate_health_response <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "httpResponse", arg = arg, call = call)
  check_names(unclass(x), c("status", "content_type", "content", "headers"), arg = arg, call = call)
  if (!rlang::is_integerish(x$status, n = 1) || x$status < 100L || x$status > 599L) {
    check_abort(
      "{.arg {arg}} must have an HTTP status code between 100 and 599, not {.val {x$status}}.",
      call = call
    )
  }
  body <- attr(x, "body")
  if (!is.null(body) && !is.list(body)) {
    check_abort(
      "{.arg {arg}} must carry a {.cls list} body attribute, not {.obj_type_friendly {body}}.",
      call = call
    )
  }
  invisible(x)
}

#' @rdname health_response
#' @export
is_health_response <- function(x) {
  inherits(x, "health_response")
}

# coercion --------------------------------------------------------------------------------------------------------

#' @rdname health_response
#' @export
as_health_response <- function(x, ...) {
  UseMethod("as_health_response")
}

#' @export
as_health_response.health_response <- function(x, ...) {
  x
}

#' @export
#' @importFrom rlang try_fetch
as_health_response.httpResponse <- function(x, ...) {
  body <- NULL
  if (grepl("json", x$content_type %||% "", fixed = TRUE) && is.character(x$content)) {
    body <- rlang::try_fetch(json_read_str(x$content), error = function(cnd) NULL)
  }
  structure(x, body = body, class = unique(c("health_response", class(x))))
}

#' @export
as_health_response.list <- function(x, ...) {
  check_named(x)
  status_code <- x[["status_code"]] %||% 200L
  x[["status_code"]] <- NULL
  if (is.null(x[["timestamp"]])) x[["timestamp"]] <- ts_utc()
  validate_health_response(
    new_health_response(
      body = x,
      status_code = status_code,
      headers = .health_headers_default
    )
  )
}

#' @export
as_health_response.default <- function(x, ...) {
  shinyhealth_abort(
    c(
      "Unable to coerce {.obj_type_friendly {x}} to a {.cls health_response}.",
      "i" = "Healthcheck handlers must return a {.cls health_response}, a {.cls httpResponse}, or a named {.cls list}."
    ),
    cls = "handler_contract_error"
  )
}

# methods ---------------------------------------------------------------------------------------------------------

#' @export
#' @importFrom cli cli_fmt cli_text
format.health_response <- function(x, ...) {
  body <- attr(x, "body")
  status_line <- trimws(paste(x$status, .http_reason(x$status)))
  size <- nchar(x$content %||% "", type = "bytes")

  cli::cli_fmt({
    cli::cli_text("{.cls health_response}")
    cli::cli_text("Status: {.strong {status_line}}")
    cli::cli_text("Content-Type: {.val {x$content_type}}")
    if (length(x$headers) > 0) {
      cli::cli_text("Headers:")
      for (nm in names(x$headers)) {
        cli::cli_text("  {.field {nm}}: {x$headers[[nm]]}")
      }
    }
    cli::cli_text("Body ({size} bytes):")
    for (nm in names(body)) {
      val <- body[[nm]]
      if (is.list(val)) {
        cli::cli_text("  {.field {nm}}: <list of {length(val)}> {.val {names(val)}}")
      } else {
        cli::cli_text("  {.field {nm}}: {.val {val}}")
      }
    }
  })
}

#' @export
print.health_response <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' @export
#' @importFrom utils str
str.health_response <- function(object, ...) {
  cat("<health_response>\n")
  utils::str(
    list(
      status = object$status,
      content_type = object$content_type,
      headers = object$headers,
      body = attr(object, "body")
    ),
    ...
  )
  invisible()
}

# timestamps ------------------------------------------------------------------------------------------------------

#' UTC Timestamp
#'
#' @description
#' Formats a time as an RFC 3339 / ISO 8601 timestamp in UTC (e.g. `"2026-09-06T21:15:30Z"`),
#' the interchange format expected in machine-readable API responses.
#'
#' Named `ts_utc()` (rather than `ts()`) to avoid masking [stats::ts()].
#'
#' @param time A [POSIXct] time. Defaults to [Sys.time()].
#'
#' @returns
#' A character string containing the formatted timestamp.
#'
#' @export
#'
#' @examples
#' ts_utc()
ts_utc <- function(time = Sys.time()) {
  format(time, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC")
}

# internal --------------------------------------------------------------------------------------------------------

# rfc 9111: no-store prevents caching everywhere; pragma/expires are deprecated legacy
#' @keywords internal
#' @noRd
.health_headers_default <- list(
  "Cache-Control" = "no-store"
)

#' @keywords internal
#' @noRd
.http_reasons <- c(
  "200" = "OK",
  "201" = "Created",
  "202" = "Accepted",
  "204" = "No Content",
  "301" = "Moved Permanently",
  "302" = "Found",
  "304" = "Not Modified",
  "400" = "Bad Request",
  "401" = "Unauthorized",
  "403" = "Forbidden",
  "404" = "Not Found",
  "405" = "Method Not Allowed",
  "408" = "Request Timeout",
  "429" = "Too Many Requests",
  "500" = "Internal Server Error",
  "501" = "Not Implemented",
  "502" = "Bad Gateway",
  "503" = "Service Unavailable",
  "504" = "Gateway Timeout"
)

#' @keywords internal
#' @noRd
.http_reason <- function(code) {
  reason <- .http_reasons[as.character(code)]
  if (is.na(reason)) "" else unname(reason)
}
