#' Load CEFI data
#' 
#' This function lazy loads CEFI data from a thredds url and reads a time slice into memory.
#' 
#' @param inurl Thredds data url
#' @returns Time sliced data structure
#' @export
load_data <- function(inurl){
  # Specify the OPeNDAP server URL (using regular grid output)
  url <- "http://psl.noaa.gov/thredds/dodsC/Projects/CEFI/regional_mom6/northwest_atlantic/hist_run/regrid/ocean_monthly.199301-201912.sos.nc"
  
  # Open a NetCDF file lazily and remotely
  ncopendap <- ncdf4::nc_open(url)
  
  # Read the data into memory
  timeslice = 1
  lon <- ncdf4::ncvar_get(ncopendap, "lon")
  lat <- ncdf4::ncvar_get(ncopendap, "lat")
  time <- ncdf4::ncvar_get(ncopendap, "time",start = c(timeslice), count = c(1))
  
  # Read a slice of the data into memory
  sos <- ncdf4::ncvar_get(ncopendap, "sos", start = c(1, 1, timeslice), count = c(-1, -1, 1))
  sos
  
  # Get the units
  tunits <- ncdf4::ncatt_get(ncopendap, "time", "units")
  datesince <- tunits$value
  datesince <- substr(datesince, nchar(datesince)-9, nchar(datesince))
  datesince
  
  # convert the number to datetime (input should be in second while the time is in unit of days)
  datetime_var <- as.POSIXct(time*86400, origin=datesince, tz="UTC")
  datetime_var
  
  #filled.contour(lon, lat, sos, main = paste("Sea surface salinity at ", datetime_var), xlab = "Longitude", ylab = "Latitude", levels = pretty(c(20,40), 20))
}