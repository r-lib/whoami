
context("Full name")

test_that("fullname works via git", {

  with_mock(
    `whoami::fullname` = function(...) "Joe Jamba",
    fn <- fullname()
  )

  expect_equal(fn, "Joe Jamba")

  try(fn <- fullname(), silent = TRUE)

  if (!inherits(fn, "try-error")) {
    expect_equal(class(fn), "character")
    expect_equal(length(fn), 1)
    expect_match(fn, ".*")
  }
  
})
