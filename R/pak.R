#' Generate a TOML manifest from a `pak` lockfile
#'
#' Reads a `{pak}` lockfile (JSON format) and converts it to a `manifesto`-style
#' TOML manifest. Extracts package versions and the locked R version.
#'
#' @param lockfile Path to a `pkg.lock` JSON file created by `{pak}`.
#' @param path Optional path to write the manifest. Defaults to a temporary `.toml` file.
#'
#' @return Path to the generated TOML file (invisibly).
#' @export
#'
#' @examples
#' path <- manifest_from_pak(system.file(package = 'manifesto', 'pkg.lock'))
manifest_from_pak <- function(lockfile = 'pkg.lock', path) {
  if (!file.exists(lockfile)) {
    cli::cli_abort('File {.path {lockfile}} does not exist.')
  }

  json <- jsonlite::read_json(lockfile, simplifyVector = TRUE)

  if (is.null(json$packages)) {
    cli::cli_abort('No packages found in {.path {lockfile}}.')
  }

  deps <- json$packages$version |>
    as.list()

  # `deps` must be a named list
  names(deps) <- json$packages$package

  if (missing(path)) {
    path <- tempfile(fileext = '.toml')
  }

  manifest_create(
    path = path,
    dependencies = deps,
    r_version = json$r_version
  )

  invisible(path)
}
