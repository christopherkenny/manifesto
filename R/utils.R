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
