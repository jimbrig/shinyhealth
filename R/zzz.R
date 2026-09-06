
#  ------------------------------------------------------------------------
#
# Title : zzz.R - Package Initialization, onLoad, & onAttach
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

# environment -----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rlang new_environment
.pkg_env <- rlang::new_environment()

# initializers ----------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rlang on_load local_use_cli
rlang::on_load({
  # pkg_env_init()
  # pkg_config_init()
  # pkg_opts_init()
  rlang::local_use_cli()
})

# onLoad ----------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
#' @importFrom rlang run_on_load
.onLoad <- function(libname, pkgname) {
  rlang::run_on_load()
}

# onAttach --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
.onAttach <- function(libname, pkgname) {
  packageStartupMessage(pkg_startup_msg())
}

# onUnload --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
.onUnload <- function(libname) {
  # TODO
}

# onDetach --------------------------------------------------------------------------------------------------------

#' @keywords internal
#' @noRd
.onDetach <- function(libpath) {
  # TODO
}
