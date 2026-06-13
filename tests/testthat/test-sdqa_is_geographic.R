library(sf)

pt_geo <- st_sf(geometry = st_sfc(st_point(c(0, 0)), crs = 4326))
pt_prj <- st_transform(pt_geo, 32632)

# Validation ------------------------------------------------------------------

test_that("errors for unsupported class", {
  df <- data.frame(x = 1)
  expect_error(sdqa_is_geographic(df), "unsupported class")
})

# sf --------------------------------------------------------------------------

test_that("returns TRUE for a geographic sf object", {
  expect_true(sdqa_is_geographic(pt_geo))
})

test_that("returns FALSE for a projected sf object", {
  expect_false(sdqa_is_geographic(pt_prj))
})

test_that("return value is a plain logical scalar", {
  expect_type(sdqa_is_geographic(pt_geo), "logical")
  expect_length(sdqa_is_geographic(pt_geo), 1L)
})

# terra -----------------------------------------------------------------------

test_that("returns TRUE for a geographic SpatRaster", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:4326")
  expect_true(sdqa_is_geographic(r))
})

test_that("returns FALSE for a projected SpatRaster", {
  skip_if_not_installed("terra")
  r <- terra::rast(nrows = 3, ncols = 3, crs = "EPSG:32632")
  expect_false(sdqa_is_geographic(r))
})

test_that("returns TRUE for a geographic SpatVector", {
  skip_if_not_installed("terra")
  v <- terra::vect(pt_geo)
  expect_true(sdqa_is_geographic(v))
})

test_that("returns FALSE for a projected SpatVector", {
  skip_if_not_installed("terra")
  v <- terra::vect(pt_prj)
  expect_false(sdqa_is_geographic(v))
})

# duckspatial -----------------------------------------------------------------

test_that("returns TRUE for a geographic duckspatial_df", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(pt_geo, con)
  expect_true(sdqa_is_geographic(ddf))
})

test_that("returns FALSE for a projected duckspatial_df", {
  skip_if_not_installed("duckspatial")
  con <- duckspatial::ddbs_create_conn()
  on.exit(duckspatial::ddbs_stop_conn(con))
  ddf <- duckspatial::as_duckspatial_df(pt_prj, con)
  expect_false(sdqa_is_geographic(ddf))
})
