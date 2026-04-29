#' Check for system dependencies
#'
#' This function checks for the presence of system dependencies listed in the
#' `[system-dependencies]` section of the manifest file.
#'
#' @param path Path to the `rproject.toml` file.
#' @return A `data.frame` reporting the system dependency, and its status.
#' @export
#'
#' @examples
#' path <- manifest_create(`system-dependencies` = list(git = '*'))
#' manifest_check_system(path)
manifest_check_system <- function(path = 'rproject.toml') {
  manifest <- tomledit::read_toml(path) |>
    tomledit::from_toml()

  sys_deps <- manifest$`system-dependencies`

  if (is.null(sys_deps)) {
    cli::cli_alert_info('No system dependencies listed in the manifest.')
    return(invisible(data.frame()))
  }

  results <- vapply(
    names(sys_deps),
    function(dep) {
      status <- if (Sys.which(dep) != '') {
        'OK'
      } else {
        'MISSING'
      }
      c(dep, status)
    },
    character(2)
  )

  data.frame(
    dependency = results[1, ],
    status = results[2, ]
  )
}
