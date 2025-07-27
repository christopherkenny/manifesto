test_that('`manifest_from_pak()` creates a valid TOML file', {
  lockfile <- system.file(package = 'manifesto', 'renv.lock')

  path <- manifest_from_renv(
    lockfile,
    r_version = '4.5.1'
  )
  expect_true(file.exists(path))

  toml <- tomledit::read_toml(path) |> tomledit::from_toml()
  pkgs <- toml$dependencies

  expect_type(pkgs, 'list')
  expect_named(pkgs, c('markdown', 'mime'))
  expect_equal(pkgs$markdown, '1.0')
  expect_equal(pkgs$mime, '0.12.1')

  expect_equal(toml$environment$r_version, '4.5.1')
})
