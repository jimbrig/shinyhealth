
#  ------------------------------------------------------------------------
#
# Title : Healthcheck Handlers
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

#' Default Healthcheck Handler
#'
#' @description
#' The default handler used by [add_healthcheck()]. Returns a healthy [health_response()]
#' with no additional fields or checks.
#'
#' This function also documents the *handler contract*: a healthcheck handler is any function
#' that accepts the incoming request object (`req`) and returns one of:
#'
#' - a `health_response` (see [health_response()])
#' - a plain [shiny::httpResponse()] (passed through untouched)
#' - a named `list`, treated as the complete response body. If it contains a `status_code`
#'   field, that value is used as the HTTP status code (and removed from the body); a
#'   `timestamp` field is added when absent.
#'
#' Handler return values are normalized via [as_health_response()]. If a handler throws an
#' error, [add_healthcheck()] converts it into a `503` response with `status = "fail"` and the
#' condition message under `output` -- the endpoint stays machine-readable even when a check
#' is broken.
#'
#' @inheritParams .shared_params
#'
#' @returns
#' A `health_response` object.
#'
#' @export
#'
#' @seealso [add_healthcheck()], [health_response()]
#'
#' @examples
#' health_handler_default(req = NULL)
health_handler_default <- function(req) {
  health_response()
}

#' @keywords internal
#' @noRd
#' @importFrom cli cli_alert_info
healthcheck_log <- function(req) {
  method <- req[["REQUEST_METHOD"]] %||% "<unknown>"
  path <- req[["PATH_INFO"]] %||% "<unknown>"
  cli::cli_alert_info("[shinyhealth] {method} {path} ({ts_utc()})")
}
