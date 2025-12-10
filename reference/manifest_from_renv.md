# Generate a TOML manifest from a renv lockfile

Reads a `{renv}` lockfile (JSON format) and converts it to a
`manifesto`-style TOML manifest. Extracts package versions and the R
environment version.

## Usage

``` r
manifest_from_renv(lockfile = "renv.lock", path, r_version)
```

## Arguments

- lockfile:

  Path to a `renv.lock` JSON file. Defaults to `'renv.lock'`.

- path:

  Optional path to write the TOML manifest. Defaults to a temporary
  `.toml` file.

- r_version:

  Optional R version settings. Defaults to version found in lockfile.

## Value

Path to the generated TOML file (invisibly).

## Examples

``` r
path <- manifest_from_renv(system.file(package = 'manifesto', 'renv.lock'))
```
