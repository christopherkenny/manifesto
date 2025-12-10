# Generate a TOML manifest from currently loaded packages

Captures all currently loaded packages in the R session and generates a
`manifesto`-style TOML manifest. Package versions can either reflect
their current loaded versions, or use a wildcard (`*`) to accept any.

## Usage

``` r
manifest_from_loaded(
  path,
  include_base = FALSE,
  min_version = c("loaded", "*"),
  r_version = current_r_version()
)
```

## Arguments

- path:

  Optional path to write the manifest. If missing, a temporary `.toml`
  file is created.

- include_base:

  Logical. Whether to include base packages. Defaults to FALSE.

- min_version:

  Whether to require exact loaded versions (`'loaded'`, default) or
  allow any version via a wildcard (`'*'`).

- r_version:

  Optional R version settings. Defaults to
  [`current_r_version()`](http://christophertkenny.com/manifesto/reference/current_r_version.md)

## Value

Path to the generated TOML file (invisibly).

## Details

Base packages are excluded by default to minimize boilerplate.

## Examples

``` r
path <- manifest_from_loaded()
```
