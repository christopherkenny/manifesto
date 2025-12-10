# Parse a manifesto manifest file

By default, `groups = NULL`, which will only install core dependencies.
If you want to include all optional groups, set `groups = 'all'`.

## Usage

``` r
manifest_parse(path = "rproject.toml", groups = NULL)
```

## Arguments

- path:

  Path to the `rproject.toml` file.

- groups:

  Optional character vector of dependency groups to include.

## Value

A character vector of resolved package references.

## Examples

``` r
manifest_parse(path = system.file(package = 'manifesto', 'minimal.toml'))
#> [1] "dplyr@>=1.0.0"
```
