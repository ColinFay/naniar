
<!-- README.md is generated from README.Rmd. Please edit that file -->
naniar
======

[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/njtierney/naniar?branch=master&svg=true)](https://ci.appveyor.com/project/njtierney/naniar) [![Travis-CI Build Status](https://travis-ci.org/njtierney/naniar.svg?branch=master)](https://travis-ci.org/njtierney/naniar)

`naniar` aims to make it easy to summarise, visualise, and manipulate missing data. In the future it will provide functions focussing on how to tidy, transform, visualise, model, and communicate missing data.

Currently it provides

-   Data structures for missing data
    -   `as_shadow`
    -   `bind_shadow`
    -   `gather_shadow`
    -   `is_na`
-   Visualisation methods:
    -   `geom_missing_point`
    -   `gg_missing_var`
-   Numerical summaries:
    -   `n_miss`
    -   `percent_missing_*`
    -   `summary_missing_*`
    -   `table_missing_*`

More detail is provided in this README. For a more formal description, you can read the vignette "building on ggplot2 for exploration of missing values".

`naniar` was previously nammed `ggmissing`. It was changed to `naniar` to reflect the fact that this package is going to be bigger in scope.

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

Data structures for missing data
================================

Representing missing data structure is achieved using the shadow matrix, introduced in [Swayne and Buja](https://www.researchgate.net/publication/2758672_Missing_Data_in_Interactive_High-Dimensional_Data_Visualization). The shadow matrix is the same dimension as the data, and consists of binary indicators of missingness of data values, where missing is represented as "NA", and not missing is represented as "!NA". Although these may be represented as 1 and 0, respectively. This representation can be seen in the figure below, adding the suffix "\_NA" to the variables. This structure can also be extended to allow for additional factor levels to be created. For example 0 indicates data presence, 1 indicates missing values, 2 indicates imputed value, and 3 might indicate a particular type or class of missingness, where reasons for missingness might be known or inferred. The data matrix can also be augmented to include the shadow matrix, which facilitates visualisation of univariate and bivariate missing data visualisations. Another format is to display it in long form, which facilitates heatmap style visualisations. This approach can be very helpful for giving an overview of which variables contain the most missingness. Methods can also be applied to rearrange rows and columns to find clusters, and identify other interesting features of the data that may have previously been hidden or unclear.

![](missingness-data-structures.png)

**Illustration of data structures for facilitating visualisation of missings and not missings**

Visualising missing data
========================

Visualising missing data might sound a little strange - how do you visualise something that is not there? One approach to visualising missing data comes from ggobi and manet, where we replace "NA" values with values 10% lower than the minimum value in that variable. This is provided with the `geom_missing_point()` ggplot2 geom, which we can illustrate by exploring the relationship between Ozone and Solar radiation from the airquality dataset.

``` r

library(ggplot2)

ggplot(data = airquality,
       aes(x = Ozone,
           y = Solar.R)) +
  geom_point()
#> Warning: Removed 42 rows containing missing values (geom_point).
```

![](README-regular-geom-point-1.png)

ggplot2 does not handle these missing values, and we get a warning message about the missing values.

We can instead use the `geom_missing_point()` to display the missing data

``` r

library(naniar)

ggplot(data = airquality,
       aes(x = Ozone,
           y = Solar.R)) +
  geom_missing_point()
```

![](README-geom-missing-point-1.png)

`geom_missing_point()` has shifted the missing values to now be 10% below the minimum value. The missing values are a different colour so that missingness becomes preattentive.

This plays nicely with other parts of ggplot, like faceting - we can split the facet by month:

``` r
p1 <-
ggplot(data = airquality,
       aes(x = Ozone,
           y = Solar.R)) + 
  geom_missing_point() + 
  facet_wrap(~Month, ncol = 2) + 
  theme(legend.position = "bottom")

p1
```

![](README-unnamed-chunk-2-1.png)

And then change the theme, just like you do with any other ggplot graphic

``` r

p1 + theme_bw()  
```

![](README-unnamed-chunk-3-1.png)

You can also look at the proportion of missings in each variable with gg\_missing\_var:

``` r

gg_missing_var(airquality)
```

![](README-unnamed-chunk-4-1.png)

You can also explore the whole dataset of missings using the `vis_miss` function from the [`visdat`](github.com/njtierney/visdat) package.

``` r

# devtools::install_github("njtierney/visdat")
library(visdat)
vis_miss(airquality)
```

![](README-unnamed-chunk-5-1.png)

Another approach can be to use **Univariate plots split by missingness**. We can do this using the `bind_shadow` argument to place the data and shadow side by side. This allows for us to examine univariate distributions according to the presence or absence of another variable.

``` r
library(naniar)

aq_shadow <- bind_shadow(airquality)

aq_shadow
#> # A tibble: 153 × 12
#>    Ozone Solar.R  Wind  Temp Month   Day Ozone_NA Solar.R_NA Wind_NA
#>    <int>   <int> <dbl> <int> <int> <int>   <fctr>     <fctr>  <fctr>
#> 1     41     190   7.4    67     5     1      !NA        !NA     !NA
#> 2     36     118   8.0    72     5     2      !NA        !NA     !NA
#> 3     12     149  12.6    74     5     3      !NA        !NA     !NA
#> 4     18     313  11.5    62     5     4      !NA        !NA     !NA
#> 5     NA      NA  14.3    56     5     5       NA         NA     !NA
#> 6     28      NA  14.9    66     5     6      !NA         NA     !NA
#> 7     23     299   8.6    65     5     7      !NA        !NA     !NA
#> 8     19      99  13.8    59     5     8      !NA        !NA     !NA
#> 9      8      19  20.1    61     5     9      !NA        !NA     !NA
#> 10    NA     194   8.6    69     5    10       NA        !NA     !NA
#> # ... with 143 more rows, and 3 more variables: Temp_NA <fctr>,
#> #   Month_NA <fctr>, Day_NA <fctr>
```

The plot below shows the values of temperature when ozone is present and missing, on the left is a faceted histogram, and on the right is an overlaid density.

``` r

library(ggplot2)

p1 <- ggplot(data = aq_shadow,
       aes(x = Temp)) + 
  geom_histogram() + 
  facet_wrap(~Ozone_NA,
             ncol = 1)

p2 <- ggplot(data = aq_shadow,
       aes(x = Temp,
           colour = Ozone_NA)) + 
  geom_density() 

gridExtra::grid.arrange(p1, p2, ncol = 2)
#> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

![](README-bind-shadow-density-1.png)

Numerical summaries for missing data
====================================

`naniar` provides numerical summaries of missing data. The `percent_missing_*` functions help find the proportion of missing values in the data overall, in cases, or in variables.

``` r

# Proportion elements in dataset that contains missing values
percent_missing_df(airquality)
#> [1] 4.793028
# Proportion of variables that contain any missing values
percent_missing_var(airquality)
#> [1] 33.33333
 # Proportion of cases that contain any missing values
percent_missing_case(airquality)
#> [1] 27.45098
```

We can also look at the number and percent of missings in each case and variable with `summary_missing_case`, and `summary_missing_var`.

``` r

summary_missing_case(airquality)
#> # A tibble: 153 × 3
#>     case n_missing  percent
#>    <int>     <int>    <dbl>
#> 1      1         0  0.00000
#> 2      2         0  0.00000
#> 3      3         0  0.00000
#> 4      4         0  0.00000
#> 5      5         2 33.33333
#> 6      6         1 16.66667
#> 7      7         0  0.00000
#> 8      8         0  0.00000
#> 9      9         0  0.00000
#> 10    10         1 16.66667
#> # ... with 143 more rows
summary_missing_var(airquality)
#> # A tibble: 6 × 3
#>   variable n_missing   percent
#>      <chr>     <int>     <dbl>
#> 1    Ozone        37 24.183007
#> 2  Solar.R         7  4.575163
#> 3     Wind         0  0.000000
#> 4     Temp         0  0.000000
#> 5    Month         0  0.000000
#> 6      Day         0  0.000000
```

Tabulations of the number of missings in each case or variable can be calculated with `table_missing_case` and `table_missing_var`.

``` r

table_missing_case(airquality)
#> # A tibble: 3 × 3
#>   n_missing_in_case n_cases  percent
#>               <int>   <int>    <dbl>
#> 1                 0     111 72.54902
#> 2                 1      40 26.14379
#> 3                 2       2  1.30719
table_missing_var(airquality)
#> # A tibble: 3 × 3
#>   n_missing_in_var n_vars  percent
#>              <int>  <int>    <dbl>
#> 1                0      4 66.66667
#> 2                7      1 16.66667
#> 3               37      1 16.66667
```

All functions can be called at once using `summarise_missingness`, which takes a `data.frame` and then returns a nested dataframe containing the percentages of missing data, and lists of dataframes containing tally and summary information for the variables and cases.

``` r

s_miss <- summarise_missingness(airquality)

s_miss
#> # A tibble: 1 × 7
#>   percent_missing_df percent_missing_var percent_missing_case
#>                <dbl>               <dbl>                <dbl>
#> 1           4.793028            33.33333             27.45098
#> # ... with 4 more variables: table_missing_case <list>,
#> #   table_missing_var <list>, summary_missing_var <list>,
#> #   summary_missing_case <list>

# overall % missing data
s_miss$percent_missing_df
#> [1] 4.793028

# % of variables that contain missing data
s_miss$percent_missing_var
#> [1] 33.33333

# % of cases that contain missing data
s_miss$percent_missing_case
#> [1] 27.45098

# tabulations of missing data across cases
s_miss$table_missing_case
#> [[1]]
#> # A tibble: 3 × 3
#>   n_missing_in_case n_cases  percent
#>               <int>   <int>    <dbl>
#> 1                 0     111 72.54902
#> 2                 1      40 26.14379
#> 3                 2       2  1.30719

# tabulations of missing data across variables
s_miss$table_missing_var
#> [[1]]
#> # A tibble: 3 × 3
#>   n_missing_in_var n_vars  percent
#>              <int>  <int>    <dbl>
#> 1                0      4 66.66667
#> 2                7      1 16.66667
#> 3               37      1 16.66667

# summary information (counts, percentrages) of missing data for variables and cases
s_miss$summary_missing_var
#> [[1]]
#> # A tibble: 6 × 3
#>   variable n_missing   percent
#>      <chr>     <int>     <dbl>
#> 1    Ozone        37 24.183007
#> 2  Solar.R         7  4.575163
#> 3     Wind         0  0.000000
#> 4     Temp         0  0.000000
#> 5    Month         0  0.000000
#> 6      Day         0  0.000000
s_miss$summary_missing_case
#> [[1]]
#> # A tibble: 153 × 3
#>     case n_missing  percent
#>    <int>     <int>    <dbl>
#> 1      1         0  0.00000
#> 2      2         0  0.00000
#> 3      3         0  0.00000
#> 4      4         0  0.00000
#> 5      5         2 33.33333
#> 6      6         1 16.66667
#> 7      7         0  0.00000
#> 8      8         0  0.00000
#> 9      9         0  0.00000
#> 10    10         1 16.66667
#> # ... with 143 more rows
```

Other plotting functions
========================

These dataframes from the tidying functions are then used in these plots

gg\_missing\_var
----------------

``` r

gg_missing_var(airquality)
```

![](README-unnamed-chunk-10-1.png)

gg\_missing\_case
-----------------

``` r

gg_missing_case(airquality)
```

![](README-unnamed-chunk-11-1.png)

gg\_missing\_which
------------------

This shows whether a given variable contains a missing variable. In this case grey = missing. Think of it as if you are shading the cell in, if it contains data.

``` r

gg_missing_which(airquality)
```

![](README-unnamed-chunk-12-1.png)

Future Work
===========

`naniar` will be undergoing more changes over the next 6 months, with plans to have the package in CRAN around the end of 2016.

Other plans to extend the `geom_missing` family to include:

-   1D, univariate distribution plots
-   Categorical variables
-   Bivariate plots: Scatterplots, Density overlays.
-   Provide

Acknowledgements
----------------

Naming credit (once again!) goes to @MilesMcBain, and to @hadley for the rearranged spelling. Also thank you to @dicook for her and @hadley for putting up with my various questions and concerns, mainly around the name.
