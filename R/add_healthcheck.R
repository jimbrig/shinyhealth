
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
#' Adds a health check endpoint to a Shiny app.
#'
#' @param app The Shiny app object.
#' @param path The URL path for the health check endpoint (default is `/health`).
#'
#' @returns
#' The modified `shiny.appobj` object with the updated internal `httpHandler`
#' function for handling health check requests.
#'
#' @export
#'
#' @importFrom shiny httpResponse
#'
#' @examples
#' \dontrun{
#' myapp <- shiny::shinyApp(ui = shiny::fluidPage("hi"), server = function(input, output, session) {})
#' myapp |> add_healthcheck()
#' }
add_healthcheck <- function(app, path = "/health") {
  check_shiny_app(app)
  old <- app$httpHandler
  new <- function(req) {
    if (identical(req$REQUEST_METHOD, "GET") && identical(req$PATH_INFO, path)) {
      return(
        shiny::httpResponse(
          status = 200L,
          content_type = "application/json",
          content = '{"status": 200, "message": "HEALTHY"}',
          headers = list("Cache-Control" = "no-store")
        )
      )
    }
    old(req)
  }
  app$httpHandler <- new
  app
}
