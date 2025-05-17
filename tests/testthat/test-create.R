test_that('`create_manifest()` writes a valid manifest file', {
  path <- create_manifest(project_name = 'demo', project_version = '0.1.0')

  expect_true(file.exists(path))

  manifest <- tomledit::from_toml(tomledit::read_toml(path))
  expect_equal(manifest$project$name, 'demo')
  expect_equal(manifest$project$version, '0.1.0')
  expect_true('dependencies' %in% names(manifest))
})
