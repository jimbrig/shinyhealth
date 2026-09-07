
#  ------------------------------------------------------------------------
#
# Title : JSON Utilities
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

# json options ----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom yyjsonr opts_read_json
JSON_READ_OPTS <- yyjsonr::opts_read_json(
  obj_of_arrs_to_df = FALSE,
  arr_of_objs_to_df = FALSE,
  arr_of_arrs_to_matrix = FALSE
)

#' @keywords internal
#' @noRd
#' @importFrom yyjsonr opts_write_json
JSON_WRITE_FILE_OPTS <- yyjsonr::opts_write_json(
  pretty = TRUE,
  auto_unbox = TRUE
)

#' @keywords internal
#' @noRd
#' @importFrom yyjsonr opts_write_json
JSON_WRITE_STR_OPTS <- yyjsonr::opts_write_json(
  pretty = FALSE,
  auto_unbox = TRUE
)


# read --------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @export
#' @importFrom yyjsonr read_json_file
json_read_file <- function(path, opts = JSON_READ_OPTS, ...) {
  check_json_file(path)
  yyjsonr::read_json_file(filename = path, opts = opts, ...)
}

#' @keywords internal
#' @noRd
#' @export
#' @importFrom yyjsonr read_json_str
json_read_str <- function(str, opts = JSON_READ_OPTS, ...) {
  check_json_str(str)
  yyjsonr::read_json_str(str = str, opts = opts, ...)
}

#' @keywords internal
#' @noRd
#' @export
json_read <- function(x, ...) {
  UseMethod("json_read")
}

#' @keywords internal
#' @noRd
#' @export
json_read.character <- function(x, ...) {
  if (is_valid_json_file(x)) {
    json_read_file(x, ...)
  } else if (is_valid_json_str(x)) {
    json_read_str(x, ...)
  } else {
    check_abort(msg = "Provided {.arg x} is not a valid JSON file path or string", call = rlang::caller_env())
  }
}

#' @keywords internal
#' @noRd
#' @export
#' @importFrom yyjsonr read_json_raw
json_read.raw <- function(x, ...) {
  yyjsonr::read_json_raw(raw_vec = x, opts = JSON_READ_OPTS, ...)
}

#' @keywords internal
#' @noRd
#' @export
#' @importFrom yyjsonr read_json_conn
json_read.url <- function(x, ...) {
  yyjsonr::read_json_conn(conn = x, opts = JSON_READ_OPTS, ...)
}

# write -----------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @export
#' @importFrom yyjsonr write_json_str
json_write_str <- function(x, ...) {
  yyjsonr::write_json_str(x = x, opts = JSON_WRITE_STR_OPTS, ...)
}

#' @keywords internal
#' @noRd
#' @export
#' @importFrom yyjsonr write_json_file
json_write_file <- function(x, path, ...) {
  yyjsonr::write_json_file(x = x, filename = path, opts = JSON_WRITE_FILE_OPTS, ...)
}


