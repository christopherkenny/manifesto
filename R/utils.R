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
