
context("GitHub username")

test_that("Github username works", {

  skip_on_cran()
  
  tr <- try(
    silent = TRUE,
    gh <- httr::GET(
      "https://api.github.com",
      httr::add_headers("user-agent" = "https://github.com/r-lib/whoami"),
      httr::timeout(1.0)
    )
  )

  if (inherits(tr, "try-error") || gh$status_code != 200) {
    skip("No internet, skipping")
  }

  mockery::stub(gh_username, "email_address", "csardi.gabor@gmail.com")
  expect_equal(gh_username(), "gaborcsardi")
})
