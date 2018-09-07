


# whoami

[![Linux Build Status](https://travis-ci.org/r-lib/whoami.svg?branch=master)](https://travis-ci.org/r-lib/whoami)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/r-lib/whoami?svg=true)](https://ci.appveyor.com/project/gaborcsardi/whoami)
[![](http://www.r-pkg.org/badges/version/whoami)](http://www.r-pkg.org/pkg/whoami)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/whoami)](http://www.r-pkg.org/pkg/whoami)
[![Coverage Status](https://img.shields.io/codecov/c/github/r-lib/whoami/master.svg)](https://codecov.io/github/r-lib/whoami?branch=master)

> Username, full name, email address, GitHub username of the current user

For the username it tries the `LOGNAME`, `USER`, `LNAME` and
`USERNAME` environment variables first. If these are all unset,
or set to an empty string, then it tries running `id` on Unix-like
systems and `whoami` on Windows.

For the full name of the user, it queries the system services and
also tries the user's global git configuration. On Windows, it tries finding the global git configuration in `Sys.getenv("USERPROFILE")` if it doesn't find it in `Sys.getenv("HOME")` (often "Documents").

For the email address it uses the user's global git configuration. It tries finding the global git configuration in `Sys.getenv("USERPROFILE")` if it doesn't find it in `Sys.getenv("HOME")`.

For the GitHub username it uses the `GITHUB_USERNAME` environment variable then it tries searching on GitHub for the user's email
address.

Related JavaScript packages:
[sindresorhus/username](https://github.com/sindresorhus/username),
[sindresorhus/fullname](https://github.com/sindresorhus/fullname),
[sindresorhus/github-username](https://github.com/sindresorhus/github-username),
[paulirish/github-email](https://github.com/paulirish/github-email).

## Installation


```r
devtools::install_github("r-lib/whoami")
```

## Usage


```r
library(whoami)
username()
```

```
#> [1] "gaborcsardi"
```

```r
fullname()
```

```
#> [1] "Gabor Csardi"
```

```r
email_address()
```

```
#> [1] "csardi.gabor@gmail.com"
```

```r
gh_username()
```

```
#> [1] "gaborcsardi"
```

```r
whoami()
```

```
#>                 username                 fullname            email_address 
#>            "gaborcsardi"           "Gabor Csardi" "csardi.gabor@gmail.com" 
#>              gh_username 
#>            "gaborcsardi"
```

## License

MIT © [Gábor Csárdi](http://gaborcsardi.org)
