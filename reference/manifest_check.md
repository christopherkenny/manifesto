# Check if the installed packages match the manifest requirements

Check if the installed packages match the manifest requirements

## Usage

``` r
manifest_check(path = "rproject.toml", groups = NULL)
```

## Arguments

- path:

  Path to the TOML manifest file. Defaults to "rproject.toml".

- groups:

  Optional dependency groups to include. Defaults to NULL (core only).

## Value

A `data.frame` reporting installed version, required version, and
status.

## Examples

``` r
manifest_check(system.file(package = 'manifesto', 'minimal.toml'))
#>   package required installed  status
#> 1   dplyr  >=1.0.0      <NA> MISSING
```
