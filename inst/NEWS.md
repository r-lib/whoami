
# 1.3.0

* Now `fullname()` uses the `FULLNAME` environment variable, if set.

* Now `email_address()` uses the `EMAIL` environment variable, if set.

# 1.2.0

* `gh_username()` caches the result, separately for each email address.

* `gh_username()` uses the `GITHUB_USERNAME` environment variable, if it
  it is set (#6, @maelle)

* On Windows, `gh_fullname()` and `gh_email_address()` try finding the
  global git configuration in `Sys.getenv("USERPROFILE")` if it is not
  found in `Sys.getenv("HOME")` (#7, @maelle)

* `gh_username()` also tries the `GITHUB_PAT` environment variable
  to find a GitHub token, after `GITHUB_TOKEN` (#9, @maelle)

# 1.1.2

Maintainence release, no user visible changes

# 1.1.1

Maintainence release, no user visible changes

# 1.1.0

* Fallbacks, instead of errors, #2

# 1.0.0

First release
