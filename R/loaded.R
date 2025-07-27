#' Generate a TOML manifest from currently loaded packages
#'
#' Captures all currently loaded packages in the R session and generates
#' a `manifesto`-style TOML manifest. Package versions can either reflect
#' their current loaded versions, or use a wildcard (`*`) to accept any.
#'
#' Base packages are excluded by default to minimize boilerplate.
#'
#' @param path Optional path to write the manifest. If missing, a temporary `.toml` file is created.
#' @param include_base Logical. Whether to include base packages. Defaults to FALSE.
#' @param min_version Whether to require exact loaded versions (`'loaded'`, default)
#'   or allow any version via a wildcard (`'*'`).
#' @param r_version Optional R version settings. Defaults to `current_r_version()`
#'
#' @return Path to the generated TOML file (invisibly).
#' @export
#'
#' @examples
#' path <- manifest_from_loaded()
manifest_from_loaded <- function(
    path, include_base = FALSE, min_version = c('loaded', '*'),
    r_version = current_r_version()) {
  min_version <- match.arg(min_version)

  if (missing(path)) {
    path <- tempfile(fileext = '.toml')
  }

  pkgs <- loadedNamespaces()

  pkg_info <- lapply(pkgs, function(pkg) {
    desc <- tryCatch(utils::packageDescription(pkg), error = function(e) NULL)
    if (is.null(desc)) {
      return(NULL)
    }

    list(
      name = desc$Package,
      version = if (min_version == 'loaded') desc$Version else '*'
    )
  })

  pkg_info <- Filter(Negate(is.null), pkg_info)

  if (!include_base) {
    base_pkgs <- rownames(utils::installed.packages(priority = 'base'))
    pkg_info <- Filter(function(x) !(x$name %in% base_pkgs), pkg_info)
  }

  deps <- stats::setNames(
    lapply(pkg_info, function(pkg) list(version = pkg$version)),
    vapply(pkg_info, function(pkg) pkg$name, character(1))
  )

  manifest_create(
    path = path,
    dependencies = deps,
    r_version = current_r_version()
  )

  invisible(path)
}
