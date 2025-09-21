test_that('`manifest_check_system()` works with existing system dependency', {
  # Assuming 'git' is installed on the system
  path <- manifest_create(
    `system-dependencies` = list(git = '*')
  )
  result <- manifest_check_system(path)
  expect_equal(result$status, 'OK')
})

test_that('`manifest_check_system()` works with missing system dependency', {
  path <- manifest_create(
    `system-dependencies` = list(nonexistentdependency = '*')
  )
  result <- manifest_check_system(path)
  expect_equal(result$status, 'MISSING')
})

test_that('`manifest_check_system()` handles no system dependencies', {
  path <- manifest_create()
  expect_invisible(manifest_check_system(path))
})
