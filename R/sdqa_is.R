#' Check if a spatial object has a geographic CRS
#'
#' @description
#' Returns `TRUE` if `x` has a geographic (lon/lat) CRS, `FALSE` otherwise.
#' Returns `FALSE` when the CRS is projected or undefined.
#'
#' @param x A spatial object. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#'
#' @return A single logical value.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc     <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#' nc_utm <- st_transform(nc, 32617)
#'
#' sdqa_is_geographic(nc)
#' sdqa_is_geographic(nc_utm)
sdqa_is_geographic <- function(x) {
  arg <- rlang::as_label(rlang::ensym(x))
  isTRUE(sf::st_is_longlat(.crs_extract(x, arg)))
}

#' Check if a spatial object has a projected CRS
#'
#' @description
#' Returns `TRUE` if `x` has a projected (Cartesian) CRS, `FALSE` otherwise.
#' Returns `FALSE` when the CRS is geographic or undefined.
#'
#' @param x A spatial object. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#'
#' @return A single logical value.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc     <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#' nc_utm <- st_transform(nc, 32617)
#'
#' sdqa_is_projected(nc)
#' sdqa_is_projected(nc_utm)
sdqa_is_projected <- function(x) {
  arg <- rlang::as_label(rlang::ensym(x))
  isFALSE(sf::st_is_longlat(.crs_extract(x, arg)))
}
