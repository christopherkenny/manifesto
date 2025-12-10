# Generate a TOML manifest from a DESCRIPTION file

Parses fields from a DESCRIPTION file and generates a corresponding TOML
manifest with `[project]`, `[environment]`, and dependency groups.

## Usage

``` r
manifest_from_description(
  description = "DESCRIPTION",
  path,
  include_empty_groups = FALSE
)
```

## Arguments

- description:

  Path to the DESCRIPTION file.

- path:

  Optional output file path. Defaults to a temporary `.toml` file.

- include_empty_groups:

  Whether to include empty dependency sections.

## Value

Path to the generated TOML file (invisibly).

## Details

By default, both `Depends` and `Imports` are mapped to `[dependencies]`.
`Suggests`, `LinkingTo`, and `Enhances` are mapped to their own optional
groups.

## Examples

``` r
path <- manifest_from_description(system.file(package = 'cli', 'DESCRIPTION'))
```
