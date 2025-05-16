#' Return the current version of the manifesto package
#'
#' @return A character version string.
#' @export
#'
#' @examples
#' manifest_version()
manifest_version <- function() {
  as.character(utils::packageVersion('manifesto'))
}
