#' Generate a TOML manifest from a renv lockfile
#'
#' Reads a `{renv}` lockfile (JSON format) and converts it to a `manifesto`-style
#' TOML manifest. Extracts package versions and the R environment version.
#'
#' @param lockfile Path to a `renv.lock` JSON file. Defaults to `"renv.lock"`.
#' @param path Optional path to write the TOML manifest. Defaults to a temporary `.toml` file.
#'
#' @return Path to the generated TOML file (invisibly).
#' @export
#'
#' @examples
#' path <- manifest_from_renv(system.file(package = 'manifesto', 'renv.lock'))
manifest_from_renv <- function(lockfile = 'renv.lock', path) {
  if (!file.exists(lockfile)) {
    cli::cli_abort('File {.path {lockfile}} does not exist.')
  }

  json <- jsonlite::read_json(lockfile, simplifyVector = TRUE)

  if (is.null(json$Packages)) {
    cli::cli_abort('No packages found in {.path {lockfile}}.')
  }

  deps <- lapply(json$Packages, function(pkg) {
    list(version = pkg$Version)
  })

  names(deps) <- vapply(json$Packages, function(pkg) pkg$Package, character(1))

  r_version <- json$R$Version %||% current_r_version()

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
