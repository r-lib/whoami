
context("Email address")

test_that("Email address works", {

  mockery::stub(email_address, "system", "jambajoe@joe.joe")
  expect_equal(email_address(), "jambajoe@joe.joe")
})

test_that("EMAIL env var", {
  expect_equal(
    withr::with_envvar(c("EMAIL" = "bugs.bunny@acme.com"), email_address()),
    "bugs.bunny@acme.com")
})
