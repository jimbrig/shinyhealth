
#  ------------------------------------------------------------------------
#
# Title : Package Utilities
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

# meta ------------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_name <- function() {
  "shinyhealth"
}

#' @keywords internal
#' @noRd
#' @importFrom utils packageVersion
pkg_version <- local({
  version <- NULL
  function() {
    if (is.null(version)) {
      version <<- as.character(utils::packageVersion(pkg_name()))
    }
    version
  }
})

# user agent ------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_user_agent <- function() {
  paste0(pkg_name(), "/", pkg_version())
}

# system file -----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_sys <- function(...) {
  system.file(..., package = pkg_name())
}

#' @keywords internal
#' @noRd
pkg_sys_shiny <- function(...) {
  pkg_sys("shiny", ...)
}

# startup message -------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom crayon bold cyan yellow
pkg_startup_msg <- function() {
  msg_banner <- paste0(crayon::cyan(crayon::bold(pkg_banner())), "\n")
  msg_title <- paste0(crayon::bold(crayon::yellow(pkg_name(), paste0("v", pkg_version()))), "\n")
  msg_desc <- crayon::bold(crayon::yellow("Modern Package for Shiny App Health Checks"))
  invisible(paste0(msg_banner, msg_title, msg_desc))
}

# environment -----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rlang new_environment
pkg_env_init <- function() {
  if (!exists(".pkg_env")) {
    return()
  }
  # package config
  .pkg_env$config <- rlang::new_environment()
  # shiny
  .pkg_env$shiny <- rlang::new_environment()
  # healthchecks
  .pkg_env$health <- rlang::new_environment()

  invisible(TRUE)
}

#' @keywords internal
#' @noRd
#' @importFrom rlang env_get
pkg_env_get <- function(key, default = NULL) {
  rlang::env_get(env = .pkg_env, nm = key, default = default)
}

#' @keywords internal
#' @noRd
#' @importFrom rlang env_poke
pkg_env_set <- function(key, value, create = FALSE) {
  rlang::env_poke(env = .pkg_env, nm = key, value = value, create = create)
}

#' @keywords internal
#' @noRd
#' @importFrom rlang env_cache
pkg_env_cache <- function(key, default) {
  rlang::env_cache(env = .pkg_env, nm = key, default = default)
}

# verbosity -------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_is_verbose <- function() {
  getOption("shinyhealth.verbose", default = "inform") %in% c("inform", "debug")
}

#' @keywords internal
#' @noRd
pkg_is_debug <- function() {
  identical(getOption("shinyhealth.verbose", default = "inform"), "debug")
}

# banner ----------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
pkg_banner <- function() {
  .pkg_banner_str
}

#' @keywords internal
#' @noRd
#' @seealso https://manytools.org/hacker-tools/ascii-banner/
.pkg_banner_str <- r"(
         888      d8b                   888                        888 888    888
         888      Y8P                   888                        888 888    888
         888                            888                        888 888    888
.d8888b  88888b.  888 88888b.  888  888 88888b.   .d88b.   8888b.  888 888888 88888b.
88K      888 "88b 888 888 "88b 888  888 888 "88b d8P  Y8b     "88b 888 888    888 "88b
"Y8888b. 888  888 888 888  888 888  888 888  888 88888888 .d888888 888 888    888  888
     X88 888  888 888 888  888 Y88b 888 888  888 Y8b.     888  888 888 Y88b.  888  888
 88888P' 888  888 888 888  888  "Y88888 888  888  "Y8888  "Y888888 888  "Y888 888  888
                                    888
                               Y8b d88P
                                "Y88P"
)"
