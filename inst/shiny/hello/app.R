# minimal shinyhealth example app
#
# run with:
#   shiny::runApp(system.file("shiny", "hello", package = "shinyhealth"))
#
# then probe the endpoints:
#   curl http://127.0.0.1:<port>/health
#   curl http://127.0.0.1:<port>/readyz

library(shiny)
library(shinyhealth)

ui <- bslib::page_fillable(
  title = "shinyhealth example",
  bslib::card(
    bslib::card_header("shinyhealth example app"),
    htmltools::tags$p("This app exposes two healthcheck endpoints:"),
    htmltools::tags$ul(
      htmltools::tags$li(htmltools::tags$code("/health"), " - default handler"),
      htmltools::tags$li(htmltools::tags$code("/readyz"), " - custom handler with checks")
    )
  )
)

server <- function(input, output, session) {}

shinyApp(ui = ui, server = server) |>
  add_healthcheck() |>
  add_healthcheck(
    path = "/readyz",
    handler = function(req) {
      health_response(
        version = as.character(utils::packageVersion("shinyhealth")),
        checks = list(
          r_session = list(status = "pass", detail = R.version$version.string)
        )
      )
    }
  )
