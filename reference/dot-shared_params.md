# Shared Package Parameters

Common, shared parameters that can be inherited by other functions in
the package.

Use `@inheritParams .shared_params` in a function's roxygen2 block to
import these parameter descriptions.

## Arguments

- ui:

  User Interface object for the shiny application. Should be a valid
  `shiny.tag.list` or `bslib_page` by default.

- server:

  Server function for the shiny application or module. Should be a valid
  R function that takes `input`, `output`, and `session` as arguments.

- input, output, session:

  Default parameters for shiny server functions.

- app:

  A shiny application object, typically created using
  [`shiny::shinyApp()`](https://rdrr.io/pkg/shiny/man/shinyApp.html).

- req:

  A shiny request object

- resp:

  A shiny response object
