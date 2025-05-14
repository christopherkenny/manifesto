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

  pkg_refs <- vapply(seq_len(nrow(deps_df)), function(i) {
    pkg <- deps_df$package[i]
    ver <- deps_df$version[i]
    source <- deps_df$source[i]
    repo <- deps_df$repo[i]
    ref <- deps_df$ref[i]

    if (source %in% c('CRAN', 'bioc')) {
      if (!is.na(ver)) {
        ref_string <- paste0(pkg, '@', ver)
      } else {
        ref_string <- pkg
      }
    } else if (source %in% c('github', 'gitlab')) {
      if (!is.na(ref)) {
        ref_string <- paste0(repo, '@', ref)
      } else {
        ref_string <- repo
      }
    } else if (source == 'git') {
      if (!is.na(ref)) {
        ref_string <- paste0('git::', repo, '@', ref)
      } else {
        ref_string <- paste0('git::', repo)
      }
    } else if (source == 'url') {
      ref_string <- paste0('url::', repo)
    } else if (source == 'local') {
      ref_string <- paste0('local::', repo)
    } else {
      cli::cli_abort('Unsupported source {.val {source}} for package {.strong {pkg}}.')
    }

    ref_string
  }, FUN.VALUE = character(1))

  if (dry_run) {
    cli::cli_h2('Dry Run: Would install the following {length(pkg_refs)} packages')
    cli::cli_ul(pkg_refs)
    return(invisible(pkg_refs))
  }

  cli::cli_h2('Installing {length(pkg_refs)} packages')
  pak::pkg_install(pkg_refs)

  invisible(pkg_refs)
}
