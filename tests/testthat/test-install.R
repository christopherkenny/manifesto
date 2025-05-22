test_that('`manifest_install()` returns refs for core only', {
  path <- testthat::test_path('files', 'works-git-url.toml')
  refs <- manifest_install(path = path, dry_run = TRUE)

  expect_true(any(grepl('^cli@', refs)))
  expect_false(any(grepl('tibble', refs)))
})

test_that('`manifest_install()` returns refs for core + dev', {
  path <- testthat::test_path('files', 'works-git-url.toml')
  refs <- manifest_install(path = path, groups = 'dev', dry_run = TRUE)

  expect_true(any(grepl('^git::https://github.com/tidyverse/tibble', refs)))
})

test_that('`manifest_install()` returns deduplicated refs if package is in multiple groups', {
  path <- testthat::test_path('files', 'works-dedup.toml')

  refs <- manifest_install(path = path, groups = c('dev', 'ci'), dry_run = TRUE)

  # should contain only one `fs@` entry (from core)
  expect_equal(sum(grepl('^fs@', refs)), 1)

  # should include glue (from dev group)
  expect_true(any(grepl('^glue@', refs)))
})
