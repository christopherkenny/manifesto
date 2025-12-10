# Validate a manifesto manifest file

Validate a manifesto manifest file

## Usage

``` r
manifest_validate(path = "rproject.toml", groups = NULL)
```

## Arguments

- path:

  Path to the `rproject.toml` file.

- groups:

  Optional character vector of dependency groups to include.

## Value

Invisibly returns `TRUE` if the manifest is valid; otherwise, stops with
an error.

## Examples

``` r
manifest_validate(path = system.file(package = 'manifesto', 'minimal.toml'))
```
