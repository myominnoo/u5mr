#' Estimating under-five mortality using Maternal Age Period-derived method (MAP)
#'
#' @description
#'
#' `r lifecycle::badge('stable')`
#'
#' `u5mr_period()` uses the maternal age period-derived method (MAP) through summary
#' birth history information and maternal age (or time since first birth) to
#' calculate the under-five mortality estimates.
#'
#'
#' @param data preprocessed data
#' @param child_born children ever born
#' @param child_dead children dead
#' @param agegrp age grouping or time since first birth
#' @param svy_wt sample weights: if not available, use 1.
#' @param iso3 the `iso3` code of the country from which the survey data come
#' @param svy_region region of the country from which the survey data come
#'
#' - `ASIA`
#' - `LATC` (Latin America and the Caribbean)
#' - `NAME` (North Africa and Middle East)
#' - `SASE` (Sub-Saharan Africa, South/East)
#' - `SAWC` (Sub-Saharan Africa, West/Central)
#'
#' @param svy_year end of the survey
#'
#' @details
#'
#' In this period-derived method, under-five mortality and reference time are estimated
#' through distributions of child birthdays and death days for different categories
#' of mothers, stratified by maternal information such as region, age, and number
#' of child ever born or dead. These distributions are used to find the expected number
#' of children ever born and dead in every year prior to the survey (up to 25 years) for
#' a mother in each particular strata.
#'
#' By applying these distributions to each mother in each strata, and summing
#' across all strata, expected numbers of children ever born (CEB) and child dead
#' (CD) are generated for each year prior to the survey. The ratio of CD and
#' CEB for each year can then be calculated.
#'
#'
#' \strong{Computational Procedure}
#'
#' The formulas used to quantify MAP method is as follows:
#'
#'
#' logit(\out{5q0<sub>tjk</sub>}) = \eqn{\beta}\out{<sup>0</sup><sub>t</sub>} +
#' \out{U<sub>tj</sub>} + \eqn{\beta}\out{<sup>1</sup><sub>t</sub>} x
#' logit(\out{CD<sub>tjk</sub>} / \out{CEB<sub>tjk</sub>}) +
#' \eqn{\epsilon}\out{<sub>tjk</sub>}
#'
#' where
#'
#' t = index of calendar time \eqn{\epsilon} (0, 24)
#' j = country
#' k = survey
#' \out{CD<sub>i</sub>} = total dead children in time bin `t`
#' \out{CEB<sub>i</sub>} = total children ever born in time bin `t`
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
#' * `ref_time`  - time between survey year and interpolated year
#' * `year`  - reference year
#' * `q5` - under-five mortality
#'
#' @examples
#'
#' data("microdata")
#' ## get only female
#' md <- subset(microdata, sex == 2)
#' ## get those aged between 14 and 50
#' md <- subset(md, age >= 15 & age < 50)
#' ## create age group into 2-yearly intervals
#' md <- agegroup_as_map(md, age = "age")
#' u5mr_period(md, child_born = "ceb", child_dead = "cd", agegrp = "agegroup",
#'             svy_wt = "svy_wt", iso3 = "KHM",
#'             svy_region = "ASIA", svy_year = 1234)
#'
#' @export
u5mr_period <- function(data, child_born = "child_born", child_dead = "child_dead",
                        agegrp = "agegrp", svy_wt = "svy_wt", iso3 = "KHM",
                        svy_region = "ASIA", svy_year = 1234) {
  ceb <- data[[child_born]]
  cd <- data[[child_dead]]
  agegroup <- data[[agegrp]]
  svy_wt <- data[[svy_wt]]

  mcd <- data.frame(ceb, cd, agegroup, svy_wt, svy_year)

  ## obtain expected number of children ever born
  ## for each year prior to the survey
  ceb <- mcd[mcd$ceb != 0, ]
  ceb <- with(ceb, aggregate(svy_wt, list(agegroup, ceb), FUN = sum))
  names(ceb) <- c("agegroup", "ceb", "wtper")
  ceb$region <- svy_region

  birthdays_distribution <- get_coef_data("birthdays_distribution")
  ceb <- merge.data.frame(ceb, birthdays_distribution,
                          by = c("region", "agegroup", "ceb"))
  ceb <- sapply(0:24, function(x) {
    tm <- ceb[["wtper"]] * ceb[["ceb"]] * ceb[[paste0("t_", x)]]
    sum(tm, na.rm = TRUE)
  })
  ceb <- data.frame(reftime = c(0:24) + 0.5, ceb)

  ## obtain expected number of dead children
  ## for each year prior to the survey
  cd <- mcd[mcd$cd != 0, ]
  cd <- with(cd, aggregate(svy_wt, list(agegroup, cd), FUN = sum))
  names(cd) <- c("agegroup", "cd", "wtper")
  cd$region <- svy_region

  deathdays_distribution <- get_coef_data("deathdays_distribution")
  cd <- merge.data.frame(cd, deathdays_distribution,
                         by = c("region", "agegroup", "cd"))
  cd <- sapply(0:24, function(x) {
    tm <- cd[["wtper"]] * cd[["cd"]] * cd[[paste0("t_", x)]]
    sum(tm, na.rm = TRUE)
  })
  cd <- data.frame(reftime = c(0:24) + 0.5, cd)

  map <- merge.data.frame(cd, ceb, by = c("reftime"))
  map$iso3 <- iso3

  ## Apply MAP method
  map$cdceb <- map$cd / map$ceb
  map$logitcdceb <- log(map$cdceb/(1-map$cdceb))


  coef_map_5q0 <- get_coef_data("coef_map_5q0")
  coef_map_re <- get_coef_data("coef_map_re")
  map <- merge.data.frame(map, coef_map_5q0, by = "reftime")
  map <- merge.data.frame(map, coef_map_re, by = c("iso3", "reftime"))

  ## Calculate the logit of 5q0 and inverse the logit version
  map$logit_5q0 = map$coef_intercept + map$random_effect +
    map$coef_logitcdceb * map$logitcdceb
  map$q5 <- exp(map$logit_5q0 ) / (1 + exp(map$logit_5q0 ))

  ## calculate year
  map$year <- svy_year - map$reftime

  ## order the variables
  map$ref_time <- map$reftime
  map <- map[, c("ref_time", "year", "q5")]
  map <- with(map, map[order(ref_time, year, q5),])
  row.names(map) <- NULL

  return(map)
}


# HELPERS -----------------------------------------------------------------

get_coef_data <- function(x) {
  eval(parse(text = x))
}
