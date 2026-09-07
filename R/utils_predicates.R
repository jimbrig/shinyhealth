
#  ------------------------------------------------------------------------
#
# Title : Predicate Utilities
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------


# json --------------------------------------------------------------------

#' @importFrom yyjsonr validate_json_str
#' @importFrom rlang try_fetch
is_valid_json_str <- function(x) {
  rlang::try_fetch({
    suppressWarnings(
      yyjsonr::validate_json_str(
        str = x,
        verbose = FALSE,
        opts = JSON_READ_OPTS
      )
    )
  }, error = function(err) {
    FALSE
  })
}

#' @importFrom yyjsonr validate_json_file
#' @importFrom rlang try_fetch
is_valid_json_file <- function(x) {
  rlang::try_fetch({
    suppressWarnings(
      yyjsonr::validate_json_file(
        filename = x,
        verbose = FALSE,
        opts = JSON_READ_OPTS
      )
    )
  }, error = function(err) {
    FALSE
  })
}

