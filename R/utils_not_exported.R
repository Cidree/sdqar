
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

.assert_bbox_coord <- function(coord, ...) { # nocov start
  nms  <- sapply(rlang::ensyms(...), rlang::as_label)
  objs <- list(...)

  if (length(objs) < 2L) {
    cli::cli_abort("At least two objects must be provided.")
  }

  vals    <- vapply(
    seq_along(objs),
    function(i) .bbox_extract(objs[[i]], nms[[i]])[[coord]],
    numeric(1L)
  )
  val_ref <- vals[[1L]]

  mismatch_idx <- which(vals[-1L] != val_ref) + 1L

  if (length(mismatch_idx) > 0L) {
    bullets <- vapply(mismatch_idx, function(i) {
      paste0("{.arg ", nms[[i]], "}: ", coord, "=", vals[[i]])
    }, character(1L))
    names(bullets) <- rep("x", length(bullets))

    cli::cli_abort(c(
      "Not all objects share the same {coord} as {.arg {nms[[1L]]}} ({coord}={val_ref}).",
      bullets
    ))
  }

  invisible(TRUE)
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
