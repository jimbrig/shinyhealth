
#  ------------------------------------------------------------------------
#
# Title : Package Documentation
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

if (FALSE) {
  usethis::use_vignette("shinyhealth", title = "Getting Started")
  pkgnet::CreatePackageVignette()
  usethis::use_pkgdown_github_pages()
  file.rename(".github/workflows/pkgdown.yaml", ".github/workflows/pkgdown.yml")
  usethis::use_badge("pkgdown", "https://github.com/jimbrig/shinyhealth/actions/workflows/pkgdown.yml", "https://github.com/jimbrig/shinyhealth/actions/workflows/pkgdown.yml/badge.svg")
}
