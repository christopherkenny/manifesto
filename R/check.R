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

  match <- regexec('^([><=!]+)\\s*(\\d+[.-]?\\d*[.-]?\\d*)$', required)
  parts <- regmatches(required, match)[[1]]
  if (length(parts) != 3) {
    return(FALSE)
  }

  op <- parts[2]
  ver <- parts[3]

  comparison <- utils::compareVersion(installed, ver)

  switch(op,
    '==' = comparison == 0,
    '>=' = comparison >= 0,
    '<=' = comparison <= 0,
    '>'  = comparison > 0,
    '<'  = comparison < 0,
    '!=' = comparison != 0,
    FALSE
  )
}
