# Peek into a manifest file

Peek into a manifest file

## Usage

``` r
manifest_peek(path = "rproject.toml")
```

## Arguments

- path:

  Path to the `rproject.toml` file. Defaults to "rproject.toml" in the
  current directory.

## Value

Invisibly returns a list with parsed contents.

## Examples

``` r
manifest_peek(system.file('complex.toml', package = 'manifesto'))
#> • Manifesto version: "0.0.1"
#> • Project name: "complicated-demo"
#> • Project version: "0.9.1"
#> • Required R version: ">= 4.2.0"
#> Dependencies:
#>   • default: dplyr (">= 1.0.10"), BiocManager (">= 1.30.10"), readr ("2.1.4")
#>   • dev: testthat ("3.2.0"), lintr ("3.0.2")
#>   • workshop: terra ("1.7-18")
#>   • ci: covr ("3.6.2")
#>   • system: build-essential ("*")
```
