# Install packages from a manifesto manifest

Install packages from a manifesto manifest

## Usage

``` r
manifest_install(path = "rproject.toml", groups = NULL, dry_run = FALSE)
```

## Arguments

- path:

  Path to the `rproject.toml` file. Defaults to "rproject.toml" in the
  current directory.

- groups:

  Optional character vector of dependency groups to include (e.g.,
  "dev", "workshop").

- dry_run:

  If `TRUE`, show what would be installed but do not install anything.

## Value

Invisibly returns a character vector of package references that were
installed.

## Examples

``` r
manifest_install(
  path = system.file(package = 'manifesto', 'minimal.toml'),
  dry_run = TRUE
)
#> 
#> ── Dry run: would install the following 1 packages ──
#> 
#> • dplyr@1.2.1
```
