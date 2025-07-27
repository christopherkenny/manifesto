#' Generate a TOML manifest from a `pak` lockfile
#'
#' Reads a `{pak}` lockfile (JSON format) and converts it to a `manifesto`-style
#' TOML manifest. Extracts package versions and the locked R version.
#'
#' @param lockfile Path to a `pkg.lock` JSON file created by `{pak}`.
#' @param path Optional path to write the manifest. Defaults to a temporary `.toml` file.
#' @param r_version Optional R version settings. Defaults to version found in lockfile.
#'
#' @return Path to the generated TOML file (invisibly).
#' @export
#'
#' @examples
#' path <- manifest_from_pak(system.file(package = 'manifesto', 'pkg.lock'))
manifest_from_pak <- function(lockfile = 'pkg.lock', path, r_version) {
  if (!file.exists(lockfile)) {
    cli::cli_abort('File {.path {lockfile}} does not exist.')
  }

  json <- jsonlite::read_json(lockfile, simplifyVector = TRUE)

  if (is.null(json$packages)) {
    cli::cli_abort('No packages found in {.path {lockfile}}.')
  }

  # Filter out invalid package names (which might be captured by pak)
  pkg_df <- json$packages
  pkg_df <- pkg_df[is_valid_package_name(pkg_df$package), , drop = FALSE]

  # create deps
  deps <- pkg_df$version |>
    as.list()
  names(deps) <- pkg_df$package

  if (missing(r_version)) {
    raw_r_version <- json$r_version
    r_version <- sub('^R version ([0-9.]+).*', '\\1', raw_r_version)
    r_version <- r_version %||% current_r_version()
  }

  if (missing(path)) {
    path <- tempfile(fileext = '.toml')
  }

  manifest_create(
    path = path,
    dependencies = deps,
    r_version = r_version
  )

  invisible(path)
}
