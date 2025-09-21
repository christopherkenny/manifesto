test_that('`is_valid_package_name()` works with valid package names', {
  expect_true(is_valid_package_name('dplyr'))
  expect_true(is_valid_package_name('ggplot2'))
  expect_true(is_valid_package_name('data.table'))
})

test_that('`is_valid_package_name()` works with invalid package names', {
  expect_false(is_valid_package_name('dplyr-'))
  expect_false(is_valid_package_name('-dplyr'))
  expect_false(is_valid_package_name('dp_lyr'))
  expect_false(is_valid_package_name('d.'))
})
