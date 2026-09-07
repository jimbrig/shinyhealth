
# wire test helpers -----------------------------------------------------------------------------------------------

skip_if_no_wire_deps <- function() {
  testthat::skip_if_not_installed("httr2")
  testthat::skip_if_not_installed("promises")
  testthat::skip_if_not_installed("later")
  testthat::skip_if_not_installed("httpuv")
  testthat::skip_if_not_installed("withr")
}

new_wire_app <- function() {
  shiny::shinyApp(
    ui = shiny::fluidPage("wire test ui"),
    server = function(input, output, session) {}
  )
}

# starts the app non-blocking in this process via shiny::startApp() and
# registers cleanup on the calling frame
local_health_app <- function(app, env = parent.frame()) {
  handle <- shiny::startApp(
    app,
    port = httpuv::randomPort(),
    launch.browser = FALSE,
    quiet = TRUE
  )
  withr::defer(try(handle$stop(), silent = TRUE), envir = env)

  deadline <- Sys.time() + 10
  while (handle$status() != "running" && Sys.time() < deadline) {
    later::run_now(0.1)
  }
  if (handle$status() != "running") {
    testthat::skip("test app failed to start")
  }
  handle
}

# a synchronous httr2::req_perform() here would deadlock: curl blocks the only
# R thread, which is the same thread the later event loop needs to run the
# app's http handler. so requests are performed as promises and the event loop
# is pumped until the response resolves.
fetch_url <- function(url, method = "GET") {
  req <- httr2::request(url)
  req <- httr2::req_method(req, method)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  resp <- NULL
  err <- NULL
  p <- httr2::req_perform_promise(req)
  promises::then(p, function(r) resp <<- r, function(e) err <<- conditionMessage(e))

  deadline <- Sys.time() + 10
  while (is.null(resp) && is.null(err) && Sys.time() < deadline) {
    later::run_now(0.1)
  }
  if (!is.null(err)) testthat::skip(paste("request failed:", err))
  if (is.null(resp)) testthat::skip("request timed out")
  resp
}
