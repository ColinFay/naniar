% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/n-prop-miss-complete.R
\name{n_complete}
\alias{n_complete}
\title{Return the number of complete values}
\usage{
n_complete(x)
}
\arguments{
\item{x}{a vector}
}
\value{
numeric number of complete values
}
\description{
A complement to `n_miss``
}
\examples{

n_complete(airquality)
n_complete(airquality$Ozone)

}
