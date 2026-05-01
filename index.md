# `manifesto`

`manifesto` provides a lightweight, portable way to declare R project
environments using a simple `rproject.toml` file. It makes setting up
and sharing reproducible R projects faster and more reliable. As it is
lightweight, it can also be used easily for setting up new R
installations or for workshops which require packages.

Unlike most reproducibility-ish packages, this is not focused on being
able to run code under a completely specified environment. It is aimed
at ensuring the right sets of packages are installed for users and
workshops.

------------------------------------------------------------------------

## What is `manifesto`?

`manifesto` introduces a human-readable, TOML-based manifest format for
R projects. It captures:

- Project metadata (name, version, description, authors)
- Required R version
- Package dependencies, with version constraints
- Package sources (CRAN, Bioconductor, GitHub, GitLab, Git, or custom
  URLs)
- Optional dependency groups (development, workshop, full install)
- System dependencies (OS libraries)
- Install preferences (such as binary vs source installs)

The goal is to simplify project setup across local machines, teams, and
workshops, without locking users into heavyweight tools.

------------------------------------------------------------------------

## Minimal Example

The smallest valid `rproject.toml` looks like this:

``` toml
[project]
name = "MyAnalysis"
version = "0.0.1"

[manifesto]
version = "0.1.0"

[environment]
r_version = ">= 4.4.2"

[dependencies]
dplyr = ">= 1.0.0"
```

## Installation

You can install the development version of `manifesto` like so:

``` r

# install.packages('pak')
pak::pak('christopherkenny/manifesto')
```

## Example

For most users, you will only need to use the
[`manifest_install()`](http://christophertkenny.com/manifesto/reference/manifest_install.md)
function. This handles organizing and installing packages dound in the
manifest file. By default, this file is called `rproject.toml`.

Below, we install one of the example manifest files included with the
package. Note that for the example, `dry_run = TRUE` means that no
packages will be installed, but details of what would be installed are
printed to the console.

``` r

library(manifesto)

manifest <- system.file(package = 'manifesto', 'complex.toml')

manifest_install(path = manifest, dry_run = TRUE)
#> 
#> ── Dry run: would install the following 3 packages ──
#> 
#> • dplyr@1.2.0
#> • BiocManager@1.30.27
#> • readr@2.1.4
```

`manifesto` can also be used to create a manifest file from a package’s
`DESCRIPTION` file.

``` r

manifest <- manifest_from_description(
  system.file(package = 'cli', 'DESCRIPTION')
)
readLines(manifest) |>
  cat(sep = '\n')
#> [manifesto]
#> version = "0.0.1"
#> 
#> [project]
#> name = "cli"
#> version = "3.6.5"
#> authors = [
#>     { name = "Gábor Csárdi", email = "gabor@posit.co", roles = ["aut", "cre"] },
#>     { name = "Hadley Wickham", roles = "ctb" },
#>     { name = "Kirill Müller", roles = "ctb" },
#>     { name = "Salim Brüggemann", email = "salim-b@pm.me", roles = "ctb" },
#>     { name = "Posit Software, PBC", roles = ["cph", "fnd"] }
#> ]
#> 
#> [environment]
#> r_version = ">= 3.4"
#> 
#> [dependencies]
#> utils = "*"
#> 
#> [suggests-dependencies]
#> callr = "*"
#> covr = "*"
#> crayon = "*"
#> digest = "*"
#> glue = ">= 1.6.0"
#> grDevices = "*"
#> htmltools = "*"
#> htmlwidgets = "*"
#> knitr = "*"
#> methods = "*"
#> processx = "*"
#> ps = """
#> >=
#> 1.3.4.9000"""
#> rlang = ">= 1.0.2.9003"
#> rmarkdown = "*"
#> rprojroot = "*"
#> rstudioapi = "*"
#> testthat = ">= 3.2.0"
#> tibble = "*"
#> whoami = "*"
#> withr = "*"
```
