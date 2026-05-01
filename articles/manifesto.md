# Getting started with \`manifesto\`

The `manifesto` package provides tools for managing project environments
in R using standardized TOML manifest files. These manifest files make
project metadata, dependencies, and environment settings explicit and
portable. This vignette introduces the core features of `manifesto` and
demonstrates how to use it in typical R workflows.

``` r

library(manifesto)
```

## Installation

You can install the stable version of `manifesto` from CRAN:

``` r

pak::pak('manifesto')
```

To install the development version from GitHub:

``` r

pak::pak('christopherkenny/manifesto')
```

## Installing from a Manifest

For example purposes, we’ll use a manifest file included with the
`manifesto` package. This file is located in the `inst/examples`
directory of the package.

``` r

manifest_path <- system.file('complex.toml', package = 'manifesto')
```

To install all dependencies listed in a TOML manifest:

``` r

manifest_install(manifest_path)
```

To install with optional groups:

``` r

manifest_install(manifest_path, groups = 'dev')
manifest_install(manifest_path, groups = c('dev', 'ci'))
```

To preview what would be installed:

``` r

manifest_install(manifest_path, dry_run = TRUE)
#> 
#> ── Dry run: would install the following 3 packages ──
#> 
#> • dplyr@1.2.1
#> • BiocManager@1.30.27
#> • readr@2.1.4
```

## Creating and Using a Manifest

### Creating a Minimal Manifest

``` r

path <- manifest_create()
path
#> [1] "/tmp/RtmpgcxxAd/file1c324da7ed2f.toml"
```

    #> [manifesto]
    #> version = "0.0.2"
    #> 
    #> [project]
    #> name = "Project"
    #> version = "0.0.1"
    #> 
    #> [environment]
    #> r_version = "*"
    #> 
    #> [dependencies]

This creates a file with default sections:

- `[manifesto]` with the current package version
- `[project]` with name and version placeholders
- `[environment]` with a default R version
- `[dependencies]`, initialized as an empty table

### Example Manifest Files

#### Basic project manifest

In general, this structure is only useful when there are dependencies to
specify. Suppose we want to list `dplyr` and `ggplot2` as dependencies
for our project. Here, we specify that we need `dplyr` version
`>= 1.0.0` and any version of `ggplot2`. (Practically, “any” version
will be limited to versions that meet the R version requirement and
match with other dependencies.)

Then run:

``` r

manifest_create(
  path = tempfile(fileext = '.toml'),
  name = 'myproject',
  r_version = '>= 4.2.0',
  dependencies = list(
    dplyr = '>= 1.0.0',
    ggplot2 = '*'
  )
)
```

This creates a manifest file with the following content:

``` toml
[manifesto]
version = "0.0.1"

[project]
name = "myproject"
version = "0.1.0"

[environment]
r_version = ">= 4.2.0"

[dependencies]
dplyr = ">= 1.0.0"
ggplot2 = "*"
```

#### Adding optional dependency groups

Often, we need to specify optional dependencies for development,
testing, or CI. We can do this by passing additional named arguments to
[`manifest_create()`](http://christophertkenny.com/manifesto/reference/manifest_create.md).

``` r

manifest_create(
  path = tempfile(fileext = '.toml'),
  name = 'myproject',
  r_version = '>= 4.2.0',
  dependencies = list(
    dplyr = '>= 1.0.0',
    ggplot2 = '*'
  ),
  'dev-dependencies' = list(
    testthat = '>= 3.1.0',
    lintr = '*'
  ),
  'ci-dependencies' = list(
    pkgdown = '*'
  )
)
```

``` toml
[manifesto]
version = "0.0.1"

[project]
name = "myproject"
version = "0.1.0"

[environment]
r_version = ">= 4.2.0"

[dependencies]
dplyr = ">= 1.0.0"
ggplot2 = "*"

[dev-dependencies]
testthat = ">= 3.1.0"
lintr = "*"

[ci-dependencies]
pkgdown = "*"
```

#### Including a package from GitHub

Not all packages are available on CRAN. You can include packages from
GitHub or other sources by specifying additional details. Note that
`manifesto` uses the `pak` package to handle these dependencies, so any
source that `pak` supports can be used.

The corresponding call to
[`manifest_create()`](http://christophertkenny.com/manifesto/reference/manifest_create.md)
would look like this:

``` r

manifest_create(
  path = tempfile(fileext = '.toml'),
  name = 'myproject',
  r_version = '>= 4.2.0',
  dependencies = list(
    dplyr = '>= 1.0.0',
    ggplot2 = '*',
    cli = '*'
  ),
  'dev-dependencies' = list(
    gh = list(source = 'github', repo = 'r-lib/gh', ref = 'v1.4.0')
  )
)
```

``` toml
[manifesto]
version = "0.0.1"

[project]
name = "myproject"
version = "0.1.0"

[environment]
r_version = ">= 4.2.0"

[dependencies]
dplyr = ">= 1.0.0"
ggplot2 = "*"
cli = "*"

[dev-dependencies]
gh = { source = "github", repo = "r-lib/gh", ref = "v1.4.0" }
```

#### Using a local package path

You can also specify a local package path for development or testing
purposes.

``` r

manifest_create(
  path = tempfile(fileext = '.toml'),
  name = 'myproject',
  r_version = '>= 4.2.0',
  dependencies = list(
    dplyr = '>= 1.0.0'
  ),
  'dev-dependencies' = list(
    mydevpkg = list(source = 'local', path = '../mydevpkg')
  )
)
```

    [manifesto]
    version = "0.0.1"

    [project]
    name = "myproject"
    version = "0.1.0"

    [environment]
    r_version = ">= 4.2.0"

    [dependencies]
    dplyr = ">= 1.0.0"

    [dev-dependencies]
    mydevpkg = { source = "local", path = "../mydevpkg" }

These examples reflect common patterns for specifying runtime,
development, CI, and local dependencies.

## Validating a Manifest

You can validate the structure and content of a manifest with:

``` r

manifest_validate(path = manifest_path)
```

This checks for required sections, valid dependency specifications, and
correct field usage.

## Example Workflow

In general, you only have to create and share a file. You can use the
[`manifest_create()`](http://christophertkenny.com/manifesto/reference/manifest_create.md)
function to create a manifest file. Then anyone with the file can use
[`manifest_install()`](http://christophertkenny.com/manifesto/reference/manifest_install.md)
to install the dependencies. `manifesto` is a generally lightweight
package, so it should not add much overhead to your workflow.

The use of groups allows you to specify different sets of dependencies
for different purposes, such as development, testing, or for workshops.
The original motivation was as a workshop tool, but has expanded a bit
to allow for more general use.

### 1. Creating a new manifest with common dependencies

``` r

manifest <- manifest_create(
  path = tempfile(fileext = '.toml'),
  name = 'myproject',
  version = '0.1.0',
  r_version = '>= 4.2.0',
  dependencies = list(
    dplyr = '>= 1.0.0',
    ggplot2 = '*',
    glue = '*'
  ),
  'dev-dependencies' = list(
    testthat = '>= 3.1.0',
    lintr = '*'
  )
)
```

This creates a manifest for an R project that uses `dplyr` and
`ggplot2`, with development tools like `testthat` grouped separately.

### 2. Installing core and dev dependencies

``` r

manifest_install(manifest, groups = 'dev', dry_run = TRUE)
#> 
#> ── Dry run: would install the following 5 packages ──
#> 
#> • dplyr@1.2.1
#> • ggplot2
#> • glue
#> • testthat@3.3.2
#> • lintr
```

This installs everything from `[dependencies]` and `[dev-dependencies]`.
Here, for CRAN purposes, `dry_run = TRUE` means no packages are
installed, but the output shows what would be installed.

The general idea then is that `dependencies` must always be installed.
Groups like `dev` would be used for development or testing.

### 3. Installing all dependencies

The special group name `all` is reserved to allow a user to install
everything in the manifest.

``` r

manifest_install(manifest, groups = 'all', dry_run = TRUE)
#> 
#> ── Dry run: would install the following 5 packages ──
#> 
#> • dplyr@1.2.1
#> • ggplot2
#> • glue
#> • testthat@3.3.2
#> • lintr
```

By default, only `[dependencies]` is installed, whereas `all` installs
everything.

## Manifest File Structure

A valid TOML manifest must contain the following top-level sections:

- `[manifesto]` (required)
  - `version`: (required) should match the version of the `manifesto`
    package used to generate it.
- `[project]` (required)
  - `name`: (required) the name of the project.
  - `version`: (required) the version of the project.
  - `authors`: (optional) an array of tables with fields such as `name`,
    `email`, and `roles`.
- `[environment]` (required)
  - `r_version`: (required) a valid R version requirement string (e.g.,
    “\>= 4.2.0”).
- `[dependencies]` (required)
  - List of core package dependencies (name = version).

Optional groups:

- `[<group>-dependencies]` (optional)
  - Named groups such as `dev`, `suggests`, `ci`, `enhances`,
    `workshop`, etc.
  - Each contains its own set of package references.

Each package reference may be: - A version string (e.g., “\>= 1.0.0”) -
A table with `source`, `repo`, `ref`, or `url` (e.g., for GitHub,
GitLab, or custom sources)

Examples:

    gh = { source = "github", repo = "r-lib/gh", ref = "v1.4.0" }
    custompkg = { source = "url", url = "https://example.com/custompkg.tar.gz" }

## Converting from DESCRIPTION to Manifest

``` r

manifest_desc <- tempfile(fileext = '.toml')
manifest_from_description(
  system.file(package = 'cli', 'DESCRIPTION'),
  path = manifest_desc
)
```

    #> [manifesto]
    #> version = "0.0.2"
    #> 
    #> [project]
    #> name = "cli"
    #> version = "3.6.6"
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

This uses fields from the DESCRIPTION file to populate:

- Project name and version
- Author information
- R version from `Depends`
- Dependency sections such as `Imports`, `Suggests`, `LinkingTo`, and
  `Enhances`

## Converting from Manifest to DESCRIPTION

``` r

description_path <- tempfile(pattern = 'DESCRIPTION')
manifest_to_description(manifest_desc, out = description_path)
```

    #> Package: cli
    #> Version: 3.6.6
    #> Title: TODO Title
    #> Description: TODO Description
    #> License: TODO License
    #> Encoding: UTF-8
    #> Authors@R: c( person("Gábor", "Csárdi", email = "gabor@posit.co", role
    #>         = c("aut", "cre")), person("Hadley", "Wickham", role =
    #>         c("ctb")), person("Kirill", "Müller", role = c("ctb")),
    #>         person("Salim", "Brüggemann", email = "salim-b@pm.me", role =
    #>         c("ctb")), person("Posit Software,", "PBC", role = c("cph",
    #>         "fnd")) )
    #> Depends: R (>= 3.4)
    #> Imports: utils
    #> Suggests: callr, covr, crayon, digest, glue (>= 1.6.0), grDevices,
    #>         htmltools, htmlwidgets, knitr, methods, processx, ps (>=
    #>         1.3.4.9000), rlang (>= 1.0.2.9003), rmarkdown, rprojroot,
    #>         rstudioapi, testthat (>= 3.2.0), tibble, whoami, withr

Required DESCRIPTION fields such as `Title`, `Description`, and
`License` are filled with placeholder `TODO` values if missing. Author
information is translated into `Authors@R` format.

It’s very important to note that these types of files have different
purposes. Not all fields in a DESCRIPTION file are required in a
manifest file, so conversion can be lossy.

## Learn More

For complete documentation, visit:

<https://github.com/christopherkenny/manifesto>

This package is intended to streamline environment specification and
improve reproducibility in R projects.

------------------------------------------------------------------------

**DISCLAIMER**: This vignette has been written with help from ChatGPT
4o. It has been reviewed for correctness and edited for clarity by the
package author. Please note any issues at
<https://github.com/christopherkenny/manifesto/issues>.
