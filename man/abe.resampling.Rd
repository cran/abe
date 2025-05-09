% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/abe.R
\name{abe.resampling}
\alias{abe.resampling}
\title{Resampled Augmented Backward Elimination}
\usage{
abe.resampling(
  fit,
  data = NULL,
  include = NULL,
  active = NULL,
  tau = 0.05,
  exact = FALSE,
  criterion = c("alpha", "AIC", "BIC"),
  alpha = 0.2,
  type.test = c("Chisq", "F", "Rao", "LRT"),
  type.factor = NULL,
  num.resamples = 100,
  type.resampling = c("Wallisch2021", "bootstrap", "mn.bootstrap", "subsampling"),
  prop.sampling = 0.5,
  save.out = c("minimal", "complete"),
  parallel = FALSE,
  seed = NULL,
  ...
)
}
\arguments{
\item{fit}{An object of class `"lm"`, `"glm"`, `"logistf"`, `"coxph"`, or `"survreg"` representing the fit.
Note, the functions should be fitted with argument `x=TRUE` and `y=TRUE` (or `model=TRUE` for `"logistf"` objects).}

\item{data}{data frame used when fitting the object `fit`.}

\item{include}{a vector containing the names of variables that will be included in the final model. These variables are used as passive variables during modeling. These variables might be exposure variables of interest or known confounders.
They will never be dropped from the working model in the selection process,
but they will be used passively in evaluating change-in-estimate criteria of other variables.
Note, variables which are not specified as include or active in the model fit are assumed to be active and passive variables.}

\item{active}{a vector containing the names of active variables. These less important explanatory variables will only be used as active,
but not as passive variables when evaluating the change-in-estimate criterion.}

\item{tau}{Value that specifies the threshold of the relative change-in-estimate criterion. Default is set to 0.05.}

\item{exact}{Logical, specifies if the method will use exact change-in-estimate or approximated. Default is set to FALSE, which means that the method will use approximation proposed by Dunkler et al.
Note, setting to TRUE can severely slow down the algorithm, but setting to FALSE can in some cases lead to a poor approximation of the change-in-estimate criterion.}

\item{criterion}{String that specifies the strategy to select variables for the blacklist.
Currently supported options are significance level `'alpha'`, Akaike information criterion `'AIC'` and Bayesian information criterion `'BIC'`.
If you are using significance level, in that case you have to specify the value of 'alpha' (see parameter `alpha`). Default is set to `"alpha"`.}

\item{alpha}{Value that specifies the level of significance as explained above. Default is set to 0.2.}

\item{type.test}{String that specifies which test should be performed in case the `criterion = "alpha"`.
Possible values are `"F"` and `"Chisq"` (default) for class `"lm"`, `"Rao"`, `"LRT"`, `"Chisq"` (default), `"F"` for class `"glm"` and `"Chisq"` for class `"coxph"`. See also \link{drop1}.}

\item{type.factor}{String that specifies how to treat factors, see details, possible values are `"factor"` and `"individual"`.}

\item{num.resamples}{number of resamples.}

\item{type.resampling}{String that specifies the type of resampling. Possible values are `"Wallisch2021"`, `"bootstrap"`, `"mn.bootstrap"`, `"subsampling"`. Default is set to `"Wallisch2021"`. See details.}

\item{prop.sampling}{Sampling proportion. Only applicable for `type.boot="mn.bootstrap"` and `type.boot="subsampling"`, defaults to 0.5. See details.}

\item{save.out}{String that specifies if only the minimal output of the refitted models (`save.out="minimal"`) or the entire object (`save.out="complete"`) is to be saved. Defaults to `"minimal"`}

\item{parallel}{Logical, specifies if the calculations should be run in parallel `TRUE` or not `FALSE`. Defaults to `FALSE`. See details.}

\item{seed}{Numeric, a random seed to be used to form re-sampled datasets. Defaults to `NULL`. Can be used to assure complete reproducibility of the results, see Examples.}

\item{...}{Further arguments. Currently, this is primarily used to warn users about arguments that are no longer supported.}
}
\value{
an object of class `abe` for which `summary`, `plot` and `pie.abe` functions are available.
A list with the following elements:

`coefficients` a matrix of coefficients of the final models obtained after performing ABE on re-sampled datasets; if using  `type.resampling="Wallisch2021"`, these models are obtained by using bootstrap.

`coefficients.wallisch` if using `type.resampling="Wallisch2021"` the coefficients of the final models obtained after performing ABE using resampling with `prop.sampling` equal to 0.5; `NULL` when using any other option in `type.resampling`.

`models` the final models obtained after performing ABE on re-sampled datasets, each object in the list is of the same class as `fit`; if using  `type.resampling="Wallisch2021"`, these models are obtained by using bootstrap. These are only returned if `save.out = "complete"`.

`models.wallisch` similar as `models`; if using `type.resampling="Wallisch2021"` the coefficients and terms of the final models obtained after performing ABE using resampling with `prop.sampling` equal to 0.5; `NULL` when using any other option in `type.resampling`. These are only returned if `save.out = "complete"`.

`model.parameters` a dataframe of alpha and tau values corresponding to the resampled models.

`num.boot` number of resampled datasets

`criterion` criterion used when constructing the black-list

`all.vars` a list of variables used when estimating `fit`

`fit.global` the initial model. In earlier versions of the package this parameter was called `fit.or`.

`misc` the parameters of the call to `abe.resampling`

`id` the rows of the data which were used when refitting the model; the list with elements `id1` (the rows used to refit the model; when `type.resampling="Wallisch2021"` these are based on bootstrap) and `id2` (`NULL` unless when `type.resampling="Wallisch2021"` in which case these are the rows used to refit the models based on subsampling)
}
\description{
Performs Augmented backward elimination on re-sampled data sets using different bootstrap and re-sampling techniques.
}
\details{
`type.resampling` can be `bootstrap` (n observations drawn from the original data with replacement), `mn.bootstrap` (m out of n observations drawn from the original data with replacement), `subsampling` (m out of n observations drawn from the original data without replacement, where m is `prop.sampling*n` ) and `"Wallisch2021"`. When using `"Wallisch2021"` the resampling is done twice: first time using bootstrap (these results are contained in `models`) and the second time using resampling with `prop.sampling` equal to 0.5 (these results are contained in `models.wallisch`); see Wallisch et al. (2021).

When using `parallel=TRUE` parallel backend must be registered before using `abe.resampling`. The parallel backends available will be system-specific; see [foreach()] for more details.

In earlier versions, \code{abe} used to include an \code{exp.beta} argument. This is not supported anymore. Instead, the function now uses the exponential change in estimate for logistic and Cox models only.
}
\examples{
# simulate some data and fit a model

set.seed(1)
n = 100
x1 <- runif(n)
x2 <- runif(n)
x3 <- runif(n)
y<- -5 + 5 * x1 + 5 * x2 + rnorm(n, sd = 5)
dd <- data.frame(y = y, x1 = x1, x2 = x2, x3 = x3)
fit <- lm(y ~ x1 + x2 + x3, x = TRUE, y = TRUE, data = dd)

# use ABE on 10 re-samples considering different
# change-in-estimate thresholds and significance levels

fit.resample1 <- abe.resampling(fit, data = dd, include = "x1",
active = "x2", tau = c(0.05, 0.1), exact = TRUE,
criterion = "alpha", alpha = c(0.2, 0.05), type.test = "Chisq",
num.resamples = 10, type.resampling = "Wallisch2021")

names(summary(fit.resample1))
summary(fit.resample1)$var.rel.frequencies
summary(fit.resample1)$model.rel.frequencies
summary(fit.resample1)$var.coefs[1]
summary(fit.resample1)$pair.rel.frequencies[1]
print(fit.resample1)

# use ABE on 10 bootstrap re-samples considering different
# change-in-estimate thresholds and significance levels

fit.resample2 <- abe.resampling(fit, data = dd, include = "x1",
active = "x2", tau = c(0.05, 0.1),exact = TRUE,
criterion = "alpha", alpha = c(0.2, 0.05), type.test = "Chisq",
num.resamples = 10, type.resampling = "bootstrap")

summary(fit.resample2)

# use ABE on 10 subsamples randomly selecting 50\% of subjects
# considering different change-in-estimate thresholds and
# significance levels

fit.resample3 <- abe.resampling(fit, data = dd, include = "x1",
active = "x2", tau = c(0.05,0.1), exact = TRUE,
criterion = "alpha", alpha = c(0.2, 0.05), type.test = "Chisq",
num.resamples = 10, type.resampling = "subsampling", prop.sampling = 0.5)

summary(fit.resample3)

#Assure reproducibility of the results

fit.resample.1 <- abe.resampling(fit,  data = dd, include = "x1",
active = "x2", tau = c(0.05, 0.1), exact = TRUE,
criterion = "alpha", alpha = c(0.2, 0.05), type.test = "Chisq",
num.resamples = 10, type.resampling = "Wallisch2021")

fit.resample.2 <- abe.resampling(fit, data = dd, include = "x1",
active = "x2", tau = c(0.05, 0.1), exact = TRUE,
criterion = "alpha", alpha = c(0.2, 0.05), type.test = "Chisq",
num.resamples = 10, type.resampling = "Wallisch2021")

#since different seeds are used, fit.resample.1 and fit.resample.2 give different results

fit.resample.3 <- abe.resampling(fit, data = dd, include = "x1",
active = "x2", tau = c(0.05, 0.1), exact = TRUE,
criterion = "alpha", alpha = c(0.2, 0.05), type.test = "Chisq",
num.resamples = 10, type.resampling = "Wallisch2021", seed = 87982)

fit.resample.4 <- abe.resampling(fit, data = dd, include = "x1",
active = "x2", tau = c(0.05, 0.1), exact = TRUE,
criterion = "alpha", alpha = c(0.2, 0.05), type.test = "Chisq",
num.resamples = 10, type.resampling = "Wallisch2021", seed = 87982)

#now fit.resample.3 and fit.resample.4 give exactly the same results

#' Example to run parallel computation on windows, using all but 2 cores

#library(doParallel)
#N_CORES <- detectCores()
#cl <- makeCluster(N_CORES-2)
#registerDoParallel(cl)
#fit.resample <- abe.resampling(fit, data = dd, include = "x1", active = "x2",
#tau = c(0.05, 0.1), exact = TRUE, criterion = "alpha", alpha = c(0.2, 0.05),
#type.test = "Chisq", num.resamples = 50, type.resampling = "Wallisch2021")
#stopCluster(cl)
}
\references{
Daniela Dunkler, Max Plischke, Karen Lefondre, and Georg Heinze. Augmented Backward Elimination: A Pragmatic and Purposeful Way to Develop Statistical Models. PloS One, 9(11):e113677, 2014, [doi:](doi:10.1371/journal.pone.0113677).

Riccardo De Bin, Silke Janitza, Willi Sauerbrei and Anne-Laure Boulesteix. Subsampling versus Bootstrapping in Resampling-Based Model Selection for Multivariable Regression. Biometrics 72, 272-280, 2016, [doi:](doi:10.1111/biom.12381).

Wallisch Christine, Dunkler Daniela, Rauch Geraldine, de Bin Ricardo, Heinze Georg. Selection of Variables for Multivariable Models: Opportunities and Limitations in Quantifying Model Stability by Resampling. Statistics in Medicine 40:369-381, 2021, [doi:](doi:10.1002/sim.8779).
}
\seealso{
\link{abe}, \link{summary.abe}, \link{print.abe}, \link{plot.abe}, \link{pie.abe}
}
\author{
Rok Blagus, \email{rok.blagus@mf.uni-lj.si}

Daniela Dunkler

Sladana Babic
}
