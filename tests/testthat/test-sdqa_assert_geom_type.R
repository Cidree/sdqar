library(sf)

# sf objects with distinct geometry types
sf_point <- st_sf(
  geometry = st_sfc(st_point(c(0, 0)), crs = 4326)
)
sf_multipoint <- st_sf(
  geometry = st_sfc(
    st_multipoint(matrix(c(0, 0, 1, 1), ncol = 2, byrow = TRUE)),
    crs = 4326
  )
)
sf_polygon <- st_sf(
  geometry = st_sfc(
    st_polygon(list(matrix(
      c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE
    ))),
    crs = 4326
  )
)
sf_multipolygon <- st_sf(
  geometry = st_sfc(
    st_multipolygon(list(list(matrix(
      c(0, 0, 1, 0, 1, 1, 0, 1, 0, 0), ncol = 2, byrow = TRUE
    )))),
    crs = 4326
  )
)

# Validation ------------------------------------------------------------------

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_assert_geom_type(df, "POINT"), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("passes and returns TRUE invisibly for correct geometry type", {
  expect_invisible(sdqa_assert_geom_type(sf_point, "POINT"))
  expect_true(sdqa_assert_geom_type(sf_point, "POINT"))
})

test_that("errors when geometry type does not match", {
  expect_error(sdqa_assert_geom_type(sf_point, "POLYGON"), "unexpected geometry")
})

test_that("error names the offending type", {
  expect_error(sdqa_assert_geom_type(sf_point, "POLYGON"), "POINT")
})

test_that("error names the argument", {
  expect_error(sdqa_assert_geom_type(sf_point, "POLYGON"), "sf_point")
})

test_that("comparison is case-insensitive", {
  expect_no_error(sdqa_assert_geom_type(sf_point, "point"))
  expect_no_error(sdqa_assert_geom_type(sf_point, "Point"))
})

test_that("passes when expected contains multiple allowed types", {
  expect_no_error(sdqa_assert_geom_type(sf_polygon, c("POLYGON", "MULTIPOLYGON")))
  expect_no_error(sdqa_assert_geom_type(sf_multipolygon, c("POLYGON", "MULTIPOLYGON")))
})

test_that("errors when type is not among multiple allowed types", {
  expect_error(
    sdqa_assert_geom_type(sf_point, c("POLYGON", "MULTIPOLYGON")),
    "unexpected geometry"
  )
})

test_that("passes for MULTIPOLYGON when expected is MULTIPOLYGON", {
  expect_no_error(sdqa_assert_geom_type(sf_multipolygon, "MULTIPOLYGON"))
})

test_that("errors for MULTIPOLYGON when only POLYGON is expected", {
  expect_error(sdqa_assert_geom_type(sf_multipolygon, "POLYGON"), "MULTIPOLYGON")
})

# terra -----------------------------------------------------------------------

test_that("passes for SpatVector with correct geometry type", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_polygon)
  expect_no_error(sdqa_assert_geom_type(sv, "POLYGON"))
})

test_that("errors for SpatVector with wrong geometry type", {
  skip_if_not_installed("terra")
  sv <- terra::vect(sf_polygon)
  expect_error(sdqa_assert_geom_type(sv, "POINT"), "unexpected geometry")
})

test_that("errors for SpatRaster with informative message", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_error(sdqa_assert_geom_type(r, "POLYGON"), "unsupported class")
})

# duckspatial -----------------------------------------------------------------

test_that("passes when duckspatial_df has the expected geometry type", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_polygon, con)
  expect_no_error(sdqa_assert_geom_type(ddf, "POLYGON"))
})

test_that("errors when duckspatial_df has an unexpected geometry type", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(sf_polygon, con)
  expect_error(sdqa_assert_geom_type(ddf, "POINT"), "unexpected geometry")
})
