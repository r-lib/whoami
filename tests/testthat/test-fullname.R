
context("Full name")

test_that("fullname works", {

  fn <- fullname()
  expect_equal(class(fn), "character")
  expect_equal(length(fn), 1)
  expect_match(fn, ".*")
  
})
