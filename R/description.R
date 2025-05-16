#' Generate a TOML manifest from a DESCRIPTION file
#'
#' Parses fields from a DESCRIPTION file and generates a corresponding
#' TOML manifest with `[project]`, `[environment]`, and dependency groups.
#'
#' By default, both `Depends` and `Imports` are mapped to `[dependencies]`.
#' `Suggests`, `LinkingTo`, and `Enhances` are mapped to their own optional groups.
#'
#' @param description Path to the DESCRIPTION file.
#' @param path Optional output file path. Defaults to a temporary `.toml` file.
#' @param include_empty_groups Whether to include empty dependency sections.
#'
#' @return Path to the generated TOML file (invisibly).
#' @export
#'
#' @examples
#' path <- manifest_from_description(system.file(package = 'cli', 'DESCRIPTION'))
manifest_from_description <- function(description = 'DESCRIPTION', path, include_empty_groups = FALSE) {
  desc <- parse_description(description)

  if (missing(path)) {
    path <- tempfile(fileext = '.toml')
  }

  name <- desc$Package
  version <- desc$Version
  authors <- parse_authors_field(desc$`Authors@R`)
  r_version <- parse_r_version(desc$Depends)

  extras <- list(
    'dependencies' = parse_dependencies(c(desc$Depends, desc$Imports)),
    'suggests-dependencies' = parse_dependencies(desc$Suggests),
    'linkingto-dependencies' = parse_dependencies(desc$LinkingTo),
    'enhances-dependencies' = parse_dependencies(desc$Enhances)
  )

  # Optionally remove empty groups
  if (isFALSE(include_empty_groups)) {
    extras <- Filter(length, extras)
  }

  # Always include authors and r_version in their correct slots
  project <- list(name = name, version = version)

  authors <- parse_authors_field(desc$`Authors@R`)
  if (length(authors) > 0) {
    project$authors <- authors
  }

  extras$project <- project

  # Delegate to create_manifest() for writing + validation
  do.call(
    create_manifest,
    c(list(
    path = path,
    name = name,
    version = version,
    r_version = r_version
  ), extras)
  )

}

parse_description <- function(path) {
  if (!file.exists(path)) {
    cli::cli_abort('DESCRIPTION file not found at {.file {path}}.')
  }

  as.list(read.dcf(path)[1, ])
}

parse_dependencies <- function(dep_field) {
  if (is.null(dep_field)) {
    return(list())
  }

  dep_lines <- unlist(strsplit(dep_field, ',\\s*'))

  deps <- list()
  for (entry in dep_lines) {
    parts <- strsplit(entry, '\\s*\\(\\s*|\\s*\\)\\s*')[[1]]
    pkg <- parts[1]
    version <- if (length(parts) > 1) parts[2] else '*'
    deps[[pkg]] <- version
  }

  deps
}

parse_authors_field <- function(authors_field) {
  if (is.null(authors_field)) return(list())

  expr <- tryCatch(parse(text = authors_field)[[1]], error = function(e) NULL)
  if (is.null(expr)) return(list())

  authors <- tryCatch(eval(expr), error = function(e) NULL)
  if (is.null(authors)) return(list())

  if (inherits(authors, 'person')) {
    authors <- as.list(authors)
  }

  out <- lapply(authors, function(p) {
    name_parts <- c(p$given, p$family)
    name_parts <- name_parts[!is.na(name_parts)]
    name <- paste(name_parts, collapse = ' ')
    name <- trimws(name)

    email <- p$email
    email <- email[!is.na(email) & nzchar(email)]
    email <- email[1]

    roles <- p$role
    roles <- roles[!is.na(roles) & nzchar(roles)]

    author <- list(name = name)
    if (!is.null(email) && !is.na(email) && nzchar(email)) {
      author$email <- email
    }
    if (length(roles) > 0) {
      author$roles <- roles
    }

    author
  })

  out
}

parse_r_version <- function(dep_field) {
  if (is.null(dep_field)) {
    return('*')
  }

  lines <- unlist(strsplit(dep_field, ',\\s*'))

  r_line <- grep('^R\\b', lines, value = TRUE)

  if (length(r_line) == 0) {
    return('*')
  }

  match <- regmatches(r_line, regexec('R\\s*\\(\\s*([^)]+)\\s*\\)', r_line))[[1]]
  if (length(match) >= 2) {
    return(match[2])
  }

  '*'
}
