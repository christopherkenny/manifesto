test_that('`manifest_from_loaded()` creates a TOML file with nonempty [packages]', {
  skip_if_not_installed('tomledit')

  path <- manifest_from_loaded()
  expect_true(file.exists(path))

  toml <- tomledit::read_toml(path) |> tomledit::from_toml()

  expect_type(toml$dependencies, 'list')
  expect_gt(length(toml$dependencies), 0)

  expect_type(toml$environment, 'list')
  expect_match(toml$environment$r_version, '^\\d+\\.\\d+')
})
