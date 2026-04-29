#' Generate a TOML manifest from installed packages
#'
#' Captures all packages installed on `.libPaths()` and generates
#' a `manifesto`-style TOML manifest. Package versions can either reflect
#' their installed versions, or use a wildcard (`*`) to accept any.
#'
#' Base packages are excluded by default to minimize boilerplate.
#'
#' @param path Optional path to write the manifest. If missing, a temporary `.toml` file is created.
#' @param include_base Logical. Whether to include base packages. Defaults to FALSE.
#' @param min_version Whether to require exact installed versions (`'installed'`, default)
#'   or allow any version via a wildcard (`'*'`).
#' @param r_version Optional R version settings. Defaults to `current_r_version()`.
#'
#' @return Path to the generated TOML file (invisibly).
#' @export
#'
#' @examples
#' path <- manifest_from_installed()
manifest_from_installed <- function(
  path,
  include_base = FALSE,
  min_version = c('installed', '*'),
  r_version = current_r_version()
) {
  min_version <- match.arg(min_version)

  if (missing(path)) {
    path <- tempfile(fileext = '.toml')
  }

  pkg_dirs <- unique(unlist(lapply(.libPaths(), function(lib) {
    dirs <- list.dirs(lib, recursive = FALSE, full.names = FALSE)
    dirs[is_valid_package_name(dirs)]
  })))

  pkg_info <- lapply(pkg_dirs, function(pkg) {
    desc <- tryCatch(
      utils::packageDescription(
        pkg,
        fields = c('Package', 'Version', 'Priority')
      ),
      error = function(e) NULL
    )
    if (is.null(desc) || isTRUE(is.na(desc))) {
      return(NULL)
    }
    list(
      name = desc$Package,
      version = if (min_version == 'installed') desc$Version else '*',
      priority = desc$Priority
    )
  })

  pkg_info <- Filter(Negate(is.null), pkg_info)

  if (!include_base) {
    pkg_info <- Filter(function(x) !isTRUE(x$priority == 'base'), pkg_info)
  }

  deps <- create_dependency_list(pkg_info)

  manifest_create(
    path = path,
    dependencies = deps,
    r_version = r_version
  )

  invisible(path)
}
