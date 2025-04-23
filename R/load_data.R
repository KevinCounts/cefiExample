load_data_aws <- function(path){
  
  aws_exists <- aws.s3::bucket_exists(
    bucket = "s3://noaa-oar-cefi-regional-mom6-pds/",
    region = "us-east-1"
  )
  
  if (!(aws_exists)){
    stop("AWS bucket does not exist")
  }
  
  print("Downloading file and storing it in work directory")
  aws.s3::save_object(
    object = path,
    bucket = "s3://noaa-oar-cefi-regional-mom6-pds/",
    region = "us-east-1",
    file = "bfg_1994010100_fhr09_fluxes_control.nc"
  )
  print("File downloaded")
  
  ncaws <- ncdf4::nc_open(url)
  return (ncaws)
}

load_data_opendap <- function(path){
  # Open a NetCDF file lazily and remotely
  ncopendap <- ncdf4::nc_open(path)
  return (ncopendap)
}



load_data <- function(data_source, path, variable, timeslice, ensemble=1){
  #Variable check
  sources_valid <- list("aws","opendap","local")
  if (!(data_source %in% sources_valid)) {
    stop("Data source should be 'aws', 'opendap', or 'local'")
  }
  
  #Retrieve ncfile via lazy load
  if (data_source == "aws") {
    print("WARNING: Using AWS will download the entire data file into your working direcotry")
    ncfile <- load_data_aws(path)
  } else if (data_source == "opendap") {
    ncfile <- load_data_opendap(path)
  } else {
    ncfile <- ncdf4::nc_open(path)
  }
  
  print(ncfile)
  lon <- ncdf4::ncvar_get(ncfile, "lon",verbose=TRUE)
  lat <- ncdf4::ncvar_get(ncfile, "lat")
  time <- ncdf4::ncvar_get(ncfile, "time",start = c(timeslice), count = c(1))
  print("******************")
  # Read a slice of the data into memory
  slice <- ncdf4::ncvar_get(ncfile, variable, start = c(1, 1, 1), count = c(-1, -1, 1))
  
  # Get the units
  tunits <- ncdf4::ncatt_get(ncfile, "lead", "units")
  datesince <- tunits$value
  datesince <- substr(datesince, nchar(datesince)-9, nchar(datesince))
  
  # convert the number to datetime (input should be in second while the time is in unit of days)
  datetime_var <- as.POSIXct(time*86400, origin=datesince, tz="UTC")
  
  df <- expand.grid(X = lon, Y = lat)
  data <- as.vector(t(sos))
  df$Data <- data
  names(df) <- c("lon", "lat", "sos")
  return (df)
}