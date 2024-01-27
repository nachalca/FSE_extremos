\name{KolmogorovSmirnov}
\alias{KolmogorovSmirnov}
\title{Computation of the Kolmogorov-Smirnov statistics}
\description{
  This function computes the Kolmogorov-Smirnov statistics (KS).
}
\usage{
KolmogorovSmirnov(S1, S2)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{S1}{Vector containing the sample 1 from which CDF1 will be estimated.}
  \item{S2}{Vector containing the sample 2 from which CDF2 will be estimated.}
}
\details{
  CDF1 and CDF2 are estimated empirically to compute the Kolmogorov-Smirnov statistics.
}
\value{
  Returns the value of the Kolmogorov-Smirnov statistics.
}
\references{D.A. Darling. "The Kolmogorov-Smirnov, Cramer-von Mises tests", Ann. Math. Statist., 28 (4), 823-838 (1957).

P.-A. Michelangeli, M. Vrac, H. Loukos. "Probabilistic downscaling approaches: Application to wind cumulative distribution functions", Geophys. Res. Lett.,  doi:10.1029/2009GL038401, 2009.}
\author{P.-A. Michelangeli (pam@climpact.com) and M. Vrac (mathieu.vrac@lsce.ipsl.fr)}
\seealso{\code{\link{CramerVonMisesTwoSamples}},\code{\link{CDFt}} }
\examples{}
\keyword{univar}
