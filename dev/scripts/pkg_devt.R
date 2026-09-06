
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
    "aaa",
    "zzz",
    "add_healthcheck",
    "utils_pkg",
    "utils_checks",
    "shinyhealth-conditions"
  ) |>
    purrr::walk(usethis::use_r, open = FALSE)
}

# tests -------------------------------------------------------------------

if (FALSE) {
  usethis::use_testthat()
  usethis::use_test(name = "add_healthcheck", open = FALSE)
}

