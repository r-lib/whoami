
.onLoad <- function(libname, pkgname) {
  lookup_gh_username <<- memoize_first(lookup_gh_username)
}

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

memoize_first <- function(fun) {
  fun
  cache <- list()
  dec <- function(arg, ...) {
    if (!is_string(arg)) return(fun(arg, ...))
    if (is.null(cache[[arg]])) cache[[arg]] <<- fun(arg, ...)
    cache[[arg]]
  }
  dec
}

gh_url <- "https://api.github.com"

ok <- function(x) {
  !inherits(x, "try-error") &&
    !is.null(x) &&
    length(x) == 1 &&
    x != "" &&
    !is.na(x)
}

`%or%` <- function(l, r) {
  if (ok(l)) l else r
}

str_trim <- function(x) {
  gsub("\\s+$", "", gsub("^\\s+", "", x))
}

fallback_or_stop <- function(fallback, msg) {
  if (!is.null(fallback)) {
    fallback
  } else {
    stop(msg)
  }
}

#' User name of the current user
#'
#' Tries the \code{LOGNAME}, \code{USER}, \code{LNAME}, \code{USERNAME}
#' environment variables first. Then it tries the `id` command on Unix-like
#' platforms and `whoami` on Windows.
#'
#' @param fallback If not \code{NULL} then this value is returned
#'   if the username cannot be found, instead of triggering an error.
#' @return The user name of the current user.
#'
#' @family user names
#' @export
#' @examples
#' \dontrun{
#' username()
#' }

username <- function(fallback = NULL) {

  e <- Sys.getenv()
  user <- e["LOGNAME"] %or% e["USER"] %or% e["LNAME"] %or% e["USERNAME"]
  if (ok(user)) return(as.vector(user))

  if (.Platform$OS.type == "unix") {
    user <- try(str_trim(system("id -un", intern = TRUE)), silent = TRUE)
    if (ok(user)) return(user)
  } else if (.Platform$OS.type == "windows") {
    user <- try({
      user <- system("whoami", intern = TRUE, show.output.on.console = FALSE)
      user <- sub("^.*\\\\", "", str_trim(user))
    }, silent = TRUE)
    if (ok(user)) return(user)
  } else {
    return(fallback_or_stop(
      fallback,
      "Unknown platform, cannot determine username"
    ))
  }
  fallback_or_stop(fallback, "Cannot determine username")
}

#' Full name of the current user
#'
#' Uses the \code{FULLNAME} environment variable, if set.
#' Otherwise tries system full names and the git configuration as well.
#'
#' @param fallback If not \code{NULL} then this value is returned
#'   if the full name of the user cannot be found, instead of
#'   triggering an error.
#' @return The full name of the current user.
#'
#' @family user names
#' @export
#' @examples
#' \dontrun{
#' fullname()
#' }

fullname <- function(fallback = NULL) {

  if ((x <- Sys.getenv("FULLNAME", "")) != "") return(x)

  if (Sys.info()["sysname"] == "Darwin") {
    user <- try({
      user <- system("id -P", intern = TRUE)
      user <- str_trim(user)
      user <- strsplit(user, ":")[[1]][8]
    }, silent = TRUE)
    if (ok(user)) return(user)

    user <- try({
      user <- system("osascript -e \"long user name of (system info)\"",
                     intern = TRUE)
      user <- str_trim(user)
    }, silent = TRUE)
    if (ok(user)) return(user)

  } else if (.Platform$OS.type == "windows") {
    user <- try(suppressWarnings({
      user <- system("git config --global user.name", intern = TRUE)
      user <- str_trim(user)
    }), silent = TRUE)
    if (ok(user)){
      return(user)
    } else{
      user <- try(suppressWarnings({
        user <- system(paste0("git config --file ",
                              file.path(Sys.getenv("USERPROFILE"),
                                        ".gitconfig"),
                              " user.name"), intern = TRUE)
        user <- str_trim(user)
      }), silent = TRUE)
      if(ok(user)){
        return(user)
      }
    }

    user <- try({
      username <- username()
      user <- system(
        paste0("wmic useraccount where name=\"", username,
               "\" get fullname"),
        intern = TRUE
      )
      user <- sub("FullName", "", user)
      user <- str_trim(paste(user, collapse = ""))
    }, silent = TRUE)

    if (ok(user)) return(user)

  } else {
    user <- try({
      user <- system("getent passwd $(whoami)", intern = TRUE)
      user <- str_trim(user)
      user <- strsplit(user, ":")[[1]][5]
      user <- sub(",.*", "")
    }, silent = TRUE)
    if (ok(user)) return(user)

  }

  user <- try(suppressWarnings({
    user <- system("git config --global user.name", intern = TRUE)
    user <- str_trim(user)
  }), silent = TRUE)
  if (ok(user)){
    return(user)
  } else{
    user <- try(suppressWarnings({
      user <- system(paste0("git config --file ",
                            file.path(Sys.getenv("USERPROFILE"),
                                      ".gitconfig"),
                            " user.name"), intern = TRUE)
      user <- str_trim(user)
    }), silent = TRUE)
    if(ok(user)){
      return(user)
    }
  }

  fallback_or_stop(fallback, "Cannot determine full name")
}

#' Email address of the current user
#'
#' If uses the \code{EMAIL} environment variable, if set.
#' Otherwise it tries to find it in the user's global git configuration.
#'
#' @param fallback If not \code{NULL} then this value is returned
#'   if the email address cannot be found, instead of triggering an error.
#' @return Email address on success. Otherwise an error is thrown.
#'
#' @family user names
#' @export
#' @examples
#' \dontrun{
#' email_address()
#' }

email_address <- function(fallback = NULL) {

  if ((x <- Sys.getenv("EMAIL", "")) != "") return(x)

  email <- try(suppressWarnings({
    email <- system("git config --global user.email", intern = TRUE)
    email <- str_trim(email)
  }), silent = TRUE)
  if (ok(email)){
    return(email)
  } else{
    user <- try(suppressWarnings({
      email <- system(paste0("git config --file ",
                            file.path(Sys.getenv("USERPROFILE"),
                                      ".gitconfig"),
                            " user.email"), intern = TRUE)
      email <- str_trim(email)
    }), silent = TRUE)
    if(ok(email)){
      return(email)
    }
  }

  fallback_or_stop(fallback, "Cannot get email address")
}

#' Find the current user's GitHub username
#'
#' Uses the \code{GITHUB_USERNAME} global variable or searches on GitHub,
#'  for the user's email address, see
#' \code{\link{email_address}}.
#'
#' This function caches the username in the current R session, and if the
#' email address of the user is unchanged, it does not perform another
#' GitHub query.
#'
#' @param token GitHub token to use. By default it uses
#'   the \code{GITHUB_TOKEN} environment variable, if set.
#'   If unset, uses the \code{GITHUB_PAT} environment
#'   variable, if set.
#' @param fallback If not \code{NULL} then this value is returned
#'   if the GitHub username cannot be found, instead of triggering an
#'   error.
#' @return GitHub username, or an error is thrown if it cannot be found.
#'
#' @family user names
#' @export
#' @importFrom httr GET add_headers status_code content
#' @importFrom jsonlite fromJSON
#' @importFrom utils URLencode
#' @examples
#' \dontrun{
#' gh_username()
#' }

gh_username <- function(token = NULL,
                        fallback = NULL) {
  # try reading username from global variable
  env_gh_username <- Sys.getenv("GITHUB_USERNAME")
  if (nzchar(env_gh_username)) return(env_gh_username)

  email <- try(email_address(), silent = TRUE)
  if (ok(email)) {
    if (! grepl('@', email)) {
      return(fallback_or_stop(
        fallback,
        "This does not seem to be an email address"
      ))
    }
    lookup_gh_username(email, token)

  } else {
    fallback_or_stop(fallback, "Cannot get GitHub username")
  }
}

lookup_gh_username <- function(email, token) {
  url <- URLencode(paste0(gh_url, "/search/users?q=", email,
                          " in:email"))

  if(is.null(token)){
    token <- Sys.getenv("GITHUB_TOKEN", Sys.getenv("GITHUB_PAT"))
  }

  auth <- character()
  if (token != "") auth <- c("Authorization" = paste("token", token))

  resp <- GET(
    url,
    add_headers("user-agent" = "https://github.com/r-lib/whoami",
                'accept' = 'application/vnd.github.v3+json',
                .headers = auth)
  )
  if (status_code(resp) >= 300) {
    return(fallback_or_stop(fallback, "Cannot find GitHub username"))
  }
  data <- fromJSON(content(resp, as = "text"), simplifyVector = FALSE)
  if (data$total_count == 0) {
    return(
      fallback_or_stop(fallback, "Cannot find GitHub username for email")
    )
  }

  data$items[[1]]$login
}

#' User name and full name of the current user
#'
#' Calls \code{\link{username}} and \code{\link{fullname}}.
#'
#' @return A named character vector with entries: \code{username},
#'   \code{fullname}, \code{email_address}, \code{gh_username}.
#'
#' @family user names
#' @export
#' @examples
#' \dontrun{
#' whoami()
#' }
#' @details
#' For the username it tries the `LOGNAME`, `USER`,
#' `LNAME` and `USERNAME` environment variables first.
#'  If these are all unset, or set to an empty string,
#'  then it tries running `id` on Unix-like
#' systems and `whoami` on Windows.
#'
#' For the full name of the user, it queries the system services
#' and also tries the user's global git configuration.
#' On Windows, it tries finding the global git configuration
#' in `Sys.getenv("USERPROFILE")` if it doesn't find it
#' in `Sys.getenv("HOME")` (often "Documents").
#'
#' For the email address it uses the user's global git
#' configuration. It tries finding the global git
#' configuration in `Sys.getenv("USERPROFILE")`
#' if it doesn't find it in `Sys.getenv("HOME")`.
#'
#' For the GitHub username it uses the `GITHUB_USERNAME`
#' environment variable then it tries searching on GitHub
#' for the user's email address.

whoami <- function() {
  c("username" = username(),
    "fullname" = fullname(),
    "email_address" = email_address(),
    "gh_username" = gh_username()
    )
}
