
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
  mockery::stub(gh_username, "lookup_gh_username", "gaborcsardi")
  expect_equal(gh_username(), "gaborcsardi")

  # when there's an environment variable
  mockery::stub(gh_username, "Sys.getenv", function(x) {
    if (x == "GITHUB_USERNAME") {
      "anuser"
    } else {
      Sys.getenv(x)
    }
  })
  expect_equal(gh_username(), "anuser")
})
