#' Public order from Brittany (France), 2013-2015.
#'
#' A dataset gathering three years of public order from various
#'   French officials. This dataset is interesting when working with missing data
#'   as we can see some trends for specific groups, but also because missing values
#'   are coded with three differents terminology: a classic NA, a blank (""), or
#'   a "Non disponible" (which means "non available").
#'   (\url{https://breizh-sba.opendatasoft.com/explore/dataset/marches-publics-collectivites-bretonnes/information/}).
#'
#'
#' @name breizh
#' @docType data
#' @usage data(breizh)
#' @source \url{{https://breizh-sba.opendatasoft.com/explore/dataset/marches-publics-collectivites-bretonnes/information/}
#' @keywords datasets
#' @examples
#'
#' library(naniar)
#' # Visualise the missingness in variables
#' gg_miss_var(breizh)
#' # Summary of missingness
#' miss_var_summary(breizh)
#' \dontrun{
#' # Replace to NA when the variable is "Non disponible"
#' df <- replace_with_na_all(data = breizh,
#'                     .funs = ~.x == "Non disponible")
#' }

"breizh"
