
#  ------------------------------------------------------------------------
#
# Title : Package Documentation
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

attachment::att_amend_desc(use.config = TRUE, update.config = TRUE, path.c = "dev/config/attachment.config.yml")

# readme ------------------------------------------------------------------

if (FALSE) {

}

# vignettes ---------------------------------------------------------------

if (FALSE) {
  usethis::use_vignette("shinyhealth", title = "Getting Started")
}


# pkgdown -----------------------------------------------------------------

if (FALSE) {
  usethis::use_pkgdown_github_pages()
  file.rename(".github/workflows/pkgdown.yaml", ".github/workflows/pkgdown.yml")
  usethis::use_badge("pkgdown", "https://github.com/jimbrig/shinyhealth/actions/workflows/pkgdown.yml", "https://github.com/jimbrig/shinyhealth/actions/workflows/pkgdown.yml/badge.svg")

  usethis::use_directory("pkgdown", ignore = TRUE)
  fs::file_move("_pkgdown.yml", "pkgdown/_pkgdown.yml")
  pkgdown::build_favicons()
}

# badges ------------------------------------------------------------------

if (FALSE) {
  usethis::use_badge("DeepWiki", "https://deepwiki.com/jimbrig/shinyhealth", "https://deepwiki.com/badge.svg")
  usethis::use_badge("R Universe Version", "https://jimbrig.r-universe.dev/shinyhealth", "https://jimbrig.r-universe.dev/shinyhealth/badges/version")
}



# experiemental -----------------------------------------------------------

# i'm using this package to experiement with some interesting enhanced forms
# of docs and related:

# pkgnet - may remove, though could be useful for context
if (FALSE) {
  pkgnet::CreatePackageVignette(pkg = getwd(), pkg_reporters = list(pkgnet::DependencyReporter$new(), pkgnet::FunctionReporter$new()), vignette_path = file.path(getwd(), "dev/docs/pkgnet-report.Rmd"))
  rmarkdown::render("dev/docs/pkgnet-report.Rmd")
  browseURL("dev/docs/pkgnet-report.html")
}
# ^ definitely has the right idea - very useful information - bad interface and presentation though
# should circle back on this as something to do myself (pkgdev package)
