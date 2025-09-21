#' Check if the installed packages match the manifest requirements
#'
#' @param path Path to the TOML manifest file. Defaults to "rproject.toml".
#' @param groups Optional dependency groups to include. Defaults to NULL (core only).
#'
#' @return A `data.frame` reporting installed version, required version, and status.
#' @export
#'
#' @examples
#' manifest_check(system.file(package = 'manifesto', 'minimal.toml'))
manifest_check <- function(path = 'rproject.toml', groups = NULL) {
  manifest_validate(path, groups = groups)
  refs <- manifest_parse(path, groups = groups)

  pkg_names <- sub('@.*$', '', refs)
  required_versions <- ifelse(grepl('@', refs), sub('^.*?@', '', refs), '*')
  installed <- as.data.frame(utils::installed.packages()[, c('Package', 'Version')], stringsAsFactors = FALSE)

  result <- vapply(seq_along(pkg_names), function(i) {
    pkg <- pkg_names[i]
    req <- required_versions[i]
    found <- installed[installed$Package == pkg, 'Version']

    if (length(found) == 0) {
      return(c(NA, 'MISSING'))
    }

    inst <- found[1]

    if (version_satisfies(req, inst)) {
      return(c(inst, 'OK'))
    } else {
      return(c(inst, 'VERSION MISMATCH'))
    }
  }, character(2))

  data.frame(
    package = pkg_names,
    required = required_versions,
    installed = result[1, ],
    status = result[2, ]
  )
}

version_satisfies <- function(required, installed) {
  if (required == '*') {
    return(TRUE)
  }

  # Normalize version separators to dots for consistency
  required <- gsub('-', '.', required)
  installed <- gsub('-', '.', installed)

  # Regex to capture operator and version
  match <- regexec('^([><=!]+)\\s*([0-9][0-9.-]*)', required)
  parts <- regmatches(required, match)[[1]]

  if (length(parts) < 3) {
    return(FALSE) # Return FALSE if format is not 'operator version'
  }

  op <- parts[2]
  ver <- parts[3]

  # Ensure version strings are valid for comparison
  if (!grepl('^[0-9.-]+$', ver) || !grepl('^[0-9.-]+$', installed)) {
    return(FALSE)
  }

  comparison <- utils::compareVersion(installed, ver)

  # Handle cases where versions have different number of components
  if (comparison != 0) {
    ver_parts <- strsplit(ver, '\\.')[[1]]
    installed_parts <- strsplit(installed, '\\.')[[1]]
    min_len <- min(length(ver_parts), length(installed_parts))
    if (all(ver_parts[1:min_len] == installed_parts[1:min_len])) {
      if (length(ver_parts) > min_len && all(ver_parts[(min_len + 1):length(ver_parts)] == '0')) {
        comparison <- 0
      } else if (length(installed_parts) > min_len && all(installed_parts[(min_len + 1):length(installed_parts)] == '0')) {
        comparison <- 0
      }
    }
  }

  # Perform comparison based on operator
  result <- switch(op,
    `==` = comparison == 0,
    `>=` = comparison >= 0,
    `<=` = comparison <= 0,
    `>`  = comparison > 0,
    `<`  = comparison < 0,
    `!=` = comparison != 0,
    FALSE # Default case for unsupported operators
  )

  return(result)
}
