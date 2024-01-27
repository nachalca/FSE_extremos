\name{CramerVonMisesTwoSamples}
\alias{CramerVonMisesTwoSamples}
\title{Computation of the two-sample Cramer-von Mises statistics}
\description{
  This function computes the two-sample Cramer-von Mises statistics U.
}
\usage{
CramerVonMisesTwoSamples(S1, S2)
}
\arguments{
  \item{S1}{Vector containing the sample 1 from which CDF1 will be estimated.}
  \item{S2}{Vector containing the sample 2 from which CDF2 will be estimated.}
}
\value{
  U: The value of the Cramer-von Mises statistics.
}
\details{CDF1 and CDF2 are estimated empirically to compute the two-sample Cramer-von Mises statistics.}
\references{T.W. Anderson "On the distribution of the Two-sample Cramer-von Mises criterion". The Annals of Mathematical Statistics, 33 (3), 1148-1159 (1962).

P.-A. Michelangeli, M. Vrac, H. Loukos. "Probabilistic downscaling approaches: Application to wind cumulative distribution functions", Geophys. Res. Lett.,  doi:10.1029/2009GL038401, 2009.}
\author{P.-A. Michelangeli (pam@climpact.com) and M. Vrac (mathieu.vrac@lsce.ipsl.fr)}
\seealso{\code{\link{KolmogorovSmirnov}},\code{\link{CDFt}}}
\examples{}
\keyword{univar}
