#' Estimating under-five mortality using Maternal Age Cohort-derived method (MAC)
#'
#' @description
#'
#' `r lifecycle::badge('stable')`
#'
#' `u5mr_cohort()` uses the maternal age cohort-derived methods (MAC) through summary
#' birth history information and maternal age (or time since first birth) to
#' calculate the under-five mortality estimates.
#'
#' @param data preprocessed data
#' @param women total number of women
#' @param child_born children ever born
#' @param child_dead children dead
#' @param agegrp age grouping or time since first birth
#' @param iso3 the `iso3` code of the country from which the survey data come
#' @param svy_year end of the survey
#'
#'
#' @details
#'
#' In this cohort-derived method, under-five mortality and reference time are estimated
#' through summary birth history information from the mothers and her age or time since
#' her first birth.
#'
#' In case sample weights are available for the mothers, final variables
#' should be multiplied by these weights before summarizing.
#'
#' \strong{Computational Procedure}
#'
#' Two formulas were used to quantify MAC method:
#'
#' \strong{\eqn{5q0} component}
#'
#' logit(\out{5q0<sub>ijk</sub>}) = \eqn{\beta}\out{<sub>0i</sub>} + \out{U<sub>ij</sub>} +
#' \eqn{\beta}\out{<sub>1i</sub>} x logit(\out{CD<sub>ijk</sub>} /
#' \out{CEB<sub>ijk</sub>}) + \eqn{\beta}\out{<sub>2i</sub>} x \out{CEB<sub>ijk</sub>} +
#' \eqn{\beta}\out{<sub>3i</sub>} x PR1 + \eqn{\beta}\out{<sub>4i</sub>} x PR2 +
#' \eqn{\epsilon}\out{<sub>ijk</sub>}
#'
#' where
#'
#' i = 5-year maternal age group \eqn{\epsilon} (15-19, 20-24, ... , 45-49)
#' j = country
#' k = survey
#' \out{CD<sub>i</sub>} = total dead children from maternal age group `i`
#' \out{CEB<sub>i</sub>} = total children ever born from maternal age group `i`
#' PR1 = ratio of parity among maternal age group 15-19 and parity among maternal age
#' group 20-24
#' PR2 = ratio of parity among maternal age group 20-24 and parity among maternal age
#' group 25-29
#' \out{U<sub>ij</sub>} = country-specific random effects
#'
#' All coefficients vary by maternal age group, as indicated by `i` and the random
#' effects also vary by country, as indicated by `j`.
#'
#'
#' \strong{Reference time component}
#'
#' \out{reftime<sub>ijk</sub>} = \eqn{\beta}\out{<sub>0i</sub>} +
#' \eqn{\beta}\out{<sub>1i</sub>} x (\out{CD<sub>ijk</sub>} /
#' \out{CEB<sub>ijk</sub>}) +
#' \eqn{\beta}\out{<sub>2i</sub>} x \out{CEB<sub>ijk</sub>} +
#' \eqn{\beta}\out{<sub>3i</sub>} x PR1 + \eqn{\beta}\out{<sub>4i</sub>} x PR2 +
#' \eqn{\epsilon}\out{<sub>ijk</sub>}
#'
#'
#'
#' @references
#'
#' Rajaratnam JK, Tran LN, Lopez AD, Murray CJL (2010) Measuring Under-Five Mortality: Validation of New Low-Cost Methods. PLOS Medicine 7(4): e1000253.
#' (\doi{10.1371/journal.pmed.1000253}{10.1371/journal.pmed.1000253})
#'
#' @return `data.frame`
#'
#' * `iso3` - total number of women
#' * `svy_year` - total number of children ever born
#' * `agegrp` - five-year age groups
#' * `ref_time`  - time between survey year and interpolated year
#' * `year`  - reference year
#' * `q5` - under-five mortality
#'
#' @examples
#'
#' ## Example using fake survey data from Cambodia
#' data(cambodia)
#' camb <- u5mr_cohort(cambodia, women = "women", child_born = "child_born",
#' child_dead = "child_dead", agegrp = "agegrp", iso3 = "KHM", svy_year = 1234)
#'
#' with(camb,
#'      plot(year, q5 * 1000, type = "b", pch = 19,
#'           col = "black", xlab = "Year", ylab = "U5MR per 1000 live births",
#'           main = paste0("Under-five mortality, q(5) in Bangladesh, estimated\n",
#'                        "using the maternal age cohort-derived method")))
#'
#' @export
u5mr_cohort <- function(data, women = "women",
                        child_born = "child_born", child_dead = "child_dead",
                        agegrp = "agegrp", iso3 = "KHM", svy_year = 2010) {
  agegrp <- data[[agegrp]]
  women <- data[[women]]
  child_born <- data[[child_born]]
  child_dead <- data[[child_dead]]

  pi <- child_born / women
  di <- child_dead / child_born
  logit_di <- log(di / (1 - di))

  pr1 <- pi[1] / pi[2]
  pr2 <- pi[2] / pi[3]

  mac_re <- get_coef_data("coef_mac_re")
  re <- mac_re$re[mac_re$iso3 == iso3]
  ## if there is no country that matches, then re = 0
  if (length(re) == 0) re <- 0

  ## calculate logit 5q0 values
  mac_5q0 <- get_coef_data("coef_mac_5q0")
  logit_5q0 <- mac_5q0$coef_intercept + re + mac_5q0$coef_log_cdceb *
    logit_di + mac_5q0$coef_ceb * pi + mac_5q0$coef_pr1 * pr1 +
    mac_5q0$coef_pr2 * pr2
  ## convert back to normal values by exponentiating
  q5 <- exp(logit_5q0) / (1 + exp(logit_5q0))

  ## calculate reference time
  mac_reftime <- get_coef_data("coef_mac_ti")
  ref_time <- mac_reftime$coef_intercept + mac_reftime$coef_cdceb * di +
    mac_reftime$coef_ceb * pi + mac_reftime$coef_pr1 * pr1 +
    mac_reftime$coef_pr2 * pr2
  year <- svy_year - ref_time

  data.frame(iso3, svy_year, agegrp, ref_time, year, q5)
}



# HELPERS -----------------------------------------------------------------

get_coef_data <- function(x) {
  eval(parse(text = x))
}

