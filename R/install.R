#' Install packages from a manifesto manifest
#'
#' @param path Path to the `rproject.toml` file. Defaults to "rproject.toml" in the current directory.
#' @param groups Optional character vector of dependency groups to include (e.g., "dev", "workshop").
#' @param dry_run If `TRUE`, show what would be installed but do not install anything.
#'
#' @return Invisibly returns a character vector of package references that were installed.
#' @export
#'
#' @examples
#' install_manifest(
#'   path = system.file(package = 'manifesto', 'minimal.toml'),
#'   dry_run = TRUE
#' )
install_manifest <- function(path = 'rproject.toml', groups = NULL, dry_run = FALSE) {
  validate_manifest(path = path, groups = groups)

  refs <- parse_manifest(path = path, groups = groups)

  if (length(refs) == 0) {
    cli::cli_alert_danger('No packages to install.')
    return(invisible(character()))
  }

  if (dry_run) {
    cli::cli_h2('Dry run: would install the following {length(refs)} packages')
    cli::cli_ul(refs)
    return(invisible(refs))
  }

  cli::cli_h2('Installing {length(refs)} packages')
  pak::pkg_install(refs)

  invisible(refs)
}
