
check_shiny_app <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!inherits(x, "shiny.appobj")) {
    cli::cli_abort("{.arg {arg}} must be a shiny app object and inherit from {.cls shiny.appobj}, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

#' @examples
#' myapp <- shiny::shinyApp(ui = shiny::fluidPage("hi"), server = function(input, output, session) {})
#'
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

myapp <- shiny::shinyApp(ui = shiny::fluidPage("hi"), server = function(input, output, session) {})
myapp_w_healthcheck <- add_healthcheck(myapp)

# run app using native print method
myapp_w_healthcheck
# launched with URL and port: http://127.0.0.1:4393/
# open browser to http://127.0.0.1:4393/health
