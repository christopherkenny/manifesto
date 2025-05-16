test_that('`validate_manifest()` works on package example files', {
  expect_true(
    validate_manifest(path = system.file('minimal.toml', package = 'manifesto'))
  )
  expect_true(
    validate_manifest(path = system.file('complex.toml', package = 'manifesto'))
  )
})

test_that('`validate_manifest()` works on file with git source', {
  path <- testthat::test_path('files', 'works-git-url.toml')
  expect_true(validate_manifest(path))
})

test_that('`validate_manifest()` works on file with local source', {
  path <- testthat::test_path('files', 'works-local-dev.toml')
  expect_true(validate_manifest(path))
})

test_that('`validate_manifest()` warns on reserved all-dependencies section', {
  path <- testthat::test_path('files', 'warn-all-dependencies.toml')
  expect_warning(
    validate_manifest(path),
    'reserved'
  )
})

test_that('`validate_manifest()` errors when github repo is missing', {
  path <- testthat::test_path('files', 'error-missing-repo.toml')
  expect_error(
    validate_manifest(path, groups = 'dev'),
    'source = github but no repo'
  )
})

test_that('`validate_manifest()` works with url source', {
  path <- testthat::test_path('files', 'works-url.toml')
  expect_true(validate_manifest(path, groups = 'dev'))
})

test_that('`validate_manifest()` works with gitlab source', {
  path <- testthat::test_path('files', 'works-gitlab.toml')
  expect_true(validate_manifest(path, groups = 'dev'))
})

test_that('`validate_manifest()` warns when url source is missing url field', {
  path <- testthat::test_path('files', 'error-missing-url.toml')
  expect_warning(validate_manifest(path), 'missing a url field')
})

test_that('`validate_manifest()` warns when local source is missing path field', {
  path <- testthat::test_path('files', 'error-missing-path.toml')
  expect_warning(validate_manifest(path), 'missing a path field')
})
