#' Parse a manifesto rproject.toml manifest file
#'
#' @param path Path to the `rproject.toml` file.
#' @param groups Optional character vector of dependency groups to include.
#'
#' @return A character vector of resolved package references.
#' @export
#'
#' @examples
#' # TODO
parse_manifest <- function(path = 'rproject.toml', groups = NULL) {
  if (!file.exists(path)) {
    cli::cli_abort('The file {.file {path}} does not exist.')
  }

  manifest <- tomledit::read_toml(path)

  cli::cli_h2('Parsing manifest at {path}')

  deps <- list()

  collect_deps <- function(dep_section) {
    if (is.null(manifest[[dep_section]])) {
      return()
    }

    for (pkg in names(manifest[[dep_section]])) {
      entry <- manifest[[dep_section]][[pkg]]

      if (is.character(entry)) {
        deps[[pkg]] <- paste0(pkg, '@', entry)
      } else if (is.list(entry)) {
        source <- entry$source %||% 'CRAN'
        version <- entry$version
        ref <- entry$ref
        repo <- entry$repo

        if (source == 'CRAN' || source == 'bioc') {
          if (!is.null(version)) {
            deps[[pkg]] <- paste0(pkg, '@', version)
          } else {
            deps[[pkg]] <- pkg
          }
        } else if (source == 'github') {
          if (is.null(repo)) {
            cli::cli_abort('Package {.strong {pkg}} has source = github but no repo field.')
          }
          ref_part <- if (!is.null(ref)) paste0('@', ref) else ''
          deps[[pkg]] <- paste0(repo, ref_part)
        } else {
          cli::cli_abort('Unsupported source {.val {source}} for package {.strong {pkg}}.')
        }
      }
    }
  }

  # Always start with base dependencies
  collect_deps('dependencies')

  # Then any requested groups
  if (!is.null(groups)) {
    for (group in groups) {
      group_key <- paste0(group, '-dependencies')
      if (!is.null(manifest[[group_key]])) {
        cli::cli_alert_info('Including {.strong {group}} group')
        collect_deps(group_key)
      } else {
        cli::cli_alert_warning('Group {.strong {group}} not found in the manifest.')
      }
    }
  }

  pkg_refs <- unname(deps)

  cli::cli_alert_success('Parsed {length(pkg_refs)} package references')
  pkg_refs
}
