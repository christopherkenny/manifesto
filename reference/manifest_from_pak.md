# Generate a TOML manifest from a `pak` lockfile

Reads a `{pak}` lockfile (JSON format) and converts it to a
`manifesto`-style TOML manifest. Extracts package versions and the
locked R version.

## Usage

``` r
manifest_from_pak(lockfile = "pkg.lock", path, r_version)
```

## Arguments

- lockfile:

  Path to a `pkg.lock` JSON file created by `{pak}`.

- path:

  Optional path to write the manifest. Defaults to a temporary `.toml`
  file.

- r_version:

  Optional R version settings. Defaults to version found in lockfile.

## Value

Path to the generated TOML file (invisibly).

## Examples

``` r
path <- manifest_from_pak(system.file(package = 'manifesto', 'pkg.lock'))
```
