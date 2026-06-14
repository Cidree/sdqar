
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

.assert_bbox_coord <- function(coord, ..., op = "==") { # nocov start
  nms  <- sapply(rlang::ensyms(...), rlang::as_label)
  objs <- list(...)

  if (length(objs) < 2L) {
    cli::cli_abort("At least two objects must be provided.")
  }

  if (op != "==" && length(objs) > 2L) {
    cli::cli_abort(c(
      "{.code op = \"{op}\"} requires exactly two objects.",
      "i" = "Use {.code op = \"==\"} to compare more than two objects."
    ))
  }

  vals    <- vapply(
    seq_along(objs),
    function(i) .bbox_extract(objs[[i]], nms[[i]])[[coord]],
    numeric(1L)
  )
  val_ref <- vals[[1L]]

  op_fn        <- match.fun(op)
  mismatch_idx <- which(!op_fn(vals[-1L], val_ref)) + 1L

  if (length(mismatch_idx) > 0L) {
    bullets <- vapply(mismatch_idx, function(i) {
      paste0("{.arg ", nms[[i]], "}: ", coord, "=", vals[[i]])
    }, character(1L))
    names(bullets) <- rep("x", length(bullets))

    if (op == "==") {
      cli::cli_abort(c(
        "Not all objects share the same {coord} as {.arg {nms[[1L]]}} ({coord}={val_ref}).",
        bullets
      ))
    } else {
      op_label <- c(
        "<=" = "less than or equal to",
        "<"  = "less than",
        ">=" = "greater than or equal to",
        ">"  = "greater than"
      )[[op]]
      cli::cli_abort(c(
        "{.arg {nms[[2L]]}} {coord} ({vals[[2L]]}) is not {op_label} {.arg {nms[[1L]]}} {coord} ({val_ref}).",
        bullets
      ))
    }
  }

  invisible(TRUE)
} # nocov end

.geom_type_extract <- function(x, arg) { # nocov start
  if (inherits(x, c("sf", "sfc"))) {
    return(toupper(unique(as.character(sf::st_geometry_type(x)))))
  }
  if (inherits(x, "SpatVector")) {
    # terra::geomtype() cannot distinguish POINT from MULTIPOINT etc.; convert
    # to sf to obtain precise WKT type names.
    return(toupper(unique(as.character(sf::st_geometry_type(sf::st_as_sf(x))))))
  }
  if (inherits(x, "duckspatial_df")) {
    return(toupper(duckspatial::ddbs_geometry_type(x)))
  }
  cli::cli_abort(c(
    "{.arg {arg}} has unsupported class {.cls {class(x)[1]}}.",
    "i" = "Supported: {.cls sf}, {.cls SpatVector}, {.cls duckspatial_df}.",
    "i" = "{.cls SpatRaster} has no vector geometry type."
  ))
} # nocov end

.datum_name <- function(crs) { # nocov start
  wkt <- crs$wkt
  if (is.null(wkt) || is.na(wkt)) return(NA_character_)

  # Use regexec() so the capture group extracts only the name inside the quotes,
  # avoiding the trailing " that sub()-based stripping leaves behind.

  # Projected CRS: geodetic base is named in BASEGEOGCRS["name"]
  m <- regmatches(wkt, regexec('BASEGEOGCRS\\["([^"]+)"', wkt, perl = TRUE))[[1L]]
  if (length(m) >= 2L) return(m[[2L]])

  # Geographic CRS (incl. ensemble datums like ETRS89)
  m <- regmatches(wkt, regexec('GEOG(?:RAPHIC)?CRS\\["([^"]+)"', wkt, perl = TRUE))[[1L]]
  if (length(m) >= 2L) return(m[[2L]])

  NA_character_
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
