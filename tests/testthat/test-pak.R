test_that('`manifest_from_pak()` creates a valid TOML file with expected packages', {
  lockfile <- system.file(package = 'manifesto', 'pkg.lock')

  path <- manifest_from_pak(lockfile)
  expect_true(file.exists(path))

  toml <- tomledit::read_toml(path) |> tomledit::from_toml()
  deps <- toml$dependencies

  expect_type(deps, 'list')
  expect_named(deps, c('cli', 'pak', 'rlang', 'tomledit'))

  expect_equal(toml$environment$r_version, '4.5.1')
})
