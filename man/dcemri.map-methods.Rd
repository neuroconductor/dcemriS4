% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dcemri_map.R
\docType{methods}
\name{dcemri.map}
\alias{dcemri.map}
\alias{dcemri.map,array-method}
\title{Pharmacokinetic Modeling of Dynamic Contrast-Enhanced MRI Data}
\usage{
dcemri.map(conc, ...)

\S4method{dcemri.map}{array}(
  conc,
  time,
  img.mask,
  model = "extended",
  aif = NULL,
  user = NULL,
  ab.ktrans = c(0, 1),
  ab.kep = ab.ktrans,
  ab.vp = c(1, 19),
  ab.tauepsilon = c(1, 1/1000),
  maxit = 5000,
  samples = FALSE,
  multicore = FALSE,
  verbose = FALSE,
  ...
)
}
\arguments{
\item{conc}{Matrix or array of concentration time series (last dimension
must be time).}

\item{...}{Additional parameters to the function.}

\item{time}{Time in minutes.}

\item{img.mask}{Mask matrix or array. Voxels with \code{mask=0} will be
excluded.}

\item{model}{is a character string that identifies the type of compartmental
model to be used.  Acceptable models include: 
\describe{
\item{\dQuote{weinmann}}{Tofts & Kermode AIF convolved with single 
compartment model} 
\item{\dQuote{extended}}{Weinmann model extended with additional vascular
compartment (default)} 
\item{\dQuote{orton.exp}}{Extended model using Orton's exponential AIF} 
\item{\dQuote{kety.orton.exp}}{Kety model using Orton's exponential AIF} 
\item{\dQuote{orton.cos}}{Extended model using Orton's raised cosine AIF} 
\item{\dQuote{kety.orton.cos}}{Kety model using Orton's raised cosine AIF} 
}}

\item{aif}{is a character string that identifies the parameters of the type
of arterial input function (AIF) used with the above model.  Acceptable
values are: \code{tofts.kermode} (default) or \code{fritz.hansen} for the
\code{weinmann} and \code{extended} models; \code{orton.exp} (default) or
\code{user} for the \code{orton.exp} model and \code{orton.exp} model;
\code{user} for the \code{orton.cos} model and \code{orton.cos} model.}

\item{user}{Vector of AIF parameters.  For Tofts and Kermode: \eqn{a_1},
\eqn{m_1}, \eqn{a_2}, \eqn{m_2}; for Orton \emph{et al.}: \eqn{A_b},
\eqn{\mu_b}, \eqn{A_g}, \eqn{\mu_g}.}

\item{ab.ktrans}{Mean and variance parameter for Gaussian prior on
\eqn{\log(K^{trans})}.}

\item{ab.kep}{Mean and variance parameter for Gaussian prior on
\eqn{\log(k_{ep})}.}

\item{ab.vp}{Hyper-prior parameters for the Beta prior on \eqn{v_p}{vp}.}

\item{ab.tauepsilon}{Hyper-prior parameters for observation error Gamma
prior.}

\item{maxit}{The maximum number of iterations for the optimization
procedure.}

\item{samples}{If \code{TRUE} output includes samples drawn from the
posterior distribution for all parameters.}

\item{multicore}{If \code{TRUE} algorithm is parallelized using
\pkg{multicore}.}

\item{verbose}{Logical variable (default = \code{FALSE}) that allows
text-based feedback during execution of the function.}
}
\value{
Parameter estimates and their standard errors are provided for the
masked region of the multidimensional array.  The multi-dimensional arrays
are provided in \code{nifti} format.

They include: 
\item{ktrans}{Transfer rate from plasma to the extracellular,
extravascular space (EES).} 
\item{kep}{Rate parameter for transport from the EES to plasma.} 
\item{ve}{Fractional occupancy by EES (the ratio between ktrans and kep).} 
\item{vp}{Fractional occupancy by plasma.}
\item{sigma2}{The residual sum-of-squares from the model fit.}
\item{time}{Acquisition times (for plotting purposes).
} 
Note, not all parameters are available under all models choices.
}
\description{
Maximum-a-posteriori (MAP) estimation for single compartment models is
performed using literature-based or user-specified arterial input functions.
}
\details{
Implements \emph{maximum a posteriori} (MAP) estimation for the Bayesian
model in Schmid \emph{et al.} (2006).
}
\examples{

data("buckley")
xi <- seq(5, 300, by=5)
img <- array(t(breast$data)[,xi], c(13,1,1,60))
mask <- array(TRUE, dim(img)[1:3])
time <- buckley$time.min[xi]

## MAP estimation with extended Kety model and Fritz-Hansen default AIF
fit.map.vp <- dcemri.map(img, time, mask, aif="fritz.hansen")
## Nonlinear regression with extended Kety model and Fritz-Hansen default AIF
fit.lm.vp <- dcemri.lm(img, time, mask, aif="fritz.hansen")

plot(breast$ktrans, fit.map.vp$ktrans, xlim=c(0,1), ylim=c(0,1),
     xlab=expression(paste("True ", K^{trans})),
     ylab=expression(paste("Estimated ", K^{trans})))
points(breast$ktrans, fit.lm.vp$ktrans, pch=3)
abline(0, 1, lwd=2, col=2)
legend("bottomright", c("MAP Estimation (fritz.hansen)",
                        "Levenburg-Marquardt (fritz.hansen)"), pch=c(1,3))

## MAP estimation with Kety model and Fritz-Hansen default AIF
fit.map <- dcemri.map(img, time, mask, model="weinmann", aif="fritz.hansen")
## Nonlinear regression with Kety model and Fritz-Hansen default AIF
fit.lm <- dcemri.lm(img, time, mask, model="weinmann", aif="fritz.hansen")

cbind(breast$kep, fit.lm$kep[,,1], fit.lm.vp$kep[,,1], fit.map$kep[,,1],
      fit.map.vp$kep[,,1])
cbind(breast$ktrans, fit.lm$ktrans[,,1], fit.lm.vp$ktrans[,,1],
      fit.map$ktrans[,,1], fit.map.vp$ktrans[,,1])

}
\references{
Schmid, V., Whitcher, B., Padhani, A.R., Taylor, N.J. and Yang,
G.-Z.  (2006) Bayesian methods for pharmacokinetic models in dynamic
contrast-enhanced magnetic resonance imaging, \emph{IEEE Transactions on
Medical Imaging}, \bold{25} (12), 1627-1636.
}
\seealso{
\code{\link{dcemri.lm}}, \code{\link{dcemri.bayes}}
}
\author{
Volker Schmid \email{volkerschmid@users.sourceforge.net}
}
\keyword{models}
