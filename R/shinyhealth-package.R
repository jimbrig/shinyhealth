
#  ------------------------------------------------------------------------
#
# Title : shinyhealth Package
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

# docs --------------------------------------------------------------------

#' `shinyhealth` Package
#'
#' @description
#' The `shinyhealth` package provides tools for incorporating a simple
#' health check (`/health`) endpoint for R Shiny applications.
#'
#' @keywords internal
"_PACKAGE"

# imports -----------------------------------------------------------------

## usethis namespace: start
#' @importFrom rlang caller_arg caller_env .data .env
#' @importFrom rlang new_environment empty_env on_load run_on_load local_use_cli
#' @importFrom cli cli_abort cli_warn cli_inform
## usethis namespace: end
NULL

# globals -----------------------------------------------------------------

#' @keywords internal
#' @noRd
utils::globalVariables(c())
