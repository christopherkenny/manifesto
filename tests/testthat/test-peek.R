test_that('manifest_peek handles missing file', {
  expect_error(manifest_peek('non-existent-file.toml'), 'File not found')
})

test_that('manifest_peek warns on missing sections', {
  file <- test_path('files', 'missing-sections.toml')
  expect_warning(manifest_peek(file), 'Missing expected section')
})

test_that('manifest_peek handles no dependencies', {
  file <- test_path('files', 'no-deps.toml')
  expect_snapshot(manifest_peek(file))
})

test_that('manifest_peek handles many dependencies', {
  file <- test_path('files', 'many-deps.toml')
  expect_snapshot(manifest_peek(file))
})

test_that('manifest_peek handles various dependency specifications', {
  file <- test_path('files', 'works-dedup.toml')
  expect_snapshot(manifest_peek(file))
})

test_that('manifest_peek returns parsed manifest invisibly', {
  file <- test_path('files', 'no-deps.toml')
  suppressWarnings({
    manifest <- manifest_peek(file)
  })
  expect_true(is.list(manifest))
  expect_equal(manifest$project$name, 'myproject')
})
