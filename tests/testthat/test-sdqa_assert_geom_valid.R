library(sf)

# Valid polygon
sf_valid <- st_sf(
  geometry = st_sfc(
    st_polygon(list(matrix(
      c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE
    ))),
    crs = 4326
  )
)

# Bowtie polygon: edges (0,0)-(1,1) and (1,0)-(0,1) cross — self-intersection
sf_invalid <- st_sf(
  geometry = st_sfc(
    st_polygon(list(matrix(
      c(0, 0, 1, 1, 1, 0, 0, 1, 0, 0), ncol = 2, byrow = TRUE
    ))),
    crs = 4326
  )
)

# Two rows: one valid, one invalid
sf_mixed <- st_sf(
  geometry = st_sfc(
    st_polygon(list(matrix(
      c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE
    ))),
    st_polygon(list(matrix(
      c(0, 0, 1, 1, 1, 0, 0, 1, 0, 0), ncol = 2, byrow = TRUE
    ))),
    crs = 4326
  )
)

# Validation ------------------------------------------------------------------

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_geom_valid(df), "unsupported class")
})

test_that("error for SpatRaster mentions unsupported class", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_geom_valid(r), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly for valid geometries", {
  expect_invisible(sdqa_assert_geom_valid(sf_valid))
  expect_true(sdqa_assert_geom_valid(sf_valid))
})

test_that("errors for invalid geometry", {
  expect_error(sdqa_assert_geom_valid(sf_invalid), "invalid geometr")
})

test_that("error names the argument", {
  expect_error(sdqa_assert_geom_valid(sf_invalid), "sf_invalid")
})

test_that("error includes reason string", {
  expect_error(sdqa_assert_geom_valid(sf_invalid), "Self-intersection|Ring Self-intersection")
})

test_that("error includes row index", {
  expect_error(sdqa_assert_geom_valid(sf_invalid), "Row 1")
})

test_that("error reports all invalid rows for mixed object", {
  expect_error(sdqa_assert_geom_valid(sf_mixed), "Row 2")
})

# terra -----------------------------------------------------------------------

test_that("passes for SpatVector with all valid geometries", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_valid)
  expect_no_error(sdqa_assert_geom_valid(sv))
})

test_that("errors for SpatVector with invalid geometry", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_invalid)
  expect_error(sdqa_assert_geom_valid(sv), "invalid geometr")
})

test_that("error includes reason string for SpatVector", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_invalid)
  expect_error(sdqa_assert_geom_valid(sv), "Self-intersection|Ring Self-intersection")
})

# duckspatial -----------------------------------------------------------------

test_that("passes for duckspatial_df with all valid geometries", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_valid, con)
  expect_no_error(sdqa_assert_geom_valid(ddf))
})

test_that("errors for duckspatial_df with invalid geometry", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_invalid, con)
  expect_error(sdqa_assert_geom_valid(ddf), "invalid geometr")
})

test_that("error includes reason string for duckspatial_df", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_invalid, con)
  expect_error(sdqa_assert_geom_valid(ddf), "Self-intersection|Ring Self-intersection")
})

# terra engine ----------------------------------------------------------------

test_that("engine = 'terra' passes for valid sf", {
  skip_if_not_installed("terra")
  expect_no_error(sdqa_assert_geom_valid(sf_valid, engine = "terra"))
})

test_that("engine = 'terra' returns TRUE invisibly for valid sf", {
  skip_if_not_installed("terra")
  expect_invisible(sdqa_assert_geom_valid(sf_valid, engine = "terra"))
  expect_true(sdqa_assert_geom_valid(sf_valid, engine = "terra"))
})

test_that("engine = 'terra' errors for invalid sf", {
  skip_if_not_installed("terra")
  expect_error(sdqa_assert_geom_valid(sf_invalid, engine = "terra"), "invalid geometr")
})

test_that("engine = 'terra' error names the argument", {
  skip_if_not_installed("terra")
  expect_error(sdqa_assert_geom_valid(sf_invalid, engine = "terra"), "sf_invalid")
})

test_that("engine = 'terra' error includes reason string", {
  skip_if_not_installed("terra")
  expect_error(
    sdqa_assert_geom_valid(sf_invalid, engine = "terra"),
    "Self-intersection|Ring Self-intersection"
  )
})

test_that("engine = 'terra' passes for valid SpatVector", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_valid)
  expect_no_error(sdqa_assert_geom_valid(sv, engine = "terra"))
})

test_that("engine = 'terra' errors for invalid SpatVector", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_invalid)
  expect_error(sdqa_assert_geom_valid(sv, engine = "terra"), "invalid geometr")
})

test_that("engine = 'terra' error includes reason string for SpatVector", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_invalid)
  expect_error(
    sdqa_assert_geom_valid(sv, engine = "terra"),
    "Self-intersection|Ring Self-intersection"
  )
})

test_that("engine = 'terra' passes for duckspatial_df with valid geometry", {
  skip_if_not_installed("duckspatial")
  skip_if_not_installed("terra")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_valid, con)
  expect_no_error(sdqa_assert_geom_valid(ddf, engine = "terra"))
})

test_that("engine = 'terra' errors for duckspatial_df with invalid geometry", {
  skip_if_not_installed("duckspatial")
  skip_if_not_installed("terra")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_invalid, con)
  expect_error(sdqa_assert_geom_valid(ddf, engine = "terra"), "invalid geometr")
})
