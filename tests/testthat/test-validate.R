test_that('`validate_manifest()` works', {
  expect_true(validate_manifest(path = system.file(package = 'manifesto', 'minimal.toml')))
  expect_true(validate_manifest(path = system.file(package = 'manifesto', 'complex.toml')))
})
