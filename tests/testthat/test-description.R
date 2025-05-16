test_that('`parse_description()` returns a list with named fields', {
  desc <- parse_description(testthat::test_path('files', 'desc-minimal'))

  expect_type(desc, 'list')
  expect_true(all(c('Package', 'Version', 'Authors@R') %in% names(desc)))
  expect_equal(desc$Package, 'testpkg')
})

test_that('`parse_authors_field()` parses Authors@R correctly', {
  field <- 'person("Jane", "Doe", email = "jane@example.com", role = c("aut", "cre"))'
  parsed <- parse_authors_field(field)

  expect_type(parsed, 'list')
  expect_equal(parsed[[1]]$name, 'Jane Doe')
  expect_equal(parsed[[1]]$email, 'jane@example.com')
  expect_equal(parsed[[1]]$roles, c('aut', 'cre'))
})

test_that('`parse_dependencies()` parses versioned fields', {
  field <- 'dplyr (>= 1.0.0), glue'
  parsed <- parse_dependencies(field)

  expect_equal(parsed$dplyr, '>= 1.0.0')
  expect_equal(parsed$glue, '*')
})

test_that('`parse_r_version()` extracts R version constraint', {
  field <- 'R (>= 4.2.0), methods'
  version <- parse_r_version(field)

  expect_equal(version, '>= 4.2.0')
})

test_that('`manifest_from_description()` generates a valid TOML file', {
  desc_path <- testthat::test_path('files', 'desc-minimal')
  path <- manifest_from_description(desc_path)

  expect_true(file.exists(path))

  manifest <- tomledit::from_toml(tomledit::read_toml(path))
  expect_equal(manifest$project$name, 'testpkg')
  expect_true('dependencies' %in% names(manifest))
  expect_true('suggests-dependencies' %in% names(manifest))
  expect_true('environment' %in% names(manifest))
})




