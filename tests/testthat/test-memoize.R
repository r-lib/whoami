
context("memoize")

test_that("can memoize", {
  called <- 0L
  f <- function(x)  called <<- called + 1L
  f <- memoize_first(f)
  f("a")
  f("a")
  f("a")
  expect_equal(called, 1L)

  f("b")
  f("b")
  f("a")
  expect_equal(called, 2L)
})

test_that("non-string argument", {
  called <- 0L
  f <- function(x)  called <<- called + 1L
  f <- memoize_first(f)
  f(NULL)
  f(123)
  f(letters)
  expect_equal(called, 3L)

  f("a")
  f("a")
  f("a")
  expect_equal(called, 4L)

  f(NULL)
  f(123)
  f(letters)
  expect_equal(called, 7L)
})
