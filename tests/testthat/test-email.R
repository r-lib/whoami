
context("Email address")

test_that("Email address works", {

  with_mock(
    `whoami::email_address` = function(...) "jambajoe@joe.joe",
    expect_equal(email_address(), "jambajoe@joe.joe")
  )
  
})
