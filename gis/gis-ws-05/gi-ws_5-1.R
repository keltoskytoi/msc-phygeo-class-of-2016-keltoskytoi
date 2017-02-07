## Pfade setzen----------------------------------------------------------------

source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

## libraries und function einlesen---------------------------------------------

install.packages("gdalUtils")
library(gdalUtils)
library(raster)

## Dateien einlesen------------------------------------------------------------

dsm <- paste0(path_input, "las_dsm_01m.tif")

## Raster aus ursprüngliches DGM
dem_hydro <- raster(dsm)

writeRaster(dem_hydro,paste0(path_temp,"dem_hydro.tif"),overwrite=TRUE)

dem_hydro<- paste0(path_temp, "dem_hydro.tif")

# Transform tif to sgrd
system(paste0(path_saga,
              " io_gdal 0",
              " -GRIDS ", paste0(dem_hydro, ".sgrd"),
              " -FILES ", dem_hydro))

# Compute slope
system(paste0(path_saga,
              " ta_morphometry 0",
              " -ELEVATION ", paste0(dem_hydro, ".sgrd"),
              " -SLOPE ", paste0(path_temp, "slope.sgrd"),
              " -C_MINI ", paste0(path_temp, "mincurv.sgrd"),
              " -C_MAXI ", paste0(path_temp, "maxcurv.sgrd"),
              " -C_PROF ", paste0(path_temp, "pcurv.sgrd"),
              " -C_TANG ", paste0(path_temp, "tcurv.sgrd")))

# Transform sgrd to tiff
system(paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_temp, "slope.sgrd"),
              " -FILE ", paste0(path_temp, "slope.tif"))) 
plot(raster(paste0(path_temp, "slope.tif")))

## Calculating the sinkroute
system(paste0(path_saga, 
              " ta_preprocessor 1",
              " -ELEVATION ", paste0(dem_hydro, ".sgrd"),
              " -SINKROUTE ", paste0(path_temp, "sinkroute.sgrd"),
              " -THRSHEIGHT ", "." ))

#transform sgrd to tiff and visualize it
system(paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_temp, "sinkroute.sgrd"),
              " -FILE ", paste0(path_temp, "sinkroute.tif"))) 
plot(raster(paste0(path_temp, "sinkroute.tif")))

## Calculating the catchment area using "Catchment Area/(Flow Tracing)":
system(paste0(path_saga,
              " ta_hydrology 2" ,
              " -ELEVATION ", paste0(dem_hydro, ".sgrd"),
              " -SINKROUTE ", paste0(path_temp, "sinkroute.sgrd"),
              " -CAREA ", paste0(path_temp, "catchment_area.sgrd")))

#transform sgrd to tiff and visualize it
system(paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_temp, "catchment_area.sgrd"),
              " -FILE ", paste0(path_temp, "catchment_area.tif"))) 
plot(raster(paste0(path_temp, "catchment_area.tif")))

## Calculating the catchment area  using the tool "Catchment Area (Parallel)":
system(paste0(path_saga,
              " ta_hydrology 0" ,
              " -ELEVATION ", paste0(dem_hydro, ".sgrd"),
              " -SINKROUTE ", paste0(path_temp, "sinkroute.sgrd"),
              " -CAREA ", paste0(path_temp, "catchment_area_parallel.sgrd")))

#transform sgrd to tiff and visualize it
system(paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_temp, "catchment_area_parallel.sgrd"),
              " -FILE ", paste0(path_temp, "catchment_area_parallel.tif"))) 
plot(raster(paste0(path_temp, "catchment_area_parallel.tif")))

### Calculating the topographic wetness index using the tool "Topographic Wetness Index (TWI)":
system(paste0(path_saga,
              " ta_hydrology 20" ,
              " -SLOPE ", paste0(path_temp, "slope.sgrd"),
              " -AREA ", paste0(path_temp, "catchment_area.sgrd"),
              " -TWI ", paste0(path_temp, "topo_wet_index.sgrd")))

### transform sgrd to tiff and visualize it
system(paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_temp, "topo_wet_index.sgrd"),
              " -FILE ", paste0(path_temp, "topo_wet_index.tif"))) 
plot(raster(paste0(path_temp, "topo_wet_index.tif")))

### Calculate the stream power index using the tool "Stream Power Index":
system(paste0(path_saga,
              " ta_hydrology 21" ,
              " -SLOPE ", paste0(path_temp, "slope.sgrd"),
              " -AREA ", paste0(path_temp, "catchment_area.sgrd"),
              " -SPI ", paste0(path_temp, "stream_power_index.sgrd")))

### transform sgrd to tiff and visualize it
system(paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_temp, "stream_power_index.sgrd"),
              " -FILE ", paste0(path_temp, "stream_power_index.tif"))) 
plot(raster(paste0(path_temp, "stream_power_index.tif")))

## Calculating the Overland Flow Distances to Channel Network using the tool 
## "Flow Distances to Channel Network":needed input for Overland Flow: Channel Network
## needed input for channel Network: "Initiation Grid" 
##<< not sure what we should use for this == classical use the
## catchment-area

### Calculating the Isochrones using the tool "Isochrones Variable Speed":
system(paste0(path_saga,
              " ta_hydrology 9" ,
              " -ELEVATION ", paste0(dem_hydro, ".sgrd"),
              " -SLOPE ", paste0(path_temp, "slope.sgrd"),
              " -FLOWACC ", paste0(path_temp, "catchment_area.sgrd"),
              " -TIME ", paste0(path_temp, "time.sgrd"),
              " -SPEED ", paste0(path_temp, "speed.sgrd")))
## Tool needs graphical user interface [Isochrones Variable Speed]

## Man würde so weitermachen:

###transform sgrd to tiff and visualize it
system(paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_temp, "time.sgrd"),
              " -FILE ", paste0(path_temp, "time.tif"))) 

plot(raster(paste0(path_temp, "time.tif")))

system(paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_temp, "speed.sgrd"),
              " -FILE ", paste0(path_temp, "speed.tif"))) 

plot(raster(paste0(path_temp, "speed.tif")))

