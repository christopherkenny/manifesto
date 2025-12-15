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
    path, include_base = FALSE, min_version = c('installed', '*'),
    r_version = current_r_version()) {
  min_version <- match.arg(min_version)

  if (missing(path)) {
    path <- tempfile(fileext = '.toml')
  }

  ip <- utils::installed.packages(fields = c('Package', 'Version', 'Priority'))

  pkg_info <- lapply(seq_len(nrow(ip)), function(i) {
    list(
      name = ip[i, 'Package'],
      version = if (min_version == 'installed') ip[i, 'Version'] else '*'
    )
  })

  if (!include_base) {
    base_pkgs <- rownames(utils::installed.packages(priority = 'base'))
    pkg_info <- Filter(function(x) !(x$name %in% base_pkgs), pkg_info)
  }

  deps <- create_dependency_list(pkg_info)

  manifest_create(
    path = path,
    dependencies = deps,
    r_version = r_version
  )

  invisible(path)
}
