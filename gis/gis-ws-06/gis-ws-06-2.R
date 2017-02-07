source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

install.packages("gdalUtils") 
install.packages("mapview") 
library(gdalUtils) 
library(raster) 
library(car) 
library(rgdal) 
library(tools) 
library(sp)

# load Input file

dsm = paste0(path_input, "las_dsm_01m.tif")

# transform DGM to raster file 

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

### (R) create an sp object of estimated gauge position
gauge <- data.frame(y = lat, x = lon, name = "Pegel")

### (R) turn into a spatial object
coordinates(gauge) <- ~ x + y

### (R) assign the coordinate system (WGS84)
projection(gauge) <- CRS("+init=epsg:4326")

### (R) reproject it
estGauge <- spTransform(gauge, CRS("+init=epsg:25832"))

### Compute slope

system(paste0(path_saga, " ta_morphometry 0", 
              " -ELEVATION ", paste0(dem_hydro, ".sgrd"), 
              " -SLOPE ", paste0(path_temp, "slope.sgrd"), 
              " -C_MINI ", paste0(path_temp, "mincurv.sgrd"), 
              " -C_MAXI ", paste0(path_temp, "maxcurv.sgrd"), 
              " -C_PROF ", paste0(path_temp, "pcurv.sgrd"), 
              " -C_TANG ", paste0(path_temp, "tcurv.sgrd")))

### transform saga-grid to Tiff and visualize it

system(paste0(path_saga, " io_gdal 2", 
              " -GRIDS ", paste0(path_temp, "slope.sgrd"), 
              " -FILE ", paste0(path_temp, "slope.tif"))) 
plot(raster(paste0(path_temp, "slope.tif")))

### (SAGA) create filled DEM and watershed

system(paste0(path_saga," ta_preprocessor 4 ", 
              " -ELEV ", paste0(dem_hydro,".sgrd"), 
              " -FILLED ",paste0(path_temp,"rt_dempitless.sgrd"), 
              " -FDIR ",paste0(path_temp,"rt_ldd.sgrd"), 
              " -WSHED ",paste0(path_temp,"rt_ws.sgrd"), 
              " -MINSLOPE=0.100000"))

### transform saga-grid to Tiff and visualize it

system(paste0(path_saga, " io_gdal 2", 
              " -GRIDS ", paste0(path_temp, "rt_dempitless.sgrd"), 
              " -FILE ", paste0(path_temp, "rt_dempitless.tif"))) 
plot(raster(paste0(path_temp, "rt_dempitless.tif")))

### (SAGA) create catchment area

system(paste0(path_saga," garden_learn_to_program 7 ", 
              " -ELEVATION ",paste0(path_temp,"rt_dempitless.sgrd"), 
              " -AREA ",paste0(path_temp,"rt_catchmentarea.sgrd"), 
              " -METHOD 0"))

### (gdalUtils) export it to R as an raster object

gdalwarp(paste0(path_temp,"rt_catchmentarea.sdat"), 
         paste0(path_temp,"rt_catchmentarea.tif") , overwrite=TRUE) 
plot(raster(paste0(path_temp, "rt_catchmentarea.tif")))

catchmentarea<-raster(paste0(path_temp,"rt_catchmentarea.tif"))

### (R) estimate gauge buffer 

gaugeBuffer <- as.data.frame(extract(catchmentarea, estGauge, buffer = 25, cellnumbers = T)[[1]])

### (R) get the id of maxpos

id <- gaugeBuffer$cell[which.max(gaugeBuffer$value)]

### (R) get the posistion that is estimated to be the gauge

gaugeLoc <- xyFromCell(dem, id)

### (SAGA) calculate upslope are

system(paste0(path_saga," ta_hydrology 4 ", 
              " -TARGET_PT_X ",gaugeLoc[1,1], 
              " -TARGET_PT_Y ",gaugeLoc[1,2], 
              " -ELEVATION ",paste0(path_temp,
                                    "rt_dempitless.sgrd"), 
              " -AREA ",paste0(path_temp,"rt_catch.sgrd"), 
              " -METHOD 0", 
              " -CONVERGE=1.100000"))

### (gdalUtils) export it to R as an raster object

gdalwarp(paste0(path_temp,"rt_catch.sdat"), 
         paste0(path_temp,"rt_catch.tif") , overwrite=TRUE) 
gdalwarp(paste0(path_temp,"rt_ws.sdat"), 
         paste0(path_temp,"rt_ws.tif") , overwrite=TRUE)

upslope<-raster(paste0(path_temp,"rt_catch.tif")) 
ws<-raster(paste0(path_temp,"rt_ws.tif"))

### view it

mapview::mapview(ws)+ upslope + gauge

#### Catchment area:

plot(raster(paste0(path_temp,"rt_catch.tif")))

#### Watershed:

plot(raster(paste0(path_temp,"rt_ws.tif")))

#### View results:

mapview::mapview(ws)+ gauge + upslope

plot(upslope) 
plot(ws)
plot(gauge)

---------------------------ws-06-2------------------------
### Calculate Overland Flow - Kinematic Wave D8
#### Timestep 1 hour

system(paste0(path_saga," sim_hydrology 1 ", 
              " -DEM ",paste0(dem_hydro,".sgrd"), 
              " -FLOW ",paste0(path_temp,"flow_1.sgrd"), 
              " -GAUGES ",("C:/Users/Keltoskytoi/Desktop/data/gis/output/Pegel.shp"), 
              " -GAUGES_FLOW ",("C:/Users/Keltoskytoi/Desktop/data/gis/output/gauges_flow_1.csv"), 
              " -TIME_SPAN ",24.000000, " -TIME_STEP ",1.00000, " -PRECIP ", 0 ))

gdalwarp(paste0(path_temp,"flow_1.sdat"), 
         paste0(path_temp,"flow_1.tif") , overwrite=TRUE)

#### Timestep 3 hours

system(paste0(path_saga," sim_hydrology 1 ",
              " -DEM ",paste0(dem_hydro,".sgrd"), 
              " -FLOW ",paste0(path_temp,"flow_3.sgrd"), 
              " -GAUGES ",("C:/Users/Keltoskytoi/Desktop/data/gis/output/Pegel.shp"), 
              " -GAUGES_FLOW ",("C:/Users/Keltoskytoi/Desktop/data/gis/output/gauges_flow_3.csv"), 
              " -TIME_SPAN ",24.000000, " -TIME_STEP ",3.00000, " -PRECIP ",0 ))

gdalwarp(paste0(path_temp,"flow_3.sdat"), 
         paste0(path_temp,"flow_3.tif") , overwrite=TRUE)

### Influence of the selected simulation time-step
  
#### Die Ausgangsniederschlagsmenge wird größer je mehr Zeitschritte für die 
#### Simulation verwendet werden. Die durchschnittliche Abflussmenge pro Zeiteinheit
#### bleibt für jede Simulation in etwa gleich (gerundet 0,11).

## Visualization run-off

flow_1 <- read.table ("C:/Users/Keltoskytoi/Desktop/data/gis/output/gauges_flow_1.csv", sep = ",", dec = ".", header=TRUE)
flow_3 <- read.table ("C:/Users/Keltoskytoi/Desktop/data/gis/output/gauges_flow_3.csv", sep = ",", dec = ".", header=TRUE)
flow_gesamt <- read.table ("C:/Users/Keltoskytoi/Desktop/data/gis/output/gauges_flow_gesamt.csv", sep = ",", dec = ".", header=TRUE)

par_org <- par(mfrow=c(1,2))
plot.default(flow_1, type = "l", main ="run-off 1 hour")
plot.default(flow_3, type = "l", main="run-off 3 hours")





