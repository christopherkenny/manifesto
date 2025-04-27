#' Install packages from a rproject.toml manifest
#'
#' @param path Path to the `rproject.toml` file. Defaults to "rproject.toml" in the current directory.
#' @param groups Optional character vector of dependency groups to include (e.g., "dev", "workshop").
#'
#' @return Invisibly returns a character vector of package references that were installed.
#' @export
#'
#' @examples
#' # TODO
install_manifest <- function(path = 'rproject.toml', groups = NULL) {
  pkg_refs <- parse_manifest(path = path, groups = groups)

  if (length(pkg_refs) == 0) {
    cli::cli_alert_danger('No packages to install.')
    return(invisible(NULL))
  }

  cli::cli_h2('Installing {length(pkg_refs)} packages')
  pak::pkg_install(pkg_refs)

  invisible(pkg_refs)
}
