test_that('`manifest_version()` matches package version', {
  expect_equal(
    manifest_version(),
    as.character(utils::packageVersion('manifesto'))
  )
})
