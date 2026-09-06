
# myapp <- shiny::shinyApp(ui = shiny::fluidPage("hi"), server = function(input, output, session) {})
# class(myapp)
# myapp$httpHandler
# function (req)
# {
#     if (!isTRUE(req$REQUEST_METHOD %in% allowed_methods))
#         return(NULL)
#     if (!isTRUE(grepl(uiPattern, req$PATH_INFO)))
#         return(NULL)
#     showcaseMode <- .globals$showcaseDefault
#     if (.globals$showcaseOverride) {
#         mode <- showcaseModeOfReq(req)
#         if (!is.null(mode))
#             showcaseMode <- mode
#     }
#     testMode <- getShinyOption("testmode", default = FALSE)
#     bookmarkStore <- getShinyOption("bookmarkStore", default = "disable")
#     if (bookmarkStore == "disable") {
#         restoreContext <- RestoreContext$new()
#     }
#     else {
#         restoreContext <- RestoreContext$new(req$QUERY_STRING)
#     }
#     withRestoreContext(restoreContext, {
#         uiValue <- NULL
#         if (is.function(ui)) {
#             if (length(formals(ui)) > 0) {
#                 uiValue <- ..stacktraceon..(ui(req))
#             }
#             else {
#                 uiValue <- ..stacktraceon..(ui())
#             }
#         }
#         else {
#             if (getCurrentRestoreContext()$active) {
#                 warning("Trying to restore saved app state, but UI code must be a function for this to work! See ?enableBookmarking")
#             }
#             uiValue <- ui
#         }
#     })
#     if (is.null(uiValue))
#         return(NULL)
#     if (inherits(uiValue, "httpResponse")) {
#         return(uiValue)
#     }
#     else {
#         html <- renderPage(uiValue, showcaseMode, testMode)
#         return(httpResponse(200, content = html))
#     }
# }


shiny::shinyApp(ui = shiny::fluidPage("hi"), server = function(input, output, session) {})
