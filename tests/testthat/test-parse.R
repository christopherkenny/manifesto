test_that('`manifest_parse()` returns only core dependencies by default', {
  path <- testthat::test_path('files', 'works-git-url.toml')
  refs <- manifest_parse(path)
  expect_true(all(grepl('^cli@', refs)))
  expect_false(any(grepl('tibble', refs))) # dev-dependency
})

test_that('`manifest_parse()` includes dev group when requested', {
  path <- testthat::test_path('files', 'works-git-url.toml')
  refs <- manifest_parse(path, groups = 'dev')
  expect_true(any(grepl('^git::https://github.com/tidyverse/tibble', refs)))
  expect_true(any(grepl('tibble', refs)))
})

test_that('`manifest_parse()` includes all groups when requested', {
  path <- testthat::test_path('files', 'works-git-url.toml')
  refs <- manifest_parse(path, groups = 'all')
  expect_true(any(grepl('^cli@', refs)))
  expect_true(any(grepl('^git::https://github.com/tidyverse/tibble', refs)))
})

test_that('`manifest_parse()` warns when unknown groups are requested', {
  path <- testthat::test_path('files', 'works-git-url.toml')

  expect_warning(
    refs <- manifest_parse(path, groups = c('nonexistent', 'dev')),
    'Group'
  )

  expect_true(any(grepl('^git::https://github.com/tidyverse/tibble', refs)))
})

test_that('`manifest_parse()` returns expected refs from warn-all-dependencies.toml', {
  path <- testthat::test_path('files', 'warn-all-dependencies.toml')
  refs <- manifest_parse(path)

  expect_true(any(grepl('^glue@', refs)))
  expect_false(any(grepl('fs', refs))) # fs is in reserved group
})

test_that('`manifest_parse()` parses core even if dev group is invalid', {
  path <- testthat::test_path('files', 'error-missing-repo.toml')
  refs <- manifest_parse(path)

  expect_true(any(grepl('^cli@', refs)))
  expect_false(any(grepl('rlang', refs))) # not in core group
})

test_that('`manifest_parse()` errors if dev group includes bad github entry', {
  path <- testthat::test_path('files', 'error-missing-repo.toml')

  expect_error(
    manifest_parse(path, groups = 'dev'),
    'source = github but no repo'
  )
})

test_that('`manifest_parse()` handles local source entries', {
  path <- testthat::test_path('files', 'works-local-dev.toml')
  refs <- manifest_parse(path, groups = 'dev')

  expect_true(any(grepl('^local::../bskyr$', refs)))
})

test_that('`manifest_parse()` handles url sources', {
  path <- testthat::test_path('files', 'works-url.toml')
  refs <- manifest_parse(path, groups = 'dev')

  expect_true(any(grepl('^url::https://cran\\.r-project\\.org', refs)))
})

test_that('`manifest_parse()` handles gitlab sources', {
  path <- testthat::test_path('files', 'works-gitlab.toml')
  refs <- manifest_parse(path, groups = 'dev')

  expect_true(any(grepl('^r-lib/archive@v1\\.0\\.1', refs)))
})
