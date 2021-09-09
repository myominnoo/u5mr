#' Categorize age into two yearly intervals, needed to apply MAP method
#'
#' @description
#'
#' `r lifecycle::badge("stable")`
#'
#' `agegroup_as_map()` converts `age` variable into a character vector named
#' `agegroup` with two yearly intervals between 14 and 50.
#'
#' @param data processed data
#' @param age age of women
#'
#' @return `data.frame`
#'
#' @examples
#'
#' ## demonstrating using microdata
#' data("microdata")
#' ## get only female
#' md <- subset(microdata, sex == 2)
#' ## get those aged between 14 and 50
#' md <- subset(md, age >= 15 & age < 50)
#' ## create age group into 2-yearly intervals
#' md <- agegroup_as_map(md, age = "age")
#'
#' summary(md$agegroup)
#' table(md$agegroup)
#'
#' @export
agegroup_as_map <- function(data, age = "age") {
  age <- data[[age]]
  start_age <- floor(age/2) * 2
  end_age <- start_age + 1
  start_age[age >= 15 & age <= 17] <- 15
  end_age[age >= 15 & age <= 17] <- 17
  data$agegroup <-  paste0(start_age, "-", end_age)
  return(data)
}
