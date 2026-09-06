
#  ------------------------------------------------------------------------
#
# Title : Package Initialization Script
#    By : Jimmy Briggs
#  Date : 2026-09-06
#
#  ------------------------------------------------------------------------

if (FALSE) {
  usethis::create_package("shinyhealth")
}

if (FALSE) {
  usethis::use_git()
}

if (FALSE) {
  usethis::use_directory("dev", ignore = TRUE)
  c("scripts", "R", "docs", "config") |> purrr::walk(~dir.create(file.path("dev", .x), showWarnings = FALSE))
  file.create("dev/README.md")
  attachment::att_amend_desc(use.config = TRUE, update.config = TRUE, path.c = "dev/config/attachment.config.yml")
  file.create("AGENTS.md")
  usethis::use_build_ignore("AGENTS.md")
  file.create("CHANGELOG.md")
  usethis::use_build_ignore("CHANGELOG.md")
  usethis::use_directory(".cursor", ignore = TRUE)
  usethis::use_git_ignore(c("mcp.env"), ".cursor")
  usethis::use_directory(".vscode", ignore = TRUE)
  usethis::use_directory(".github", ignore = TRUE)
  usethis::use_git_ignore(c("*.html"), ".github")
}
