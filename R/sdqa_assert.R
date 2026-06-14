#' Assert that spatial objects share the same bounding box
#'
#' @description
#' Checks whether all objects passed via `...` share an identical bounding box.
#' All objects are compared against the first one. Throws an error at the first
#' mismatch found.
#'
#' @param ... Two or more spatial objects. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#'
#' @return Invisibly returns TRUE. Throws an error if any object
#'   has a different bounding box from the first.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#' nc_sub <- nc[1:50, ]
#'
#' sdqa_assert_bbox(nc, nc)
#'
#' \dontrun{
#' sdqa_assert_bbox(nc, nc_sub)
#' }
sdqa_assert_bbox <- function(...) {

  # 0. Capture argument labels before `...` is evaluated
  nms  <- sapply(rlang::ensyms(...), rlang::as_label)
  objs <- list(...)

  # 1. Validate inputs
  if (length(objs) < 2L) {
    cli::cli_abort("At least two objects must be provided.")
  }

  # 2. Extract bounding box from all objects
  ## .bbox_extract() normalises all backends to a named numeric vector
  ## c(xmin, ymin, xmax, ymax) so identical() comparison works uniformly.
  bboxes   <- Map(.bbox_extract, objs, nms)
  bbox_ref <- bboxes[[1L]]

  # 3. Find every object whose bbox differs from the reference (first object)
  mismatch_idx <- which(
    vapply(bboxes[-1L], function(bb) !identical(bbox_ref, bb), logical(1L))
  ) + 1L

  # 4. Report all mismatches at once in a single error
  if (length(mismatch_idx) > 0L) {
    .fmt_bb <- function(bb) {
      sprintf(
        "xmin=%.6g, ymin=%.6g, xmax=%.6g, ymax=%.6g",
        bb[["xmin"]], bb[["ymin"]], bb[["xmax"]], bb[["ymax"]]
      )
    }
    ref_label <- .fmt_bb(bbox_ref)

    bullets <- vapply(mismatch_idx, function(i) {
      paste0("{.arg ", nms[[i]], "}: ", .fmt_bb(bboxes[[i]]))
    }, character(1L))
    names(bullets) <- rep("x", length(bullets))

    cli::cli_abort(c(
      "Not all objects share the same bounding box as {.arg {nms[[1L]]}} ({ref_label}).",
      bullets
    ))
  }

  invisible(TRUE)
}

#' Assert that spatial objects share the same CRS
#'
#' @description
#' Checks whether all objects passed via `...` share an identical Coordinate
#' Reference System (CRS). All objects are compared against the first one.
#' Throws an error at the first mismatch found.
#'
#' @param ... Two or more spatial objects. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#'
#' @return Invisibly returns TRUE. Throws an error if any object
#'   has a different CRS from the first.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#' nc_utm <- st_transform(nc, 32617)
#'
#' sdqa_assert_crs(nc, nc)
#'
#' \dontrun{
#' sdqa_assert_crs(nc, nc_utm)
#' sdqa_assert_crs(nc, nc, nc_utm)
#' }
sdqa_assert_crs <- function(...) {

  # 0. Capture argument labels before `...` is evaluated. ensyms() records the
  ## unevaluated expressions (e.g. "nc_utm"), which are used in error messages.
  nms  <- sapply(rlang::ensyms(...), rlang::as_label)
  objs <- list(...)

  # 1. Validate inputs
  if (length(objs) < 2L) {
    cli::cli_abort("At least two objects must be provided.")
  }

  # 2. Extract CRS from all objects
  ## .crs_extract() normalises all backends to an sf::crs object so that
  ## comparison with != works uniformly across sf, terra, and duckspatial_df.
  crss    <- Map(.crs_extract, objs, nms)
  crs_ref <- crss[[1L]]

  # 3. Find every object whose CRS differs from the reference (first object)
  ## crss[-1L] drops the reference; +1L corrects the index back to the full list.
  mismatch_idx <- which(
    vapply(crss[-1L], function(crs) crs_ref != crs, logical(1L))
  ) + 1L

  # 4. Report all mismatches at once in a single error
  if (length(mismatch_idx) > 0L) {
    bullets <- vapply(mismatch_idx, function(i) {
      paste0("{.arg ", nms[[i]], "}: ", crss[[i]]$Name)
    }, character(1L))
    names(bullets) <- rep("x", length(bullets))

    cli::cli_abort(c(
      "Not all objects share the same CRS as {.arg {nms[[1L]]}} ({crs_ref$Name}).",
      bullets
    ))
  }

  invisible(TRUE)
}

#' Assert that spatial objects share the same xmin
#'
#' @description
#' Checks whether the western edge (xmin) of all objects passed via `...` is
#' identical. All objects are compared against the first one. Throws an error
#' at the first mismatch found.
#'
#' @param ... Two or more spatial objects. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#'
#' @return Invisibly returns TRUE. Throws an error if any object has a
#'   different xmin from the first.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' sdqa_assert_xmin(nc, nc)
#'
#' \dontrun{
#' nc_sub <- nc[nc$NAME == "Ashe", ]
#' sdqa_assert_xmin(nc, nc_sub)
#' }
sdqa_assert_xmin <- function(...) .assert_bbox_coord("xmin", ...)

#' Assert that spatial objects share the same xmax
#'
#' @description
#' Checks whether the eastern edge (xmax) of all objects passed via `...` is
#' identical. All objects are compared against the first one. Throws an error
#' at the first mismatch found.
#'
#' @param ... Two or more spatial objects. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#'
#' @return Invisibly returns TRUE. Throws an error if any object has a
#'   different xmax from the first.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' sdqa_assert_xmax(nc, nc)
#'
#' \dontrun{
#' nc_sub <- nc[nc$NAME == "Currituck", ]
#' sdqa_assert_xmax(nc, nc_sub)
#' }
sdqa_assert_xmax <- function(...) .assert_bbox_coord("xmax", ...)

#' Assert that spatial objects share the same ymin
#'
#' @description
#' Checks whether the southern edge (ymin) of all objects passed via `...` is
#' identical. All objects are compared against the first one. Throws an error
#' at the first mismatch found.
#'
#' @param ... Two or more spatial objects. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#'
#' @return Invisibly returns TRUE. Throws an error if any object has a
#'   different ymin from the first.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' sdqa_assert_ymin(nc, nc)
#'
#' \dontrun{
#' nc_sub <- nc[nc$NAME == "Ashe", ]
#' sdqa_assert_ymin(nc, nc_sub)
#' }
sdqa_assert_ymin <- function(...) .assert_bbox_coord("ymin", ...)

#' Assert that spatial objects share the same ymax
#'
#' @description
#' Checks whether the northern edge (ymax) of all objects passed via `...` is
#' identical. All objects are compared against the first one. Throws an error
#' at the first mismatch found.
#'
#' @param ... Two or more spatial objects. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#'
#' @return Invisibly returns TRUE. Throws an error if any object has a
#'   different ymax from the first.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' sdqa_assert_ymax(nc, nc)
#'
#' \dontrun{
#' nc_sub <- nc[nc$NAME == "Ashe", ]
#' sdqa_assert_ymax(nc, nc_sub)
#' }
sdqa_assert_ymax <- function(...) .assert_bbox_coord("ymax", ...)

#' Assert that a spatial object contains only the expected geometry type(s)
#'
#' @description
#' Checks whether every geometry type found in `x` is within `expected`.
#' The comparison is case-insensitive. Throws an error listing all unexpected
#' types found.
#'
#' @param x A spatial object. Supported classes: [`sf`][sf::sf],
#'   [`SpatVector`][terra::SpatVector], or `duckspatial_df`.
#'   [`SpatRaster`][terra::SpatRaster] is not supported.
#' @param expected A character vector of allowed geometry type names (e.g.
#'   `"POLYGON"`, `c("POLYGON", "MULTIPOLYGON")`). Case-insensitive.
#'
#' @return Invisibly returns TRUE. Throws an error if any geometry type
#'   found in `x` is not in `expected`.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' sdqa_assert_geom_type(nc, "MULTIPOLYGON")
#' sdqa_assert_geom_type(nc, c("polygon", "multipolygon"))
#'
#' \dontrun{
#' sdqa_assert_geom_type(nc, "POLYGON")
#' }
sdqa_assert_geom_type <- function(x, expected) {

  # 0. Capture the argument label for use in error messages
  arg <- rlang::as_label(rlang::ensym(x))

  # 1. Normalise expected to uppercase so the check is case-insensitive
  expected <- toupper(expected)

  # 2. Extract unique geometry types present in x (returned uppercase)
  detected <- .geom_type_extract(x, arg)

  # 3. Find types present in x that are not in expected
  invalid <- setdiff(detected, expected)

  if (length(invalid) > 0L) {
    cli::cli_abort(c(
      "{.arg {arg}} contains unexpected geometry type{?s}: {.val {invalid}}.",
      "i" = "Allowed type{?s}: {.val {expected}}."
    ))
  }

  invisible(TRUE)
}

#' Assert that a spatial object uses the expected datum
#'
#' @description
#' Checks whether the datum of `x` matches `expected`. The comparison is
#' case-insensitive. Datum names are extracted from the CRS WKT, so they match
#' the base geographic CRS name (e.g. `"WGS 84"`, `"ETRS89"`, `"NAD83"`).
#' To discover the datum name for a given object, run
#' `sdqa_assert_datum(x, "")` and read the detected name from the error, or
#' inspect `sf::st_crs(x)$Name` directly.
#'
#' @param x A spatial object. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#' @param expected A character vector of allowed datum names. Case-insensitive.
#'
#' @return Invisibly returns TRUE. Throws an error if the datum of `x` is not
#'   in `expected`.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' sdqa_assert_datum(nc)
#' sdqa_assert_datum(nc, "wgs 84")
#'
#' \dontrun{
#' nc_etrs89 <- st_transform(nc, 25830)
#' sdqa_assert_datum(nc_etrs89)
#' }
sdqa_assert_datum <- function(x, expected = "WGS 84") {

  # 0. Capture the argument label for use in error messages
  arg <- rlang::as_label(rlang::ensym(x))

  # 1. Normalise to uppercase for case-insensitive comparison
  expected <- toupper(expected)
  detected <- toupper(.datum_name(.crs_extract(x, arg)))

  # 2. Error if the datum is not among the allowed values
  if (!detected %in% expected) {
    cli::cli_abort(c(
      "{.arg {arg}} has datum {.val {detected}}.",
      "i" = "Allowed datum{?s}: {.val {expected}}."
    ))
  }

  invisible(TRUE)
}

#' Assert that a spatial object uses the expected CRS units
#'
#' @description
#' Checks whether the coordinate units of `x` match `expected`. The comparison
#' is case-insensitive. Use `sf::st_crs(x)$units_gdal` to discover the unit
#' string for a given object (e.g. `"degree"`, `"metre"`, `"foot"`).
#'
#' @param x A spatial object. Supported classes: [`sf`][sf::sf],
#'   [`SpatRaster`][terra::SpatRaster], [`SpatVector`][terra::SpatVector],
#'   or `duckspatial_df`.
#' @param expected A character vector of allowed unit names. Case-insensitive.
#'
#' @return Invisibly returns TRUE. Throws an error if the CRS units of `x` are
#'   not in `expected`.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc     <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#' nc_utm <- st_transform(nc, 32617)
#'
#' sdqa_assert_crs_units(nc)
#' sdqa_assert_crs_units(nc_utm, "metre")
#'
#' \dontrun{
#' sdqa_assert_crs_units(nc_utm)
#' }
sdqa_assert_crs_units <- function(x, expected = "degree") {

  # 0. Capture the argument label for use in error messages
  arg <- rlang::as_label(rlang::ensym(x))

  # 1. Normalise to uppercase for case-insensitive comparison
  expected <- toupper(expected)
  detected <- toupper(.crs_extract(x, arg)$units_gdal)

  # 2. Error if the units are not among the allowed values
  if (!detected %in% expected) {
    cli::cli_abort(c(
      "{.arg {arg}} has CRS units {.val {detected}}.",
      "i" = "Allowed unit{?s}: {.val {expected}}."
    ))
  }

  invisible(TRUE)
}

#' Assert that all geometries in a spatial object are valid
#'
#' @description
#' Checks whether every geometry in `x` is valid according to the OGC Simple
#' Features specification. Throws an error listing the row indices and
#' invalidity reasons for any invalid geometries.
#'
#' Two validation engines are available via the `engine` argument.
#' [sf::st_is_valid()] and [terra::is.valid()] both rely on GEOS but may
#' report different results for certain edge cases, so the choice of engine
#' can matter.
#'
#' Inputs are coerced to the class expected by the chosen engine:
#' * `engine = "sf"` (default): all backends are converted to
#'   [`sf`][sf::sf].
#' * `engine = "terra"`: all backends are converted to
#'   [`SpatVector`][terra::SpatVector]. `duckspatial_df` is first collected
#'   to [`sf`][sf::sf], then passed to [terra::vect()].
#'
#' @param x A spatial object. Supported classes: [`sf`][sf::sf],
#'   [`SpatVector`][terra::SpatVector], or `duckspatial_df`.
#'   [`SpatRaster`][terra::SpatRaster] is not supported.
#' @param engine character; validation engine to use. Either `"sf"` (default,
#'   uses [sf::st_is_valid()]) or `"terra"` (uses [terra::is.valid()]).
#'
#' @return Invisibly returns `TRUE`. Throws an error if any geometry is
#'   invalid, with one bullet per offending row showing the reason.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' sdqa_assert_geom_valid(nc)
#' sdqa_assert_geom_valid(nc, engine = "terra")
#'
#' \dontrun{
#' invalid <- st_sf(
#'   geometry = st_sfc(
#'     st_polygon(list(matrix(
#'       c(0, 0, 1, 1, 1, 0, 0, 1, 0, 0), ncol = 2, byrow = TRUE
#'     ))),
#'     crs = 4326
#'   )
#' )
#' sdqa_assert_geom_valid(invalid)
#' sdqa_assert_geom_valid(invalid, engine = "terra")
#' }
sdqa_assert_geom_valid <- function(x, engine = c("sf", "terra")) {

  # 0. Capture the argument label and resolve engine choice
  arg    <- rlang::as_label(rlang::ensym(x))
  engine <- match.arg(engine)

  # 1. Coerce to the target class and run the validity check
  if (engine == "sf") {

    ## 1.1. Convert to sf
    if (inherits(x, "duckspatial_df")) {
      x_sf <- duckspatial::ddbs_collect(x)
    } else if (inherits(x, "SpatVector")) {
      x_sf <- sf::st_as_sf(x)
    } else if (inherits(x, c("sf", "sfc"))) {
      x_sf <- x
    } else {
      cli::cli_abort(c(
        "{.arg {arg}} has unsupported class {.cls {class(x)[1]}}.",
        "i" = "Supported: {.cls sf}, {.cls SpatVector}, {.cls duckspatial_df}.",
        "i" = "{.cls SpatRaster} has no vector geometry."
      ))
    }

    reasons_all <- sf::st_is_valid(x_sf, reason = TRUE)
    invalid_idx <- which(is.na(reasons_all) | reasons_all != "Valid Geometry")
    reasons_chr <- ifelse(
      is.na(reasons_all[invalid_idx]),
      "NA (exception)",
      reasons_all[invalid_idx]
    )

  } else {

    ## 1.1. Convert to SpatVector; duckspatial_df must go through sf first
    if (inherits(x, "duckspatial_df")) {
      x_sv <- terra::vect(duckspatial::ddbs_collect(x))
    } else if (inherits(x, c("sf", "sfc"))) {
      x_sv <- terra::vect(x)
    } else if (inherits(x, "SpatVector")) {
      x_sv <- x
    } else {
      cli::cli_abort(c(
        "{.arg {arg}} has unsupported class {.cls {class(x)[1]}}.",
        "i" = "Supported: {.cls sf}, {.cls SpatVector}, {.cls duckspatial_df}.",
        "i" = "{.cls SpatRaster} has no vector geometry."
      ))
    }

    result      <- terra::is.valid(x_sv, messages = TRUE)
    invalid_idx <- which(!result$valid | is.na(result$valid))
    reasons_chr <- result$reason[invalid_idx]

  }

  # 2. Report all invalid geometries at once in a single error
  n <- length(invalid_idx)
  if (n > 0L) {
    bullets        <- paste0("Row ", invalid_idx, ": ", reasons_chr)
    names(bullets) <- rep("x", n)
    cli::cli_abort(c(
      "{.arg {arg}} has {n} invalid geometr{?y/ies}.",
      bullets
    ))
  }

  invisible(TRUE)
}

#' Assert that all geometries in a spatial object are simple
#'
#' @description
#' Checks whether every geometry in `x` is simple (i.e. does not
#' self-intersect). Throws an error listing the row indices of any non-simple
#' geometries.
#'
#' @param x A spatial object. Supported classes: [`sf`][sf::sf],
#'   [`SpatVector`][terra::SpatVector], or `duckspatial_df`.
#'   [`SpatRaster`][terra::SpatRaster] is not supported.
#'
#' @return Invisibly returns `TRUE`. Throws an error if any geometry is
#'   non-simple.
#'
#' @export
#'
#' @examples
#' library(sf)
#' nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)
#'
#' sdqa_assert_geom_simple(nc)
#'
#' \dontrun{
#' non_simple <- st_sf(
#'   geometry = st_sfc(
#'     st_linestring(matrix(
#'       c(0, 0, 1, 1, 0, 1, 1, 0), ncol = 2, byrow = TRUE
#'     )),
#'     crs = 4326
#'   )
#' )
#' sdqa_assert_geom_simple(non_simple)
#' }
sdqa_assert_geom_simple <- function(x) {

  # 0. Capture the argument label for use in error messages
  arg <- rlang::as_label(rlang::ensym(x))

  # 1. Check simplicity using the appropriate backend function
  if (inherits(x, "duckspatial_df")) {
    is_simple <- duckspatial::ddbs_is_simple(x, mode = "sf")
  } else if (inherits(x, "SpatVector")) {
    is_simple <- sf::st_is_simple(sf::st_as_sf(x))
  } else if (inherits(x, c("sf", "sfc"))) {
    is_simple <- sf::st_is_simple(x)
  } else {
    cli::cli_abort(c(
      "{.arg {arg}} has unsupported class {.cls {class(x)[1]}}.",
      "i" = "Supported: {.cls sf}, {.cls SpatVector}, {.cls duckspatial_df}.",
      "i" = "{.cls SpatRaster} has no vector geometry."
    ))
  }

  # 2. Report all non-simple geometries at once in a single error
  invalid_idx <- which(!is_simple | is.na(is_simple))
  n           <- length(invalid_idx)

  if (n > 0L) {
    cli::cli_abort(c(
      "{.arg {arg}} has {n} non-simple geometr{?y/ies}.",
      "x" = "Non-simple at row{?s}: {.val {invalid_idx}}."
    ))
  }

  invisible(TRUE)
}
