
context("Email address")

test_that("Email address works", {

  mockery::stub(email_address, "system", "jambajoe@joe.joe")
  expect_equal(email_address(), "jambajoe@joe.joe")
})
