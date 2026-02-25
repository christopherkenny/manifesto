#' Validate a manifesto manifest file
#'
#' @param path Path to the `rproject.toml` file.
#' @param groups Optional character vector of dependency groups to include.
#'
#' @return Invisibly returns `TRUE` if the manifest is valid; otherwise, stops with an error.
#' @export
#'
#' @examples
#' manifest_validate(path = system.file(package = 'manifesto', 'minimal.toml'))
manifest_validate <- function(path = 'rproject.toml', groups = NULL) {
  if (!file.exists(path)) {
    cli::cli_abort('The file {.file {path}} does not exist.')
  }

  manifest <- tomledit::read_toml(path) |>
    tomledit::from_toml()

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

  # ---- Required section checks ----
  if (is.null(manifest$project$name)) {
    cli::cli_abort('Missing {.field [project].name} field in the manifest.')
  }
  if (is.null(manifest$project$version)) {
    cli::cli_abort('Missing {.field [project].version} field in the manifest.')
  }
  if (is.null(manifest$environment$r_version)) {
    cli::cli_abort('Missing {.field [environment].r_version} field in the manifest.')
  }

  # ---- Dependency validation ----
  if ('all-dependencies' %in% names(manifest)) {
    cli::cli_warn(c(
      x = 'Section {.field [all-dependencies]} is reserved and should not be used.',
      i = 'Use alternative group names like {.field dev-dependencies} instead.'
    ))
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

  invisible(TRUE)
}

# Helper function to validate a single dependency entry
validate_entry <- function(pkg, entry) {
  if (is.character(entry)) {
    return(invisible())
  }

  source <- entry$source %||% 'CRAN'
  version <- entry$version %||% NA_character_
  repo <- entry$repo %||% NA_character_
  ref <- entry$ref %||% NA_character_
  url <- entry$url %||% NA_character_
  path <- entry$path %||% NA_character_

  allowed_sources <- c('CRAN', 'bioc', 'github', 'gitlab', 'git', 'url', 'local')

  if (!source %in% allowed_sources) {
    cli::cli_abort('Unsupported source {.val {source}} for package {.strong {pkg}}.')
  }

  if (source %in% c('github', 'gitlab') && is.na(repo)) {
    cli::cli_abort('Package {.strong {pkg}} has source = {source} but no repo field.')
  }
  if (source == 'git' && is.na(repo)) {
    cli::cli_warn('Package {.strong {pkg}} from {.val git} is missing a {.field repo} field.')
  }
  if (source == 'url' && is.na(url)) {
    cli::cli_warn('Package {.strong {pkg}} from {.val url} is missing a {.field url} field.')
  }
  if (source == 'local' && is.na(path)) {
    cli::cli_warn('Package {.strong {pkg}} from {.val local} is missing a {.field path} field.')
  }

  valid_version_pattern <- '^([><=!~]+\\s*)?\\d+(?:\\.\\d+)*(?:-[0-9]+(?:\\.[0-9]+)*)?$'
  if (!is.na(version) && !grepl(valid_version_pattern, version)) {
    cli::cli_warn('Version constraint for package {.strong {pkg}} looks unusual: {.val {version}}')
  }
}
