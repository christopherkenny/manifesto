test_that('`manifest_validate()` works on package example files', {
  expect_true(
    manifest_validate(path = system.file('minimal.toml', package = 'manifesto'))
  )
  expect_true(
    manifest_validate(path = system.file('complex.toml', package = 'manifesto'))
  )
})

test_that('`manifest_validate()` works on file with git source', {
  path <- testthat::test_path('files', 'works-git-url.toml')
  expect_true(manifest_validate(path))
})

test_that('`manifest_validate()` works on file with local source', {
  path <- testthat::test_path('files', 'works-local-dev.toml')
  expect_true(manifest_validate(path))
})

test_that('`manifest_validate()` warns on reserved all-dependencies section', {
  path <- testthat::test_path('files', 'warn-all-dependencies.toml')
  expect_warning(
    manifest_validate(path),
    'reserved'
  )
})

test_that('`manifest_validate()` errors when github repo is missing', {
  path <- testthat::test_path('files', 'error-missing-repo.toml')
  expect_error(
    manifest_validate(path, groups = 'dev'),
    'source = github but no repo'
  )
})

test_that('`manifest_validate()` works with url source', {
  path <- testthat::test_path('files', 'works-url.toml')
  expect_true(manifest_validate(path, groups = 'dev'))
})

test_that('`manifest_validate()` works with gitlab source', {
  path <- testthat::test_path('files', 'works-gitlab.toml')
  expect_true(manifest_validate(path, groups = 'dev'))
})

test_that('`manifest_validate()` warns when url source is missing url field', {
  path <- testthat::test_path('files', 'error-missing-url.toml')
  expect_warning(manifest_validate(path), 'missing a url field')
})

test_that('`manifest_validate()` warns when local source is missing path field', {
  path <- testthat::test_path('files', 'error-missing-path.toml')
  expect_warning(manifest_validate(path), 'missing a path field')
})
