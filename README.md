
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Under-Five Child Mortality Estimation using the R Package `u5mr`

<!-- badges: start -->

[![Lifecycle:
maturing](man/figures/lifecycle-maturing.svg)](https://lifecycle.r-lib.org/articles/stages.html)
<!-- badges: end -->

`u5mr` is a open-source R package for estimating the child mortality.
Current implementation includes the Trussell version of the Brass method
using the Coale-Demeny model life tables and supporting datasets of
coefficients and automatic interpolating values between probabilities of
dying at a certain age and model tables.

## Installation

You can install the package from GitHub via the {remotes
package}(<https://remotes.r-lib.org/>):

``` r
remotes::install_github("myominnoo/u5mr")
```

## Usage

The first example is using Bangladesh survey data and model South of the
Coale-Demeny life table.

``` r
library(u5mr)

## Using Bangladesh survey data to estimate child mortality
data("bangladesh")
bang_both <- u5mr_trussell(bangladesh, sex = "both", model = "south", year = 1974.3)
#>   1. preparing data ...
#>   2. calculating multipliers k(i) and q(x) ...
#>   3. calculating time reference t(i) and reference date ...
#>   4. Interpolation between qx and Coale-Demeny model for q(5) ...
#>   5. Finalizing the calculation ...
bang_male <- u5mr_trussell(bangladesh, child_born = "male_born",
                 child_dead = "male_dead", sex = "male",
                 model = "south", year = 1974.3)
#>   1. preparing data ...
#>   2. calculating multipliers k(i) and q(x) ...
#>   3. calculating time reference t(i) and reference date ...
#>   4. Interpolation between qx and Coale-Demeny model for q(5) ...
#>   5. Finalizing the calculation ...
bang_female <- u5mr_trussell(bangladesh, child_born = "female_born",
                 child_dead = "female_dead", sex = "female",
                 model = "south", year = 1974.3)
#>   1. preparing data ...
#>   2. calculating multipliers k(i) and q(x) ...
#>   3. calculating time reference t(i) and reference date ...
#>   4. Interpolation between qx and Coale-Demeny model for q(5) ...
#>   5. Finalizing the calculation ...

## plotting all data points
with(bang_both,
    plot(ref_date, q5, type = "b", pch = 19,
         ylim = c(0, .45),
         col = "black", xlab = "Reference date", ylab = "u5MR",
         main = paste0("Under-five mortality, q(5) in Bangladesh, estimated\n",
                       "using model South and the Trussell version of the Brass method")))
with(bang_both, text(ref_date, q5, agegrp, cex=0.65, pos=3,col="purple"))
with(bang_male, lines(ref_date, q5, pch = 18, col = "red", type = "b", lty = 2))
with(bang_female,
    lines(ref_date, q5, pch = 18, col = "blue", type = "b", lty = 3))
legend("bottomright", legend=c("Both sexes", "Male", "Female"),
      col = c("Black", "red", "blue"), lty = 1:3, cex=0.8)
```

<img src="man/figures/README-demo1-1.png" width="150%" />

Below, the second example is demonstrated using Panama survey data and
model West.

``` r
## Using panama survey data to estimate child mortality
data("panama")
pnm_both <- u5mr_trussell(panama, sex = "both", model = "west", year = 1976.5)
#>   1. preparing data ...
#>   2. calculating multipliers k(i) and q(x) ...
#>   3. calculating time reference t(i) and reference date ...
#>   4. Interpolation between qx and Coale-Demeny model for q(5) ...
#>   5. Finalizing the calculation ...
pnm_male <- u5mr_trussell(panama, child_born = "male_born",
                child_dead = "male_dead", sex = "male",
                model = "west", year = 1976.5)
#>   1. preparing data ...
#>   2. calculating multipliers k(i) and q(x) ...
#>   3. calculating time reference t(i) and reference date ...
#>   4. Interpolation between qx and Coale-Demeny model for q(5) ...
#>   5. Finalizing the calculation ...
pnm_female <- u5mr_trussell(panama, child_born = "female_born",
                child_dead = "female_dead", sex = "female",
                model = "west", year = 1976.5)
#>   1. preparing data ...
#>   2. calculating multipliers k(i) and q(x) ...
#>   3. calculating time reference t(i) and reference date ...
#>   4. Interpolation between qx and Coale-Demeny model for q(5) ...
#>   5. Finalizing the calculation ...

## plotting all data points
with(pnm_both,
    plot(ref_date, q5, type = "b", pch = 19,
        ylim = c(0, .2), col = "black", xlab = "Reference date", ylab = "u5MR",
         main = paste0("Under-five mortality, q(5) in Panama, estimated\n",
                       "using model West and the Trussell version of the Brass method")))
with(pnm_both, text(ref_date, q5, agegrp, cex=0.65, pos=3,col="purple"))
with(pnm_male,
    lines(ref_date, q5, pch = 18, col = "red", type = "b", lty = 2))
with(pnm_female,
    lines(ref_date, q5, pch = 18, col = "blue", type = "b", lty = 3))
legend("bottomleft", legend=c("Both sexes", "Male", "Female"),
      col = c("Black", "red", "blue"), lty = 1:3, cex=0.8)
```

<img src="man/figures/README-demo2-1.png" width="150%" />

## Bug Reports / Change Requests

If you encounter a clear bug, please file an issue with a minimal
reproducible example on
[GitHub](https://github.com/myominnoo/u5mr/issues).

## Getting Help

For questions and other discussion, please directly email me
[dr.myominnoo@gmail.com](mailto::dr.myominnoo@gmail.com).

## Citation

To cite the u5mr package in publications use

      @Manual{Myo2020space,
        title = {Under-Five Child Mortality Estimation using the R Package u5mr},
        author = {Myo Minn Oo},
        year = {2021}
      }

------------------------------------------------------------------------

Please note that this project is looking for contributors. By
participating in this project, you agree to abide by its terms with
[Contributor Code of
Conduct](https://www.contributor-covenant.org/version/1/0/0/code-of-conduct/),
version 1.0.0, available at
<https://www.contributor-covenant.org/version/1/0/0/code-of-conduct/>.
