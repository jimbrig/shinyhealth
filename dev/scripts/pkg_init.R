
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

  usethis::use_readme_md()

  usethis::use_git()
  usethis::use_github()
  usethis::use_github_links()

  usethis::use_directory(".github", ignore = TRUE)
  usethis::use_git_ignore(c("*.html"), ".github")
  usethis::use_github_file(repo_spec = "noclocks/.github", path = ".github/dependabot.yml", save_as = ".github/dependabot.yml")

  file.create("CHANGELOG.md")
  usethis::use_build_ignore("CHANGELOG.md")
  usethis::use_github_action(url = "https://github.com/noclocks/.github/blob/main/.github/workflows/changelog.yml")

  # usethis::use_github_actions_badge(name = "changelog") <- makes too many assumptions
  usethis::use_badge(badge_name = "Automate Changelog", href = "https://github.com/jimbrig/shinyhealth/actions/workflows/changelog.yml", src = "https://github.com/jimbrig/shinyhealth/actions/workflows/changelog.yml/badge.svg")

}

if (FALSE) {
  usethis::use_directory("dev", ignore = TRUE)
  c("scripts", "R", "docs", "config") |> purrr::walk(~dir.create(file.path("dev", .x), showWarnings = FALSE))
  file.create("dev/README.md")
  attachment::att_amend_desc(use.config = TRUE, update.config = TRUE, path.c = "dev/config/attachment.config.yml")
  file.create("AGENTS.md")
  usethis::use_build_ignore("AGENTS.md")
  usethis::use_directory(".cursor", ignore = TRUE)
  usethis::use_git_ignore(c("mcp.env"), ".cursor")
  usethis::use_directory(".vscode", ignore = TRUE)

}


