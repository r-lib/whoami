
context("Full name")

test_that("fullname fallback", {

  mockery::stub(fullname, "system", function(cmd, ...) {
    if (grepl("^git config", cmd)) {
      "Joe Jamba"
    } else {
      NULL
    }
  })

  expect_equal(fullname(), "Joe Jamba")
})

test_that("fullname works", {

  fn <- try(fullname(), silent = TRUE)
  if (!inherits(fn, "try-error")) {
    expect_equal(class(fn), "character")
    expect_equal(length(fn), 1)
    expect_match(fn, ".*")
  }
})

test_that("FULLNAME env var", {
  expect_equal(
    withr::with_envvar(c("FULLNAME" = "Bugs Bunny"), fullname()),
    "Bugs Bunny")
})
