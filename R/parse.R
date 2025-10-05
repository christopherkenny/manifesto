#' Parse a manifesto manifest file
#'
#' By default, `groups = NULL`, which will only install core dependencies.
#' If you want to include all optional groups, set `groups = 'all'`.
#'
#' @param path Path to the `rproject.toml` file.
#' @param groups Optional character vector of dependency groups to include.
#'
#' @return A character vector of resolved package references.
#' @export
#'
#' @examples
#' manifest_parse(path = system.file(package = 'manifesto', 'minimal.toml'))
manifest_parse <- function(path = 'rproject.toml', groups = NULL) {
  if (!file.exists(path)) {
    cli::cli_abort('The file {.file {path}} does not exist.')
  }

  manifest <- tomledit::read_toml(path) |>
    tomledit::from_toml()

  # Always include core dependencies
  all_refs <- collect_deps(manifest, section = 'dependencies')

  # Include any optional groups
  if (!is.null(groups)) {
    if (length(groups) == 1 && groups == 'all') {
      groups <- manifest_all_groups(path)
    }

    for (group in groups) {
      section <- paste0(group, '-dependencies')

      if (!is.null(manifest[[section]])) {
        # cli::cli_alert_info('Including {.strong {group}} group')
        group_refs <- collect_deps(manifest, section)
        group_refs <- group_refs[setdiff(names(group_refs), names(all_refs))]
        all_refs <- c(all_refs, group_refs)
      } else {
        cli::cli_warn('Group {.strong {group}} not found in the manifest.')
      }
    }
  }

  unname(all_refs)
}

collect_deps <- function(manifest, section) {
  entries <- manifest[[section]]
  if (is.null(entries)) {
    return(list())
  }

  deps <- list()

  for (pkg in names(entries)) {
    entry <- entries[[pkg]]

    if (is.character(entry)) {
      deps[[pkg]] <- paste0(pkg, '@', entry)
    } else if (is.list(entry)) {
      source <- entry$source %||% 'CRAN'
      version <- entry$version
      repo <- entry$repo
      url <- entry$url
      ref <- entry$ref
      path <- entry$path

      if (source %in% c('CRAN', 'bioc')) {
        if (!is.null(version)) {
          deps[[pkg]] <- paste0(pkg, '@', version)
        } else {
          deps[[pkg]] <- pkg
        }
      } else if (source %in% c('github', 'gitlab')) {
        if (is.null(repo)) {
          cli::cli_abort('Package {.strong {pkg}} has source = {source} but no repo field.')
        }

        if (!is.null(ref)) {
          deps[[pkg]] <- paste0(repo, '@', ref)
        } else {
          deps[[pkg]] <- repo
        }
      } else if (source == 'git') {
        if (is.null(repo)) {
          cli::cli_abort('Package {.strong {pkg}} has source = git but no repo (URL) specified.')
        }

        ref_string <- paste0('git::', repo)
        if (!is.null(ref)) {
          ref_string <- paste0(ref_string, '@', ref)
        }

        deps[[pkg]] <- ref_string
      } else if (source == 'url') {
        if (is.null(url)) {
          cli::cli_abort('Package {.strong {pkg}} has source = url but no url field specified.')
        }

        deps[[pkg]] <- paste0('url::', url)
      } else if (source == 'local') {
        if (is.null(path)) {
          cli::cli_abort('Package {.strong {pkg}} has source = local but no repo (path) specified.')
        }

        deps[[pkg]] <- paste0('local::', path)
      } else {
        cli::cli_abort('Unsupported source {.val {source}} for package {.strong {pkg}}.')
      }
    } else {
      cli::cli_warn('Skipping invalid entry for package {.strong {pkg}}.')
    }
  }

  deps <- deps |>
    gsub(pattern = '\\s+', replacement = '', x = _) |>
    trimws() |>
    gsub(pattern = '@\\*$', replacement = '', x = _)

  names(deps) <- names(entries)
  deps
}

#' Return all defined optional dependency groups in a manifest file
#'
#' @param path Path to the `rproject.toml` file.
#'
#' @return A character vector of group names (without "-dependencies")
#' @export
#'
#' @examples
#' manifest_all_groups(path = system.file(package = 'manifesto', 'minimal.toml'))
manifest_all_groups <- function(path = 'rproject.toml') {
  manifest <- tomledit::read_toml(path) |>
    tomledit::from_toml()

  section_names <- names(manifest)

  if ('all-dependencies' %in% section_names) {
    cli::cli_warn(c(
      x = 'Section {.field [all-dependencies]} is reserved and should not be used.',
      i = 'Use other group names like {.field dev-dependencies} instead.'
    ))
  }

  pattern <- '^(.*)-dependencies$'
  groups <- grep(pattern, section_names, value = TRUE)

  sub(pattern, '\\1', groups)
}
