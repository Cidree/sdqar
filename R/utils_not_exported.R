
.bbox_extract <- function(x, arg) { # nocov start
  if (inherits(x, c("sf", "sfc"))) {
    bb <- sf::st_bbox(x)
    return(c(
      xmin = bb[["xmin"]], ymin = bb[["ymin"]],
      xmax = bb[["xmax"]], ymax = bb[["ymax"]]
    ))
  }
  if (inherits(x, c("SpatRaster", "SpatVector"))) {
    return(c(
      xmin = terra::xmin(x), ymin = terra::ymin(x),
      xmax = terra::xmax(x), ymax = terra::ymax(x)
    ))
  }
  if (inherits(x, "duckspatial_df")) {
    bb <- duckspatial::ddbs_bbox(x)
    return(c(
      xmin = bb[["xmin"]], ymin = bb[["ymin"]],
      xmax = bb[["xmax"]], ymax = bb[["ymax"]]
    ))
  }
  cli::cli_abort(c(
    "{.arg {arg}} has unsupported class {.cls {class(x)[1]}}.",
    "i" = "Supported: {.cls sf}, {.cls SpatRaster}, {.cls SpatVector}, {.cls duckspatial_df}."
  ))
} # nocov end

.crs_extract <- function(x, arg) { # nocov start
  if (inherits(x, c("sf", "sfc"))) {
    return(sf::st_crs(x))
  }
  if (inherits(x, c("SpatRaster", "SpatVector"))) {
    return(sf::st_crs(terra::crs(x)))
  }
  if (inherits(x, "duckspatial_df")) {
    return(duckspatial::ddbs_crs(x))
  }
  cli::cli_abort(c(
    "{.arg {arg}} has unsupported class {.cls {class(x)[1]}}.",
    "i" = "Supported: {.cls sf}, {.cls SpatRaster}, {.cls SpatVector}, {.cls duckspatial_df}."
  ))
} # nocov end
