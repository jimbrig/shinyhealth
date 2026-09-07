
#  ------------------------------------------------------------------------
#
# Title : Add Healthcheck
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

#' Add a Health Check to a Shiny App
#'
#' @description
#' Registers one or more healthcheck endpoints on a Shiny app by decorating the app object's
#' internal HTTP handler. Requests matching a registered `path` (via `GET`) are answered by
#' `handler` before any UI rendering, session creation, or authentication occurs; all other
#' requests fall through to the app unchanged.
#'
#' Because the interception happens on the app object's own handler, no `uiPattern`
#' adjustment is required and the endpoint works regardless of how the app was constructed
#' (plain [shiny::shinyApp()], golem, UI wrappers, etc.).
#'
#' Registrations stack: call `add_healthcheck()` multiple times with different paths to expose
#' e.g. separate liveness (`/livez`) and readiness (`/readyz`) endpoints with their own handlers.
#'
#' @inheritParams .shared_params
#' @param path Character vector of URL paths to register (each must begin with `/`).
#'   Default `"/health"`.
#' @param handler A healthcheck handler: a function of `req` returning a [health_response()],
#'   a [shiny::httpResponse()], or a named list. See [health_handler_default()] for the full
#'   contract. Errors thrown by the handler are converted into a `503` "fail" response.
#' @param verbose Logical; log a console message for each healthcheck request received.
#'   Evaluated once at registration time. Defaults to [shiny::in_devmode()].
#'
#' @returns
#' The modified app object, classed `c("shinyhealth_app", "shiny.appobj")`, with registration
#' metadata stored in the `shinyhealth` attribute.
#'
#' @export
#'
#' @importFrom rlang as_label try_fetch cnd_message %||%
#' @importFrom shiny in_devmode
#'
#' @seealso [health_response()], [health_handler_default()], [has_healthcheck()], [healthcheck_paths()]
#'
#' @examples
#' app <- shiny::shinyApp(
#'   ui = shiny::fluidPage("hello"),
#'   server = function(input, output, session) {}
#' )
#'
#' app <- add_healthcheck(app)
#' has_healthcheck(app)
#' healthcheck_paths(app)
#'
#' # stack a second endpoint with a custom handler
#' app <- add_healthcheck(app, path = "/readyz", handler = function(req) {
#'   health_response(checks = list(database = list(status = "pass")))
#' })
#' healthcheck_paths(app)
add_healthcheck <- function(
  app,
  path = "/health",
  handler = health_handler_default,
  verbose = shiny::in_devmode()
) {
  check_shiny_app(app)
  check_url_path(path)
  check_function(handler)
  handler_label <- rlang::as_label(substitute(handler))

  dupes <- intersect(path, healthcheck_paths(app))
  if (length(dupes) > 0) {
    shinyhealth_warn(
      c(
        "!" = "{cli::qty(length(dupes))}Healthcheck path{?s} {.val {dupes}} already registered on this app.",
        "i" = "The new handler will shadow the existing registration."
      )
    )
  }

  force(verbose)
  old <- app$httpHandler

  app$httpHandler <- function(req) {
    if (identical(req$REQUEST_METHOD, "GET") && isTRUE(req$PATH_INFO %in% path)) {
      if (isTRUE(verbose)) healthcheck_log(req)
      return(
        rlang::try_fetch(
          as_health_response(handler(req)),
          error = function(cnd) {
            health_response(
              status = "fail",
              status_code = 503L,
              output = rlang::cnd_message(cnd)
            )
          }
        )
      )
    }
    old(req)
  }

  registrations <- attr(app, "shinyhealth") %||% list()
  registrations[[length(registrations) + 1L]] <- list(
    path = path,
    handler = handler_label,
    registered_at = ts()
  )
  attr(app, "shinyhealth") <- registrations

  if (!inherits(app, "shinyhealth_app")) {
    class(app) <- c("shinyhealth_app", class(app))
  }

  app
}

# introspection ---------------------------------------------------------------------------------------------------

#' Healthcheck Introspection
#'
#' @description
#' - `has_healthcheck()`: does the app have at least one registered healthcheck endpoint?
#' - `healthcheck_paths()`: which paths are registered?
#'
#' @inheritParams .shared_params
#'
#' @returns
#' - `has_healthcheck()`: a logical scalar.
#' - `healthcheck_paths()`: a character vector of registered paths (`character(0)` if none).
#'
#' @export
#'
#' @importFrom rlang %||%
#'
#' @examples
#' app <- shiny::shinyApp(shiny::fluidPage(), function(input, output, session) {})
#' has_healthcheck(app)
#'
#' app <- add_healthcheck(app)
#' has_healthcheck(app)
#' healthcheck_paths(app)
has_healthcheck <- function(app) {
  inherits(app, "shinyhealth_app") && length(attr(app, "shinyhealth") %||% list()) > 0
}

#' @rdname has_healthcheck
#' @export
healthcheck_paths <- function(app) {
  registrations <- attr(app, "shinyhealth") %||% list()
  paths <- unique(unlist(lapply(registrations, function(reg) reg$path)))
  paths %||% character(0)
}

# methods ---------------------------------------------------------------------------------------------------------

#' @export
#' @importFrom cli cli_fmt cli_text
format.shinyhealth_app <- function(x, ...) {
  registrations <- attr(x, "shinyhealth") %||% list()
  cli::cli_fmt({
    cli::cli_text("{.pkg shinyhealth}: {length(registrations)} registered healthcheck endpoint{?s}:")
    for (reg in registrations) {
      cli::cli_text("  {.val {reg$path}}: {.fn {reg$handler}}")
    }
  })
}

# note: printing a shiny.appobj launches the app, so the healthcheck summary is
# emitted first and NextMethod() hands off to shiny's print method to run it
#' @export
print.shinyhealth_app <- function(x, ...) {
  cat(format(x), sep = "\n")
  NextMethod()
}
