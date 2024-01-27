\name{quantileGPD}
\title{This function is for internal use and is not meant to be called by
the user. It returns a function calculating the inverse GPD CDF for any probability p, based on the location (mu), shape (xi), and scale (sc) given in parameters of quantileGPD.}
\usage{
quantileGPD(mu, xi, sc)
}
\alias{quantileGPD}
\description{
This function is for internal use and is not meant to be called by
the user. It returns a function calculating the inverse GPD CDF for any probability p, based on the location (mu), shape (xi), and scale (sc) given in parameters of quantileGPD.
}
\arguments{
  \item{mu}{Location parameter of the GPD CDF.}
  \item{xi}{Shape parameter of the GPD CDF.}
  \item{sc}{Scale parameter of the GPD CDF.}
}
\value{
Returns a function calculating the inverse GPD CDF for any probability p, based on the location (mu), shape (xi), and scale (sc) given in parameters of quantileGPD.
}
\details{This function is for internal use and is not meant to be called by
the user.}
\keyword{math}
\keyword{distribution}
\keyword{univar}
\keyword{models}
\keyword{internal}


