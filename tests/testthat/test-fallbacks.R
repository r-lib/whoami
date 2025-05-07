test_that("username() falls back", {
  local_mocked_bindings(Sys.getenv = function() NULL)
  local_mocked_bindings(system = function(...) stop())
  expect_equal(username(fallback = "foobar"), "foobar")
})

test_that("fullname() falls back", {
  local_mocked_bindings(system = function(...) stop())
  expect_equal(fullname(fallback = "Foo Bar"), "Foo Bar")
})

test_that("email_address() falls back", {
  local_mocked_bindings(system = function(...) stop())
  expect_equal(email_address(fallback = "foo@bar"), "foo@bar")
})

test_that("gh_username() falls back", {
  local_mocked_bindings(email_address = function() "me@example.com")
  expect_equal(gh_username(fallback = "fallback"), "fallback")

  local_mocked_bindings(email_address = function() "not an email")
  expect_equal(gh_username(fallback = "foobar"), "foobar")

  local_mocked_bindings(email_address = function(...) stop())
  expect_equal(gh_username(fallback = "foobar2"), "foobar2")
})
