
#  ------------------------------------------------------------------------
#
# Title : shinyhealth conditions
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

# conditions ------------------------------------------------------------------------------------------------------

#' @importFrom rlang caller_env
#' @importFrom cli cli_abort
shinyhealth_abort <- function(msg = NULL, cls = NULL, ..., parent = NULL, call = rlang::caller_env(), .envir = parent.frame()) {
  classes <- c(cls, "shinyhealth_error", "shinyhealth_condition")
  cli::cli_abort(message = msg, class = classes, parent = parent, call = call, .envir = .envir, ...)
}

#' @importFrom cli cli_warn
shinyhealth_warn <- function(msg = NULL, cls = NULL, ..., .envir = parent.frame()) {
  classes <- c(cls, "shinyhealth_warning", "shinyhealth_condition")
  cli::cli_warn(message = msg, class = classes, .envir = .envir, ...)
}

#' @importFrom cli cli_inform
shinyhealth_inform <- function(msg = NULL, cls = NULL, ..., .envir = parent.frame()) {
  classes <- c(cls, "shinyhealth_message", "shinyhealth_condition")
  cli::cli_inform(message = msg, class = classes, .envir = .envir, ...)
}
