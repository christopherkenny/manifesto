#' Create a minimal TOML manifest file
#'
#' This creates a minimal TOML file with a `[manifesto]`, `[project]`,
#' `[environment]`, and empty `[dependencies]` section.
#'
#' @param path File path to write to. If missing, a temporary file will be used.
#' @param name Optional project name. Defaults to `Project`.
#' @param version Optional project version. Defaults to `manifest_version()`.
#' @param r_version Optional R version settings. Defaults to `'*'`.
#'
#' @return Invisibly returns the written path.
#' @export
#'
#' @examples
#' path <- create_manifest(
#'   dependencies = list(dplyr = '>= 1.0.0'),
#'   'suggests-dependencies' = list(testthat = '>= 3.0.0')
#' )
create_manifest <- function(path,
                            name = 'Project',
                            version = manifest_version(),
                            r_version = '*',
                            ...) {
  if (missing(path)) {
    path <- tempfile(fileext = '.toml')
  }

  manifest <- list(
    manifesto = list(version = manifest_version()),
    project = list(
      name = name,
      version = version
    ),
    environment = list(
      r_version = r_version
    ),
    dependencies = list()
  )

  extras <- list(...)
  extras <- extras[!vapply(names(extras), is.null, logical(1))]

  if (any(names(extras) == '' | is.null(names(extras)))) {
    cli::cli_abort('All additional arguments to `create_manifest()` must be named.')
  }

  for (name in names(extras)) {
    manifest[[name]] <- extras[[name]]
  }

  toml <- tomledit::as_toml(manifest)
  tomledit::write_toml(toml, path)

  validate_manifest(path)

  invisible(path)
}
