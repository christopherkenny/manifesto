#' Peek into a manifest file
#'
#' @param path Path to the `rproject.toml` file. Defaults to "rproject.toml" in the current directory.
#'
#' @return Invisibly returns a list with parsed contents.
#' @export
#'
#' @examples
#' manifest_peek(system.file('complex.toml', package = 'manifesto'))
manifest_peek <- function(path = 'rproject.toml') {
  if (!file.exists(path)) {
    cli::cli_abort('File not found: {.path {path}}')
  }

  manifest <- tomledit::read_toml(path) |>
    tomledit::from_toml()

  required_sections <- c('manifesto', 'project', 'environment')
  missing_sections <- setdiff(required_sections, names(manifest))
  if (length(missing_sections) > 0) {
    cli::cli_warn('Missing expected section(s): {cli::cli_vec(missing_sections, style = "code")}')
  }

  cli::cli_ul()
  if (!is.null(manifest$manifesto$version)) {
    cli::cli_li('Manifesto version: {.val {manifest$manifesto$version}}')
  }

  if (!is.null(manifest$project)) {
    cli::cli_li('Project name: {.val {manifest$project$name}}')
    cli::cli_li('Project version: {.val {manifest$project$version}}')
  }

  if (!is.null(manifest$environment$r_version)) {
    cli::cli_li('Required R version: {.val {manifest$environment$r_version}}')
  }
  cli::cli_end()

  # Collect all dependency groups
  dep_sections <- names(manifest)[grepl('dependencies$', names(manifest))]

  if (length(dep_sections) > 0) {
    cli::cli_text('Dependencies:')
    cli::cli_ul()

    for (section in dep_sections) {
      group <- if (section == 'dependencies') 'default' else sub('-?dependencies$', '', section)
      deps <- manifest[[section]]

      pkg_versions <- purrr::imap_chr(deps, \(entry, pkg) {
        version <- if (is.character(entry) && length(entry) == 1) {
          entry
        } else if (!is.null(entry[['version']])) {
          entry[['version']]
        } else {
          NA_character_
        }

        if (!is.na(version)) {
          cli::format_inline('{.pkg {pkg}} ({.val {version}})')
        } else {
          NA_character_
        }
      })

      pkg_versions <- pkg_versions[!is.na(pkg_versions)]
      if (length(pkg_versions) > 0) {
        cli::cli_li('{.strong {group}}: {paste(pkg_versions, collapse = ", ")}')
      }
    }

    cli::cli_end()
  }

  invisible(manifest)
}
