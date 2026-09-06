
#  ------------------------------------------------------------------------
#
# Title : aaa.R - Shared Resources
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

# shared parameters -----------------------------------------------------------------------------------------------

#' Shared Package Parameters
#'
#' @name .shared_params
#'
#' @description
#' Common, shared parameters that can be inherited by other functions in the package.
#'
#' Use `@inheritParams .shared_params` in a function's roxygen2 block to import these parameter descriptions.
#'
#' @param ui User Interface object for the shiny application. Should be a valid `shiny.tag.list` or `bslib_page` by default.
#'
#' @param server Server function for the shiny application or module. Should be a valid R function that takes
#'   `input`, `output`, and `session` as arguments.
#'
#' @param input,output,session Default parameters for shiny server functions.
#'
#' @param app A shiny application object, typically created using [shiny::shinyApp()].
#'
#' @param req A shiny request object
#'
#' @param resp A shiny response object
#'
#' @keywords internal
NULL

# shared returns --------------------------------------------------------------------------------------------------

#' Check Returns
#'
#' @name .shared_returns_check
#'
#' @description
#' Returns for the `check_*()` functions.
#' Use `@inherit .shared_returns_check returns` in a function's roxygen2 block to apply this return description.
#'
#' @returns
#' If the checks pass, invisibly returns the provided object, `x`. If checks fail, a condition error of class `check_error`
#' is thrown.
#'
#' @keywords internal
NULL




