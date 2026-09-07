
#  ------------------------------------------------------------------------
#
# Title : Package Development Script
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------


# functions ---------------------------------------------------------------

if (FALSE) {
  c(
    # aaa & zzz
    "aaa",
    "zzz",
    # package core systems
    "shinyhealth-conditions",
    # "shinyhealth-options",
    # "shinyhealth-config",

    # "modules"
    "health_check",
    "health_response",
    # "health_"
    "add_healthcheck",

    # utils
    "utils_pkg",
    "utils_checks",
    "utils_json"


  ) |>
    purrr::walk(usethis::use_r, open = FALSE)
}

# tests -------------------------------------------------------------------

if (FALSE) {
  usethis::use_testthat()
  usethis::use_test(name = "add_healthcheck", open = FALSE)
}

