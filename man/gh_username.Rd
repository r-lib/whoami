% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/whoami.R
\name{gh_username}
\alias{gh_username}
\title{Find the current user's GitHub username}
\usage{
gh_username(token = NULL, fallback = NULL)
}
\arguments{
\item{token}{GitHub token to use. By default it uses
the \code{GITHUB_TOKEN} environment variable, if set.
If unset, uses the \code{GITHUB_PAT} environment
variable, if set.}

\item{fallback}{If not \code{NULL} then this value is returned
if the GitHub username cannot be found, instead of triggering an
error.}
}
\value{
GitHub username, or an error is thrown if it cannot be found.
}
\description{
Uses the \code{GITHUB_USERNAME} global variable or searches on GitHub,
for the user's email address, see
\code{\link{email_address}}.
}
\details{
This function caches the username in the current R session, and if the
email address of the user is unchanged, it does not perform another
GitHub query.
}
\examples{
\dontrun{
gh_username()
}

}
\seealso{
Other user names: 
\code{\link{email_address}()},
\code{\link{fullname}()},
\code{\link{username}()},
\code{\link{whoami}()}
}
\concept{user names}
