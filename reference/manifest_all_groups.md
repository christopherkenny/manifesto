# Return all defined optional dependency groups in a manifest file

Return all defined optional dependency groups in a manifest file

## Usage

``` r
manifest_all_groups(path = "rproject.toml")
```

## Arguments

- path:

  Path to the `rproject.toml` file.

## Value

A character vector of group names (without "-dependencies")

## Examples

``` r
manifest_all_groups(path = system.file(package = 'manifesto', 'minimal.toml'))
#> character(0)
```
