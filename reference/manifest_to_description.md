# Convert a TOML manifest to a DESCRIPTION file

Generates a valid DESCRIPTION file from a manifest. Required fields like
Title, Description, License, and Authors@R are inserted as TODOs if not
present.

## Usage

``` r
manifest_to_description(path = "rproject.toml", out = "DESCRIPTION")
```

## Arguments

- path:

  Path to the TOML manifest file.

- out:

  Path to the DESCRIPTION file to write. Defaults to 'DESCRIPTION'.

## Value

Invisibly returns the path to the written DESCRIPTION file.

## Examples

``` r
out <- tempfile(pattern = 'DESCRIPTION')
manifest_to_description(
  path = system.file('minimal.toml', package = 'manifesto'),
  out = out
)
```
