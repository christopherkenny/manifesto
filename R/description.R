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

  # Required fields
  name <- desc$Package
  version <- desc$Version

  # Parse authors safely, with fallback
  authors <- parse_authors_field(desc$`Authors@R`)

  # Extract R version for [environment]
  r_version <- parse_r_version(desc$Depends)

  # Process dependencies from DESCRIPTION fields
  extras <- list(
    dependencies = parse_dependencies(c(
      filter_dependencies(desc$Depends),
      filter_dependencies(desc$Imports)
    )),
    'suggests-dependencies' = parse_dependencies(desc$Suggests),
    'linkingto-dependencies' = parse_dependencies(desc$LinkingTo),
    'enhances-dependencies' = parse_dependencies(desc$Enhances)
  )

  # Optionally remove empty sections
  if (!include_empty_groups) {
    extras <- Filter(length, extras)
  }

  # Always construct a valid [project] block
  project <- list(name = name, version = version)
  if (length(authors) > 0) {
    project$authors <- authors
  }

  # Add to manifest fields
  extras$project <- project
  extras$environment <- list(r_version = r_version)

  # Create and write manifest
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

filter_dependencies <- function(field) {
  if (is.null(field)) {
    return(NULL)
  }

  entries <- unlist(strsplit(field, ',\\s*'))
  entries[!grepl('^R\\b', entries)]
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
  if (is.null(authors_field)) {
    return(list())
  }

  expr <- tryCatch(parse(text = authors_field)[[1]], error = function(e) NULL)
  if (is.null(expr)) {
    return(list())
  }

  authors <- tryCatch(eval(expr), error = function(e) NULL)
  if (is.null(authors)) {
    return(list())
  }

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

#' Convert a TOML manifest to a DESCRIPTION file
#'
#' Generates a valid DESCRIPTION file from a manifest. Required fields like
#' Title, Description, License, and Authors@R are inserted as TODOs if not present.
#'
#' @param path Path to the TOML manifest file.
#' @param out Path to the DESCRIPTION file to write. Defaults to 'DESCRIPTION'.
#'
#' @return Invisibly returns the path to the written DESCRIPTION file.
#' @export
#'
#' @examples
#' out <- tempfile(pattern = 'DESCRIPTION')
#' manifest_to_description(
#'   path = system.file('minimal.toml', package = 'manifesto'),
#'   out = out
#' )
manifest_to_description <- function(path = 'rproject.toml', out = 'DESCRIPTION') {
  manifest <- tomledit::read_toml(path) |>
    tomledit::from_toml()

  desc <- list()

  # Required base fields with fallback
  desc$Package <- manifest$project$name %||% 'TODOPackage'
  desc$Version <- manifest$project$version %||% '0.0.0.9000'
  desc$Title <- 'TODO Title'
  desc$Description <- 'TODO Description'
  desc$License <- 'TODO License'
  desc$Encoding <- 'UTF-8'

  # Authors block
  if (!is.null(manifest$project$authors)) {
    desc$`Authors@R` <- authors_to_r(manifest$project$authors)
  } else {
    desc$`Authors@R` <- 'person("TODO", "TODO", email = "todo@email.com", role = c("aut", "cre"))'
  }

  # Only R version goes into Depends
  if (!identical(manifest$environment$r_version, '*')) {
    desc$Depends <- paste0('R (', manifest$environment$r_version, ')')
  }

  # [dependencies] → Imports
  if (!is.null(manifest$dependencies)) {
    desc$Imports <- deps_to_field(manifest$dependencies)
  }

  # Optional groups
  optional_sections <- c('suggests-dependencies', 'linkingto-dependencies', 'enhances-dependencies')
  for (section in optional_sections) {
    if (!is.null(manifest[[section]])) {
      field <- switch(section,
        'suggests-dependencies' = 'Suggests',
        'linkingto-dependencies' = 'LinkingTo',
        'enhances-dependencies' = 'Enhances'
      )
      desc[[field]] <- deps_to_field(manifest[[section]])
    }
  }

  # Write DESCRIPTION file
  write.dcf(desc, file = out)
  invisible(out)
}

authors_to_r <- function(authors) {
  if (!is.list(authors)) {
    return(NULL)
  }

  people <- vapply(authors, function(x) {
    name <- x$name %||% 'TODO'
    name_parts <- strsplit(name, '\\s+')[[1]]
    given <- paste(name_parts[-length(name_parts)], collapse = ' ')
    family <- name_parts[length(name_parts)]

    email <- x$email %||% NULL
    roles <- x$roles %||% 'aut'

    person <- sprintf(
      'person(%s, %s%s, role = c(%s))',
      dquote(given),
      dquote(family),
      if (!is.null(email)) paste0(', email = ', dquote(email)) else '',
      paste(dquote(roles), collapse = ', ')
    )

    person
  }, character(1))

  paste0('c(\n  ', paste(people, collapse = ',\n  '), '\n)')
}

deps_to_field <- function(deps) {
  if (!length(deps)) {
    return(NULL)
  }

  entries <- vapply(names(deps), function(pkg) {
    version <- deps[[pkg]]
    if (identical(version, '*')) {
      pkg
    } else {
      sprintf('%s (%s)', pkg, version)
    }
  }, character(1))

  paste(entries, collapse = ',\n    ')
}

dquote <- function(x) {
  sprintf('"%s"', x)
}
