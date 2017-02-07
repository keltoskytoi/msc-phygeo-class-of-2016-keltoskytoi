source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

install.packages("gdalUtils") 
install.packages("rgdal")
library(rgdal)
library(gdalUtils) 
library(raster)

# Load Input file

dsm = paste0(path_input, "las_dsm_01m.tif")

# Transform DGM to raster file 

dem = raster(dsm)

writeRaster(dem,paste0(path_temp,"dem_hydro.tif"),overwrite=TRUE)

dem_hydro<- paste0(path_temp, "dem_hydro.tif")

### Transform tif to sgrd

system(paste0(path_saga, " io_gdal 0", 
              " -GRIDS ", paste0(dem_hydro, ".sgrd"), 
              " -FILES ", dem_hydro))

### Gauge position
lat <- 50.840860
lon <- 8.684456

    -----------------------------------------------

### (R) create an sp object of estimated gauge position
gauge <- data.frame(y = lat, x = lon, name = "Pegel")

### (R) turn into a spatial object
coordinates(gauge) <- ~ x + y

### (R) assign the coordinate system (WGS84)
projection(gauge) <- CRS("+init=epsg:4326")

### (R) reproject it
estGauge <- spTransform(gauge, CRS("+init=epsg:25832"))

writeOGR(estGauge, "C:/Users/Keltoskytoi/Desktop/data/gis/output/Pegel.shp", "Pegel", 
         driver = "ESRI Shapefile", overwrite_layer = TRUE)
