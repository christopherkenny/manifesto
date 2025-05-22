#' Create a minimal TOML manifest file
#'
#' This creates a minimal TOML file with a `[manifesto]`, `[project]`,
#' `[environment]`, and empty `[dependencies]` section.
#'
#' @param path File path to write to. If missing, a temporary file will be used.
#' @param project_name Optional project name. Defaults to `Project`.
#' @param project_version Optional project version. Defaults to `0.0.1`.
#' @param manifest_version Optional `manifesto` version. Defaults to the current
#' package version.
#' @param r_version Optional R version settings. Defaults to `'*'`.
#' @param ... Additional named arguments to add to the manifest. These will be
#' added to the top-level of the TOML file.
#'
#' @return Invisibly returns the written path.
#' @export
#'
#' @examples
#' path <- manifest_create(
#'   dependencies = list(dplyr = '>= 1.0.0'),
#'   'suggests-dependencies' = list(testthat = '>= 3.0.0')
#' )
manifest_create <- function(path,
                            project_name = 'Project',
                            project_version = '0.0.1',
                            manifesto_version = manifest_version(),
                            r_version = '*',
                            ...) {
  if (missing(path)) {
    path <- tempfile(fileext = '.toml')
  }

  manifest <- list(
    manifesto = list(version = manifesto_version),
    project = list(
      name = project_name,
      version = project_version
    ),
    environment = list(
      r_version = r_version
    ),
    dependencies = list()
  )

  extras <- list(...)
  extras <- extras[!vapply(names(extras), is.null, logical(1))]

  if (any(names(extras) == '' | is.null(names(extras)))) {
    cli::cli_abort('All additional arguments to `manifest_create()` must be named.')
  }

  for (name in names(extras)) {
    manifest[[name]] <- extras[[name]]
  }

  toml <- tomledit::as_toml(manifest)
  tomledit::write_toml(toml, path)

  manifest_validate(path)

  invisible(path)
}
