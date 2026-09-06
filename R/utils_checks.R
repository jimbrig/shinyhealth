
#  ------------------------------------------------------------------------
#
# Title : Check Utilities
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

# check_abort -------------------------------------------------------------

#' @importFrom rlang caller_env
check_abort <- function(msg, ..., call = rlang::caller_env(), .envir = parent.frame()) {
  shinyhealth_abort(msg = msg, cls = "check_error", ..., call = call, .envir = .envir)
}

# inherits --------------------------------------------------------------------------------------------------------

#' Class Inheritance Checks
#'
#' @description
#' These functions perform checks that assert the underlying class of objects passed to them.
#'
#' - `check_inherits()`: checks that object `x` is of class `class` using [base::inherits()]
#' - `check_inherits2()`: checks that object `x` is of class `class` using [base::.class2()]
#' - `check_inherits_any()`: checks that object `x` is at least one of the provided `classes` via [rlang::inherits_any()]
#' - `check_inherits_all()`: checks that object `x` is all of the provided `classes` via [rlang::inherits_all()]
#'
#' If validation fails for any of these functions, an error is thrown via `check_abort()` displaying a friendly
#' error message.
#'
#' @param x The object to check.
#' @param class,classes The name of the class or classes to use during checking.
#' @inheritParams rlang::args_error_context
#'
#' @returns
#' If checks pass, invisibly returns the provided `x` object. If checks fail, a condition error is thrown.
#'
#' @export
check_inherits <- function(x, class, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!inherits(x, class)) {
    check_abort("{.arg {arg}} must inherit from class {.cls {class}}, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

#' @rdname check_inherits
#' @export
check_inherits2 <- function(x, class, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!(class %in% .class2(x))) {
    check_abort("{.arg {arg}} must inherit from class {.cls {class}}, not {.cls {.class2(x)}}", call = call)
  }
  invisible(x)
}

#' @rdname check_inherits
#' @export
#' @importFrom rlang inherits_any
check_inherits_any <- function(x, classes, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::inherits_any(x, classes)) {
    check_abort(
      "{.arg {arg}} must inherit from one of the classes: {.cls {classes}}, not {.obj_type_friendly {x}}.",
      call = call
    )
  }
  invisible(x)
}

#' @rdname check_inherits
#' @export
#' @importFrom rlang inherits_all
check_inherits_all <- function(x, classes, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::inherits_all(x, classes)) {
    check_abort(
      "{.arg {arg}} must inherit from all of the classes: {.cls {classes}}, not {.obj_type_friendly {x}}.",
      call = call
    )
  }
  invisible(x)
}


# types -----------------------------------------------------------------------------------------------------------

check_typeof <- function(x, type, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!identical(typeof(x), type)) {
    check_abort("{.arg {arg}} must be of type {.cls {type}}, not {.obj_type_friendly {x}}.", call = call)
  }
  invisible(x)
}

check_environment <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_typeof(x, "environment", arg = arg, call = call)
}

# lists & names ---------------------------------------------------------------------------------------------------

check_list <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_typeof(x, "list", arg = arg, call = call)
}

#' @importFrom rlang is_named
check_named <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::is_named(x)) {
    check_abort("{.arg {arg}} must be a named list.", call = call)
  }
  invisible(x)
}

check_names <- function(x, req_names, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_named(x, arg = arg, call = call)
  missing_names <- setdiff(req_names, names(x))
  if (length(missing_names) > 0) {
    check_abort("{.arg {arg}} is missing the following required names: {.field {missing_names}}.", call = call)
  }
  invisible(x)
}

check_in_set <- function(x, set, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!x %in% set) {
    check_abort("{.arg {arg}} must be one of {.field {set}}, not {.val {x}}.", call = call)
  }
  invisible(x)
}

# shiny -----------------------------------------------------------------------------------------------------------

check_shiny_session <- function(x = shiny::getDefaultReactiveDomain(), arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (is.null(x)) {
    calling_function <- as.character(sys.call(-1)[[1]])
    check_abort(
      c(
        "The function {.fn {calling_function}} requires an active shiny session object.",
        "i" = "Make sure you're calling this function from within a reactive context (i.e. observer, reactive, or event handler).",
        "i" = "This function cannot be called during app initialization or outside reactive contexts."
      ),
      call = call
    )
  }
  invisible(x)
}

check_shiny_app <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "shiny.appobj", arg = arg, call = call)
}

check_shiny_tag <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "shiny.tag", arg = arg, call = call)
}

check_shiny_taglist <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "shiny.tag.list", arg = arg, call = call)
}

check_shiny_reactive <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits_all(x, c("reactiveExpr", "reactive", "function"), arg = arg, call = call)
}

check_shiny_request <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_environment(x, arg = arg, call = call)
  check_names(x, c("REQUEST_METHOD", "PATH_INFO", "rook.input"), arg = arg, call = call)
  check_in_set(x$REQUEST_METHOD, c("GET", "POST", "PUT", "DELETE", "PATCH", "HEAD", "OPTIONS"), arg = arg, call = call)
  invisible(x)
}

check_shiny_response <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "httpResponse", arg = arg, call = call)
  check_names(x, c("status", "content_type", "content", "headers"), arg = arg, call = call)
  invisible(x)
}


# bslib -----------------------------------------------------------------------------------------------------------

check_bslib_page <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_shiny_taglist(x, arg = arg, call = call)
  check_inherits(x, "bslib_page", arg = arg, call = call)
}

# httr2 -----------------------------------------------------------------------------------------------------------

check_request <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "httr2_request", arg = arg, call = call)
}

check_response <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  check_inherits(x, "httr2_response", arg = arg, call = call)
}
