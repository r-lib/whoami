
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

#' User name of the current user
#'
#' Tries the \code{LOGNAME}, \code{USER}, \code{LNAME}, \code{USERNAME}
#' environment variables first. Then it tries the `id` command on Unix-like
#' platforms and `whoami` on Windows.
#'
#' @return The user name of the current user.
#'
#' @family user names
#' @export
#' @examples
#' \dontrun{
#' username()
#' }

username <- function() {

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
    stop("Unknown platform, cannot determine username")
  }
  stop("Cannot determine username")
}

#' Full name of the current user
#'
#' Tries system full names and git configuration as well.
#'
#' @return The full name of the current user.
#'
#' @family user names
#' @export
#' @examples
#' \dontrun{
#' fullname()
#' }

fullname <- function() {
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
    if (ok(user)) return(user)

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
  if (ok(user)) return(user)

  stop("Cannot determine full name")
}

#' Email address of the current user
#'
#' It tries to find it in the user's global git configuration.
#'
#' @return Email address on success. Otherwise an error is thrown.
#' 
#' @family user names
#' @export
#' @examples
#' \dontrun{
#' email_address()
#' }

email_address <- function() {
  email <- try(suppressWarnings({
    email <- system("git config --global user.email", intern = TRUE)
    email <- str_trim(email)
  }), silent = TRUE)
  if (ok(email)) return(email)

  stop("Cannot get email address")
}

#' Find the current user's GitHub username
#'
#' Searches on GitHub, for the user's email address, see
#' \code{\link{email_address}}.
#'
#' @param token GitHub token to use. By default it uses
#'   the \code{GITHUB_TOKEN} environment variable, if set.
#' @return GitHub username, or an error is thrown if it cannot be found.
#' 
#' @family user names
#' @export
#' @importFrom httr GET add_headers stop_for_status content
#' @importFrom jsonlite fromJSON
#' @examples
#' \dontrun{
#' gh_username()
#' }

gh_username <- function(token = Sys.getenv("GITHUB_TOKEN")) {
  email <- try(email_address(), silent = TRUE)
  if (ok(email)) {
    if (! grepl('@', email)) {
      stop("This does not seem to be an email address")
    }
    url <- URLencode(paste0(gh_url, "/search/users?q=", email,
                            " in:email"))

    auth <- character()
    if (token != "") auth <- c("Authorization" = paste("token", token))

    resp <- GET(
      url,
      add_headers("user-agent" = "https://github.com/gaborcsardi/whoami",
                  'accept' = 'application/vnd.github.v3+json',
                  .headers = auth)
    )
    stop_for_status(resp)
    data <- fromJSON(content(resp, as = "text"), simplifyVector = FALSE)
    if (data$total_count == 0) {
      stop("Cannot find GitHub username for email")
    }

    return(data$items[[1]]$login)
  }

  stop("Cannot get GitHub username")
}

#' User name and full name of the current user
#'
#' Calls \code{\link{username}} and \code{\link{fullname}}.
#'
#' @return A named character vector with two entries: \code{username} and
#'   \code{fullname}.
#'
#' @family user names
#' @export
#' @examples
#' \dontrun{
#' whoami()
#' }

whoami <- function() {
  c("username" = username(),
    "fullname" = fullname(),
    "email_address" = email_address(),
    "gh_username" = gh_username()
    )
}
