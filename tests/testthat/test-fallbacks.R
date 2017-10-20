
context("Fallbacks")

test_that("username() falls back", {

  mockery::stub(username, "Sys.getenv", NULL)
  mockery::stub(username, "system", function(...) stop())
  expect_equal(username(fallback = "foobar"), "foobar")
})

test_that("fullname() falls back", {

  mockery::stub(fullname, "system", function(...) stop())
  expect_equal(fullname(fallback = "Foo Bar"), "Foo Bar")
})

test_that("email_address() falls back", {

  mockery::stub(email_address, "system", function(...) stop())
  expect_equal(email_address(fallback = "foo@bar"), "foo@bar")
})

test_that("gh_username() falls back", {

  mockery::stub(gh_username, "email_address", "not an email")
  expect_equal(gh_username(fallback = "foobar"), "foobar")

  mockery::stub(gh_username, "email_address", function(...) stop())
  expect_equal(gh_username(fallback = "foobar2"), "foobar2")
})
