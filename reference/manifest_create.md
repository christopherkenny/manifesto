# Create a minimal TOML manifest file

This creates a minimal TOML file with a `[manifesto]`, `[project]`,
`[environment]`, and empty `[dependencies]` section.

## Usage

``` r
manifest_create(
  path,
  project_name = "Project",
  project_version = "0.0.1",
  manifesto_version = manifest_version(),
  r_version = "*",
  ...
)
```

## Arguments

- path:

  File path to write to. If missing, a temporary file will be used.

- project_name:

  Optional project name. Defaults to `Project`.

- project_version:

  Optional project version. Defaults to `0.0.1`.

- manifesto_version:

  Optional `manifesto` version. Defaults to the current package version.

- r_version:

  Optional R version settings. Defaults to `'*'`.

- ...:

  Additional named arguments to add to the manifest. These will be added
  to the top-level of the TOML file.

## Value

Invisibly returns the written path.

## Examples

``` r
path <- manifest_create(
  dependencies = list(dplyr = '>= 1.0.0'),
  'suggests-dependencies' = list(testthat = '>= 3.0.0')
)
```
