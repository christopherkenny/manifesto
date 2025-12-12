#' Check if a string is a valid R package name
#'
#' A valid package name must start with a letter, end with a letter or number,
#' and contain only letters, numbers, or periods.
#'
#' @param x A character vector of package names.
#'
#' @return A logical vector.
#' @noRd
#'
#' @examples
#' is_valid_package_name('dplyr')
#' is_valid_package_name('dplyr-2')
#' is_valid_package_name('d.')
is_valid_package_name <- function(x) {
  grepl('^[A-Za-z][A-Za-z0-9.]*[A-Za-z0-9]$', x)
}

#' Create a dependency list from package information
#
#' @param pkg_info A list of package information, where each element is a list
#' with `name` and `version` components.
#
#' @return A named list of dependencies.
#' @noRd
create_dependency_list <- function(pkg_info) {
  stats::setNames(
    lapply(pkg_info, function(pkg) list(version = pkg$version)),
    vapply(pkg_info, function(pkg) pkg$name, character(1))
  )
}

#' convert greater than or equals to into either:
#' 1. the current installed version, if that version satisfies the requirement
#' 2. the CRAN latest version, if the current installed version does not satisfy the requirement
#' 3. the minimum required version, if neither the installed nor the CRAN version satisfy the requirement
#'
#' @param pkgs a character vector of package names, potentially with versions
#'
#' @noRd
negotiate_ge <- function(pkgs) {
  installed <- utils::installed.packages()
  cran_db <- tools::CRAN_package_db()

  # Only process packages with >= requirement
  has_ge <- grepl('>=', pkgs, fixed = TRUE)

  # Return non->= packages unchanged
  result <- pkgs

  if (!any(has_ge)) {
    return(result)
  }

  # Process >= packages
  ge_pkgs <- pkgs[has_ge]

  for (i in seq_along(ge_pkgs)) {
    parts <- strsplit(ge_pkgs[i], '>=')[[1]]
    pkg_name <- trimws(parts[1])
    min_version <- trimws(parts[2])

    # Current installed version
    if (pkg_name %in% rownames(installed)) {
      inst_version <- installed[pkg_name, 'Version']
      if (utils::compareVersion(inst_version, min_version) >= 0) {
        result[has_ge][i] <- paste0(pkg_name, inst_version)
        next
      }
    }

    # CRAN latest version
    cran_version <- cran_db$Version[cran_db$Package == pkg_name]
    if (length(cran_version) > 0) {
      cran_version <- cran_version[1]
      if (utils::compareVersion(cran_version, min_version) >= 0) {
        result[has_ge][i] <- paste0(pkg_name, cran_version)
        next
      }
    }

    # Minimum required version
    result[has_ge][i] <- paste0(pkg_name, min_version)
  }
  result
}
