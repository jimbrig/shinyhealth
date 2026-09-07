# NA

## Updating Documentation, `DESCRIPTION`, and `NAMESPACE`

To document (`roxygenize`) and update the package’s DESCRIPTION’s
Imports and Suggests etc. as well as the `NAMESPACE` using a declarative
config file from `dev/config/attachment.config.yml`, run the following:

``` r

attachment::att_amend_desc(use.config = TRUE, update.config = TRUE, path.c = "dev/config/attachment.config.yml")
```

or if not in an R session then,

``` powershell
# from root package folder
RScript -e 'attachment::att_amend_desc(use.config = TRUE, update.config = TRUE, path.c = "dev/config/attachment.config.yml")'
```

## `inst/` Folder Practices

NOTE: corresponds directly with internal developer friendly
`pkg_sys_*()` utilities in the `R/utils_pkg.R` script’s section. If
folders change and accessors are warranted then add one for the use
case, i.e. `pkg_sys_config("config.yml")`, `pkg_sys_shiny("testapp")`,
etc.

Opinionated standardized folders for specific use cases (use as needed
only):

``` plaintext
inst/
  WORDLIST
  # ...
  config/
    config.yml  # standard config R package default: based config file
  extdata/
    <example data to include>
  shiny/
    <note however, that if the package has a primary purpose around shiny app(s) then it is likely best to keep that as functions in the package with a single run_app() or related entrypoint to call downstream app_ui()/server(), and mod_<name> shiny modules across the app(s), etc. or both>
    <standard for including shiny apps in packages similar to plumber2 apis, etc.>
    <appname>/
      app.R  # Depending on the use case for an app, it could include additional supporting files or even a Dockerfile as well
  www/
    <specifically for being used to set as a shiny resource path on package load/attach>
    <would include folders like scripts/, styles/, images/, etc.>
  plumber2/
    <for included plumber2 api definitions bundled with the package (same as with shiny above)>
    <api_name>/
      plumber2.R
      server.R
      openapi.yml
      # etc.
  targets/
    <for included targets pipeline definitions bundled with the package (same as with shiny above)>
    <pipeline_name>/
      targets.R
      targets.yaml
      # etc.
  htmlwidgets/
    <for custom htmlwidgets only>
    <typically would correspond with either an included srcjs/srcts package root or CDN URLs>
  examples/
    <debatable - examples should typically go along the code, or in a build ignored root examples/ folder that is referenced by roxygen2 via `#' @example examples/ex_<name>.R` if you want to manage the code better as real code with IDE support etc.>
  httptest2/
    readact.R # specifically for when using httptest2 to setup mocking when sending httr2 request in a customizable manner (does more than just redact if you want it to)
  schemas/
    <json or related schemas for validation purposes>
    <could potentially represent SQL schemas if being used also>
    *.schema.json
    *<schema>.<table>.sql
    *.schema.xsd
  docs/
    <docs to include separately from installed root docs/ - i.e. custom HTML or markdown that is still just "docs"
    <i.e. to launch a local pkgdown or help page for example from an installed package>
  reports/quarto/**
  templates/**
  # etc.
```
