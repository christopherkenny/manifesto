test_that('`manifest_from_installed()` creates a TOML file with nonempty entries', {
  path <- manifest_from_installed()
  expect_true(file.exists(path))

  toml <- tomledit::read_toml(path) |> tomledit::from_toml()

  expect_type(toml$dependencies, 'list')
  expect_gt(length(toml$dependencies), 0)

  expect_type(toml$environment, 'list')
  expect_match(toml$environment$r_version, '^\\d+\\.\\d+')
})
