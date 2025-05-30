\name{CDFt.Weibull}
\title{Downscaling or bias correction of Weibull CDF through CDF-transformation}
\usage{
CDFt.Weibull(ObsRp, DataGp, DataGf, npas = 100, dev = 2, ini.sh.O = 1, ini.sc.O = 1, ini.sh.Gp = 1, ini.sc.Gp = 1, ini.sh.Gf = 1, ini.sc.Gf = 1, ini.sh.GpC = 1, ini.sc.GpC = 1, ini.sh.GfC = 1, ini.sc.GfC = 1)
}
\alias{CDFt.Weibull}
\description{
  Downscales (or corrects the model outputs) Weibull cumulative distribution function (CDF) of a climate variable from large- to local-scale by applying a equivalent of proportionality transformation :
  i.e., based on a Weibull CDF representing a variable at large scale (i.e., low spatial resolution) and the equivalent Weibull CDF at a local scale (e.g., modeled at a weather station), this method finds a mathematical transformation allowing to go from the large- to the local-scale CDF. Hence, when a new large-scale Weibull CDF is given, a new local-scale CDF (not necessarily Weibull) is downscaled based on this transformation.
}
\arguments{
  \item{ObsRp}{Observed time series of the variable (e.g., temperature) at the local scale to be used for estimation of the calibration local-scale Weibull CDF.}
  \item{DataGp}{Large-scale time series to be used for estimation of the calibration large-scale Weibull CDF.}
  \item{DataGf}{Large-scale time series to be used for estimation of the large-scale Weibull CDF to be downscaled.}
  \item{npas}{Number of "cuts" for which quantiles will be estimated (Default is 100).}
  \item{dev}{Coefficient of development (of the difference between the mean of the large-scale historical data and the mean of the large-scale future data to be downscaled). This development is used to extend range of data on which the quantiles will be calculated for the CDF to be downscaled (Default is 2).}
  \item{ini.sh.O}{Initialisation value for the Weibull CDF shape parameter of the observed (i.e., present local-scale) data.}
  \item{ini.sc.O}{Same as ini.sh.O but for the scale parameter.}
  \item{ini.sh.Gp}{Same as ini.sh.O but for the large-scale present data.}
  \item{ini.sc.Gp}{Same as ini.sh.Gp but for the scale parameter.}
  \item{ini.sh.Gf}{Same as ini.sh.Gp but for the large-scale future data.}
  \item{ini.sc.Gf}{Same as ini.sh.Gf but for the scale parameter.}
  \item{ini.sh.GpC}{Same as ini.sh.Gp for the "centered" present large-scale data.}
  \item{ini.sc.GpC}{Same as ini.sh.GpC but for the scale parameter.}
  \item{ini.sh.GfC}{Same as ini.sh.GpC but for future "centered" large-scale data.}
  \item{ini.sc.GfC}{Same as ini.sh.GfC but for the scale parameter.}
}
\value{
  CDFt.Weibull returns a list with components
  \item{DS}{Downscaled time series generated by "Quantile-matching" method performed between large-scale Weibull CDF to be downscaled, and the local-scale downscaled CDF. Note that the length of this array is equal to the length of DataGf}
  \item{x}{an array containing values of the variable (e.g., temperature) where the downscaled (and other) CDF has been estimated.}
  \item{FRp}{an array containing the values of the local-scale Weibull CDF used for calibration, evaluated at the points in x.}
  \item{FGp}{an array containing the values of the large-scale Weibull CDF used for calibration, evaluated at the points in x.}
  \item{FGf}{an array containing the values of the large-scale Weibull CDF used for downscaling, evaluated at the points in x.}
  \item{FRf}{an array containing the values of the downscaled CDF evaluated at the points in x.}
}
\details{This function provides a parametric (Weibull) version of the CDFt function. For details on the (empirical) mathematical formulation of the transformation used to translate the large-scale CDF to the local-scale one, see the reference below. Note that in this R package, the large-scale data (i.e., DataGp and DataGf) are automatically transformed to have the same mean as the ObsRp time series. This avoid to get out of the range of applicability of the CDFt method. However, the large-scale output CDFs have their initial mean (i.e., not centered).

P.-A. Michelangeli, M. Vrac, H. Loukos. "Probabilistic downscaling approaches: Application to wind cumulative distribution functions", Geophys. Res. Lett.,  doi:10.1029/2009GL038401, 2009.
}
\author{M. Vrac (mathieu.vrac@lsce.ipsl.fr)}
\seealso{\code{\link{CDFt}}, \code{\link{CDFt.Gaussian}}, \code{\link{CDFt.GPD}}, \code{\link{CDFt.Gamma.Dirac}}}
\examples{
## Example

### Generation of example data
O <- rweibull(2100,shape=2,scale=1)
Gp <- rweibull(300,shape=3,scale=1)
Gf <- rweibull(300,shape=1,scale=2)

### Call of the CDFt.Weibull method
CG = CDFt.Weibull(O,Gp,Gf)

x <- CG$x
FGp <- CG$FGp
FGf <- CG$FGf
FRp <- CG$FRp
FRf <- CG$FRf
ds <- CG$DS

### Plot the results
par(mfrow=c(1,2))

plot(x, FGp,type="l",lty=2,ylim=c(0,1),xlab="x",ylab="CDF(x)")
lines(x,FGf,type="l",lty=2,col=2)
lines(x,FRp,type="l")
lines(x,FRf,type="l",col=2)

# Compare FRf with empirical CDF from downscaled values
e = ecdf(ds)
lines(x,e(x),type="l",lty=2,col=4)

plot(Gf,ds,xlab="Large-scale data", ylab="Downscaled data")

}
\keyword{math}
\keyword{distribution}
\keyword{univar}
\keyword{models}
