\name{cdfGammaDirac}
\title{This function is for internal use and is not meant to be called by
the user. It returns a function calculating the Gamma.Dirac (i.e., mixture of a Gamma distribution and a point mass in 0) CDF for any x, based on the shape (sh), scale (sc), and probability of the point mass in 0 (p0) given in parameters of cdfGammaDirac.}
\usage{
cdfGammaDirac(sh,sc,p0)
}
\alias{cdfGammaDirac}
\description{
This function is for internal use and is not meant to be called by
the user. It returns a function calculating the Gamma.Dirac CDF for any x, based on the shape (sh), scale (sc), and probability of the point mass in 0 (p0) given in parameters of cdfGammaDirac.
}
\arguments{
  \item{sh}{Shape parameter of the Gamma.Dirac CDF.}
  \item{sc}{Scale parameter of the Gamma.Dirac CDF.}
  \item{p0}{Probability of the point mass in 0 of the Gamma.Dirac CDF.}
}
\value{
Returns a function calculating the Gamma.Dirac CDF for any x, based on the shape (sh), scale (sc), and probability of the point mass in 0 (p0) given in parameters of cdfGammaDirac.
}
\details{This function is for internal use and is not meant to be called by
the user.}
\keyword{math}
\keyword{distribution}
\keyword{univar}
\keyword{models}
\keyword{internal}

