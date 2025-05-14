#' Install packages from a rproject.toml manifest
#'
#' @param path Path to the `rproject.toml` file. Defaults to "rproject.toml" in the current directory.
#' @param groups Optional character vector of dependency groups to include (e.g., "dev", "workshop").
#' @param dry_run If `TRUE`, show what would be installed but do not install anything.
#'
#' @return Invisibly returns a character vector of package references that were installed.
#' @export
#'
#' @examples
#' # TODO
install_manifest <- function(path = 'rproject.toml', groups = NULL, dry_run = FALSE) {
  validate_manifest(path = path, groups = groups)
  deps_df <- parse_manifest(path = path, groups = groups)

  if (nrow(deps_df) == 0) {
    cli::cli_alert_danger('No packages to install.')
    return(invisible(character()))
  }

  pkg_refs <- purrr::pmap_chr(deps_df, function(package, version, source, repo, ref) {
    if (source %in% c('CRAN', 'bioc')) {
      if (!is.na(version)) paste0(package, '@', version) else package
    } else if (source %in% c('github', 'gitlab')) {
      ref_part <- if (!is.na(ref)) paste0('@', ref) else ''
      paste0(repo, ref_part)
    } else if (source == 'git') {
      ref_part <- if (!is.na(ref)) paste0('@', ref) else ''
      paste0('git::', repo %||% url, ref_part)
    } else if (source == 'url') {
      paste0('url::', repo %||% url)
    } else if (source == 'local') {
      paste0('local::', repo %||% entry$path)
    } else {
      cli::cli_abort('Unsupported source {.val {source}} for package {.strong {package}}.')
    }
  })

  if (dry_run) {
    cli::cli_h2('Dry Run: Would install the following {length(pkg_refs)} packages')
    cli::cli_ul(pkg_refs)
    return(invisible(pkg_refs))
  }

  cli::cli_h2('Installing {length(pkg_refs)} packages')
  pak::pkg_install(pkg_refs)

  invisible(pkg_refs)
}
