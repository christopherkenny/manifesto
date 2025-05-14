#' Validate the rproject.toml manifest file
#'
#' @param path Path to the `rproject.toml` file.
#' @param groups Optional character vector of dependency groups to include.
#'
#' @return Invisibly returns `TRUE` if the manifest is valid; otherwise, stops with an error.
#' @export
#'
#' @examples
#' # TODO validate the minimal file included
validate_manifest <- function(path = 'rproject.toml', groups = NULL) {
  if (!file.exists(path)) {
    cli::cli_abort('The file {.file {path}} does not exist.')
  }

  manifest <- tomledit::read_toml(path)
  cli::cli_h2('Validating manifest at {path}')

  # ---- Manifest version check ----
  expected_major <- '0'
  if (is.null(manifest$manifesto$version)) {
    cli::cli_abort('Missing {.field [manifesto].version} field in the manifest.')
  }

  version_string <- manifest$manifesto$version
  if (!grepl('^\\d+\\.\\d+\\.\\d+$', version_string)) {
    cli::cli_abort('Invalid manifesto version format: {.val {version_string}}')
  }

  manifest_major <- strsplit(version_string, '\\.')[[1]][1]
  if (manifest_major != expected_major) {
    cli::cli_abort(c(
      'Incompatible manifest version.',
      'x' = 'This version of the {.pkg manifesto} package supports major version {expected_major}.',
      'v' = 'The manifest declares version {version_string}.'
    ))
  }

  # ---- Dependency validation ----
  allowed_sources <- c('CRAN', 'bioc', 'github', 'gitlab', 'git', 'url')

  # Helper function to validate a single dependency entry
  validate_entry <- function(pkg, entry) {
    if (is.character(entry)) {
      # Simple version constraint
      if (!grepl('^(>=|<=|==|>|<)?\\s*\\d+(\\.\\d+)*$', entry)) {
        cli::cli_abort('Invalid version constraint for package {.strong {pkg}}: {.val {entry}}')
      }
    } else if (is.list(entry)) {
      source <- entry$source %||% 'CRAN'
      version <- entry$version
      repo <- entry$repo
      ref <- entry$ref

      if (!(source %in% allowed_sources)) {
        cli::cli_abort('Unsupported source {.val {source}} for package {.strong {pkg}}.')
      }

      if (!is.null(version) && !grepl('^(>=|<=|==|>|<)?\\s*\\d+(\\.\\d+)*$', version)) {
        cli::cli_abort('Invalid version constraint for package {.strong {pkg}}: {.val {version}}')
      }

      if (source == 'github' && is.null(repo)) {
        cli::cli_abort("Missing 'repo' field for GitHub package {.strong {pkg}}.")
      }

      if (source %in% c('gitlab', 'git', 'url') && is.null(repo)) {
        cli::cli_abort("Missing 'repo' field for {.val {source}} package {.strong {pkg}}.")
      }
    } else {
      cli::cli_abort('Invalid entry format for package {.strong {pkg}}.')
    }
  }

  # Collect and validate dependencies
  sections <- c('dependencies', paste0(groups, '-dependencies'))
  for (section in sections) {
    deps <- manifest[[section]]
    if (is.null(deps)) next

    for (pkg in names(deps)) {
      validate_entry(pkg, deps[[pkg]])
    }
  }

  cli::cli_alert_success('Manifest validation passed.')
  invisible(TRUE)
}
