#' Estimating under-five mortality using Coale-Demeny life table models
#'
#' @description
#'
#' `r lifecycle::badge("stable")`
#'
#' `u5mr_trussell()` uses the Trussell version of the BRASS method
#' and calculates under-five mortality estimates.
#'
#' @param data processed data
#' @param women total number of women
#' @param child_born children ever born
#' @param child_dead children dead
#' @param agegrp age grouping
#' @param model Coale-Demeny life table model:
#' `north`, `south`, `east`, and `west`
#' @param sex indicates sex-specific estimates: `both`, `male`, and `female`
#' @param svy_year end of the survey
#'
#'
#' @details
#' T. J. Trussell developed the Trussell version of the Brass method to estimate
#' child mortality using summary birth history (United Nations,  1983b, Chapter III).
#' It is based on the Coale-Demeny life table models of either North, South, East, or West.
#'
#' \strong{Computational Procedure}
#'
#' Step 1. Preparing the dataset
#'
#' The function needs four variables from the input data:
#'
#' a) `agegrp`: age groups representing `15-19`, `20-24`, `25-29`, `30-34`,
#' `35-39`, `40-44`, and `45-49`.
#'
#' b) `women`: the total number of women in the age group irrespective of their marital
#' or reporting status
#'
#' c) `child_born`: the total number of children ever borne by these women
#'
#' d) `child_dead`: the number of children dead reported by these women
#'
#' Step 1.1. Calculation of average parity per woman `P(i)`
#'
#' \deqn{P(i) = CEB(i) / FP(i)}
#'
#' - `CEB(i)` is the total number of children ever borne by these women
#'
#' - `FP(i)` is the total number of women in the
#' age group irrespective of their marital or reporting status.
#'
#' Step 1.2. Calculation of the proportions dead among children ever borne `D(i)`
#'
#' \deqn{D(i) = CD(i) / CEB(i)}
#'
#' - `CD(i)` is the number of children dead for women of age group i
#'
#'
#'
#' Step 2. Calculating the multipliers `k(i)` and probabilities of dying by age x `q(x)`
#'
#' \deqn{k(i) = a(i) + b(i) P(1)/P(2) + c(i) P(2)/P(3)}
#'
#' where `a(i)`, `b(i)`, and `c(i)` are coefficients estimated by regression analysis of
#' simulated model cases, and `P(1)/P(2)` and `P(2)/P(3)` are parity ratios.
#'
#' \deqn{q(x) = k(i) x D(i)}
#'
#'
#' Step 3. Calculating the reference dates for `q(x)` and interpolating `q5`
#'
#' Under conditions of steady mortality change over time, a reference time `t(i)`
#' can be estimated for each `q(x)`.
#'
#' \deqn{t(i) = a(i) + b(i) P(1)/P(2) + c(i) P(2)/P(3)}
#'
#' Actual dates can be obtained by subtracting `t(i)` from the reference date of
#' the survey or census, expressed in decimal terms.
#'
#'
#' Step 4. Interpolating between `q(x)` and model life table
#'
#' A common index, in this case, under-five mortality `q(5)` can be obtained by
#' conversions of corresponding `q(x)` values to the specified family of
#' the Coale-Demeny life table models. In a given life table family and sex,
#' the first step is to identify the mortality levels with q(x) values that
#' enclose the estimated value \eqn{q^e(x)}.
#'
#' \deqn{q^j(x) > q^e(x) > q^j+1(x)}
#'
#' where \eqn{q^j(x)} and \eqn{q^j+1(x)} are the model values of `q(x)` for
#' levels `j` and `j+1`, and \eqn{q^e(x)} is the estimated value.
#'
#' The desired common index \eqn{q^c(5)}, or `q5` is given by
#'
#'
#' \deqn{q^c(5) = (1.0 - h) x q^j(5) + h x q^e(5)}
#'
#' where h is the interpolation factor calculated in the following way:
#'
#' \deqn{h = q^e(x) - q^j(x) / q^j+1(x) - q^j(x)}
#'
#'
#' Step 5. Finalizing the calculation
#'
#' The final output is combined into a `data.frame`, which contains original dataset
#' as well as statistics produced during the computational procedure.
#'
#' @references
#'
#' 1. United Nations (1990) "Step-by-step guide to the estimation of the child mortality"
#' <https://www.un.org/en/development/desa/population/publications/pdf/mortality/stepguide_childmort.pdf>
#' 2. United Nations (1983) "Manual X indirect techniques for demographic estimation"
#' <https://www.un.org/en/development/desa/population/publications/pdf/mortality/stepguide_childmort.pdf>
#'
#' @return `data.frame`
#'
#' * `agegrp`      - five-year age groups
#' * `women` - total number of women
#' * `child_born`  - total number of children ever born
#' * `child_dead`  - number of children dead
#' * `pi` - average parity
#' * `di` - proportion of dead among children ever born
#' * `ki` - multipliers
#' * `qx` - probabilities of dying at age x
#' * `ti` - time between survey year and interpolated year
#' * `year` - reference year
#' * `h`  - interpolation factor
#' * `q5` - under-five mortality
#'
#' @examples
#'
#'## Using Bangladesh survey data to estimate child mortality
#'data("bangladesh")
#'bang_both <- u5mr_trussell(bangladesh, sex = "both", model = "south", svy_year = 1974.3)
#'bang_male <- u5mr_trussell(bangladesh, child_born = "male_born",
#'                  child_dead = "male_dead", sex = "male",
#'                  model = "south", svy_year = 1974.3)
#'bang_female <- u5mr_trussell(bangladesh, child_born = "female_born",
#'                  child_dead = "female_dead", sex = "female",
#'                  model = "south", svy_year = 1974.3)
#'
#'## plotting all data points
#'with(bang_both,
#'     plot(year, q5, type = "b", pch = 19,
#'          ylim = c(0, .45),
#'          col = "black", xlab = "Reference date", ylab = "u5MR",
#'          main = paste0("Under-five mortality, q(5) in Bangladesh, estimated\n",
#'                        "using model South and the Trussell version of the Brass method")))
#'with(bang_both, text(year, q5, agegrp, cex=0.65, pos=3,col="purple"))
#'with(bang_male,
#'     lines(year, q5, pch = 18, col = "red", type = "b", lty = 2))
#'with(bang_female,
#'     lines(year, q5, pch = 18, col = "blue", type = "b", lty = 3))
#'legend("bottomright", legend=c("Both sexes", "Male", "Female"),
#'       col = c("Black", "red", "blue"), lty = 1:3, cex=0.8)
#'
#'
#'## Using panama survey data to estimate child mortality
#'data("panama")
#'pnm_both <- u5mr_trussell(panama, sex = "both", model = "west", svy_year = 1976.5)
#'pnm_male <- u5mr_trussell(panama, child_born = "male_born",
#'                 child_dead = "male_dead", sex = "male",
#'                 model = "west", svy_year = 1976.5)
#'pnm_female <- u5mr_trussell(panama, child_born = "female_born",
#'                 child_dead = "female_dead", sex = "female",
#'                 model = "west", svy_year = 1976.5)
#'
#'## plotting all data points
#'with(pnm_both,
#'     plot(year, q5, type = "b", pch = 19,
#'         ylim = c(0, .2), col = "black", xlab = "Reference date", ylab = "u5MR",
#'          main = paste0("Under-five mortality, q(5) in Panama, estimated\n",
#'                        "using model West and the Trussell version of the Brass method")))
#'with(pnm_both, text(year, q5, agegrp, cex=0.65, pos=3,col="purple"))
#'with(pnm_male,
#'     lines(year, q5, pch = 18, col = "red", type = "b", lty = 2))
#'with(pnm_female,
#'     lines(year, q5, pch = 18, col = "blue", type = "b", lty = 3))
#'legend("bottomleft", legend=c("Both sexes", "Male", "Female"),
#'       col = c("Black", "red", "blue"), lty = 1:3, cex=0.8)
#'
#' @export
u5mr_trussell <- function(data, women = "women",
                          child_born = "child_born", child_dead = "child_dead",
                          agegrp = "agegrp", model = "west", svy_year = 1976.5, sex) {

  # message("  1. preparing data ... ")

  agegrp <- data[[agegrp]]
  women <- data[[women]]
  child_born <- data[[child_born]]
  child_dead <- data[[child_dead]]

  pi <- child_born / women
  di <- child_dead / child_born
  p1 <- pi[1]
  p2 <- pi[2]
  p3 <- pi[3]

  # message("  2. calculating multipliers k(i) and q(x) ... ")

  ## get Coefficients for estimation of child mortality multipliers k(i)
  ##    TRUSSELL variant TABLE 47 PAGE 77 UN Manual X
  coeff_trussell_ki <- get_coef_data("coeff_trussell_ki")
  t47 <- coeff_trussell_ki[coeff_trussell_ki$model == model, -1]
  ki <- t47$ai + (t47$bi * p1/p2) + (t47$ci * p2/p3)
  qx <- ki * di


  # message("  3. calculating time reference t(i) and reference date ... ")

  ## get Coefficients for estimation of the reference period, t(x)
  ##    TRUSSELL variant TABLE 47 PAGE 77 UN Manual X
  coeff_trussell_ti <- get_coef_data("coeff_trussell_ti")
  t48 <- coeff_trussell_ti[coeff_trussell_ti$model == model, -1]
  ti <- t48$ai + (t48$bi * p1/p2) + (t48$ci * p2/p3)
  year <- round(svy_year - ti, 1)

  # message("  4. Interpolation between qx and Coale-Demeny model for q(5) ... ")
  ## interpolation between qx and model for common index q5\
  coale_demeny_ltm <- get_coef_data("coale_demeny_ltm")
  inter <- coale_demeny_ltm[[paste0(model, "_", sex)]]

  age_index <- paste0("q", c(1, 2, 3, 5, 10, 15, 20))

  h <- vector("numeric", length = 7L)
  q5 <- sapply(1:7, function(x) {
    q <- qx[x]
    c <- inter[[age_index[x]]]
    qj <- c[ c < q]
    qj1 <- c[ q < c]
    if (length(qj) == 0) qj <- 0

    h[x] <<- (q - qj[1]) / (qj1[length(qj1)] - qj[1])

    qj5 <- inter$q5[c == qj[1]]
    qj51 <- inter$q5[c == qj1[length(qj1)]]
    (1 - h[x]) * qj5 + (h[x] * qj51)
  })

  # message("  5. Finalizing the calculation ... ")
  data.frame(agegrp, women, child_born, child_dead,
             pi, di, ki, qx, ti, year, h, q5)
}




# HELPERS -----------------------------------------------------------------

get_coef_data <- function(x) {
  eval(parse(text = x))
}

