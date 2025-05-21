#' Get the current R version
#'
#' The version is returned as a string in the format `"major.minor.patch"` (e.g., `"4.4.0"`),
#' using components from `R.version`.
#'
#' @return A character string representing the full R version.
#' @export
#'
#' @examples
#' current_r_version()
current_r_version <- function() {
  paste0(R.version$major, '.', R.version$minor)
}
