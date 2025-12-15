test_that('`manifest_check()` works', {
  manifest_path <- testthat::test_path('files', 'many-deps.toml')
  check <- manifest_check(manifest_path)
  expect_s3_class(check, 'data.frame')
})

test_that('`version_satisfies()` works with various operators', {
  # Exact match
  expect_true(version_satisfies('== 1.0.0', '1.0.0'))
  expect_false(version_satisfies('== 1.0.0', '1.0.1'))

  # Greater than or equal to
  expect_true(version_satisfies('>= 1.0.0', '1.0.0'))
  expect_true(version_satisfies('>= 1.0.0', '1.1.0'))
  expect_false(version_satisfies('>= 1.0.0', '0.9.9'))

  # Less than or equal to
  expect_true(version_satisfies('<= 1.0.0', '1.0.0'))
  expect_true(version_satisfies('<= 1.0.0', '0.9.0'))
  expect_false(version_satisfies('<= 1.0.0', '1.0.1'))

  # Greater than
  expect_true(version_satisfies('> 1.0.0', '1.0.1'))
  expect_false(version_satisfies('> 1.0.0', '1.0.0'))

  # Less than
  expect_true(version_satisfies('< 1.0.0', '0.9.9'))
  expect_false(version_satisfies('< 1.0.0', '1.0.0'))

  # Not equal to
  expect_true(version_satisfies('!= 1.0.0', '1.0.1'))
  expect_false(version_satisfies('!= 1.0.0', '1.0.0'))

  # Wildcard
  expect_true(version_satisfies('*', '1.2.3'))
})

test_that('`version_satisfies()` handles different version formats', {
  expect_true(version_satisfies('>= 1.0', '1.0.0'))
  expect_true(version_satisfies('== 1.0', '1.0.0'))
  expect_true(version_satisfies('>= 1', '1.0.0'))
})

test_that('`version_satisfies()` returns FALSE for invalid required format', {
  expect_false(version_satisfies('~> 1.0.0', '1.0.0'))
  expect_false(version_satisfies('1.0.0', '1.0.0'))
})
