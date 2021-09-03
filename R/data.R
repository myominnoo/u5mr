#' Coale-Demeny Life Table Models (1983)
#'
#' The Coale-Demeny life tables consist of four sets of models, each representing
#' a distinct mortality pattern. Each model is arranged in terms of 25 mortality
#' levels, associated with different expectations of life at birth for females in
#' such a way that `e0` of 20 years corresponds to level 1 and `e0` of 80 years
#' corresponds to level 25.
#'
#' The four underlying mortality patterns of the Coale-Demeny models are called
#' "North", "South", "East" and "West". They were identified through statistical
#' and graphical analysis of a large number of life tables of acceptable quality,
#' mainly for European countries.
#'
#' @docType data
#'
#' @usage data(coale_demeny_ltm)
#'
#' @format An object of class \code{"list"}; consist of four `data.frame` for
#' `male`, `female` and `both sexes`.
#'
#' @keywords datasets
#'
#' @references United Nations Population Studies (1990) Step-by-Step Guide
#' to the Estimation of Child Mortality No.107:1-83
#' (\href{https://www.un.org/en/development/desa/population/publications/pdf/mortality/stepguide_childmort.pdf}{United Nations})
#'
#' @source \href{https://www.un.org/development/desa/pd/content/step-step-guide-estimation-child-mortality}{United Nations Population Division}
"coale_demeny_ltm"


#' Coefficients for the estimation of child mortality multipliers `k(i)`
#'
#' This is a dataset of coefficients used to estimate multipliers `k(i)` in the TRUSSELL version of
#' the BRASS method, using Coale-Demeny mortality models.
#'
#' @details
#' The basic estimation equation for the Trussell method (equation 4.3) is
#'
#' \deqn{k(i) = a(i) + b(i) P(1)/P(2) + c(i) P(2)/P(3)}
#'
#' - extracted from page 26, Table 4.
#'
#' @docType data
#'
#' @usage data(coeff_trussell_ki)
#'
#' @format A data frame
#'
#' @keywords datasets
#'
#' @references United Nations Population Studies (1990) Step-by-Step Guide
#' to the Estimation of Child Mortality No.107:1-83
#' (\href{https://www.un.org/en/development/desa/population/publications/pdf/mortality/stepguide_childmort.pdf}{United Nations})
#'
#' @source \href{https://www.un.org/development/desa/pd/content/step-step-guide-estimation-child-mortality}{United Nations Population Division}
"coeff_trussell_ki"


#' Coefficients for the estimation of the time reference `t(i)`
#'
#' This is a dataset of coefficients used to derive the time reference `t(i)`,
#' for values of `q(x)` in the TRUSSELL version of
#' the BRASS method, using Coale-Demeny mortality models.
#'
#' @details
#' The basic estimation equation for the Trussell method (equation 4.3) is
#'
#' \deqn{t(i) = a(i) + b(i) P(1)/P(2) + c(i) P(2)/P(3)}
#'
#' The names of coefficients were changed from `e`, `f`, and `g` to `a`, `b`, and `c`.
#'
#' - extracted from page 27, Table 5.
#'
#' @docType data
#'
#' @usage data(coeff_trussell_ti)
#'
#' @format A data frame
#'
#' @keywords datasets
#'
#' @references United Nations Population Studies (1990) Step-by-Step Guide
#' to the Estimation of Child Mortality No.107:1-83
#' (\href{https://www.un.org/en/development/desa/population/publications/pdf/mortality/stepguide_childmort.pdf}{United Nations})
#'
#' @source \href{https://www.un.org/development/desa/pd/content/step-step-guide-estimation-child-mortality}{United Nations Population Division}
"coeff_trussell_ti"


#' Bangladesh 1974
#'
#' The data gathered by the 1974 Bangladesh Retrospective Survey of Fertility and Mortality
#' can be used to demonstrate the estimation of child mortality from summary birth histories
#' using the Trussell version of the BRASS method and the Coale-Demeny life table models
#' \code{\link{coale_demeny_ltm}}.
#'
#' - extracted from Display 6 on page 28 and Display 7 on page 29.
#'
#' @docType data
#'
#' @usage data(bangladesh)
#'
#' @format A data frame
#'
#' @keywords datasets
#'
#' @references United Nations Population Studies (1990) Step-by-Step Guide
#' to the Estimation of Child Mortality No.107:1-83
#' (\href{https://www.un.org/en/development/desa/population/publications/pdf/mortality/stepguide_childmort.pdf}{United Nations})
#'
#' @source \href{https://www.un.org/development/desa/pd/content/step-step-guide-estimation-child-mortality}{United Nations Population Division}
"bangladesh"




#' Panama 1976
#'
#' The data gathered by a survey in Panama between August and October 1976
#' can be used to demonstrate the estimation of child mortality from summary birth histories
#' using the Trussell version of the BRASS method and the Coale-Demeny life table models
#' \code{\link{coale_demeny_ltm}}.
#'
#' - extracted from Table49 on page 78.
#'
#' @docType data
#'
#' @usage data(panama)
#'
#' @format A data frame
#'
#' @keywords datasets
#'
#' @references United Nations (1983) Manual X: indirect techniques for demographic
#' estimation. Population studies No. 81. New York: United Nations Department
#' of International Economic and Social Affairs
#' (\href{https://unstats.un.org/unsd/demographic/standmeth/handbooks/Manual_X-en.pdf}{United Nations})
#'
#' @source \href{https://www.un.org/en/development/desa/population/publications/manual/estimate/demographic-estimation.asp}{United Nations Population Division}
"panama"
