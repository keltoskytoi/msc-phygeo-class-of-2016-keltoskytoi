#### Pfade setzen--------------------------------------------------------------
source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

#### libraries und function einlesen-------------------------------------------

install.packages("gdalUtils")
install.packages("maps")
install.packages("maptools")

library(gdalUtils)
library(glcm)
library(graphics)
library(link2GI)
library(leaflet)
library(maps)
library(maptools)
library(raster)
library(rgdal)
library(rgeos)
library(RSAGA)
library(sp)
library(tools)

rasterOptions(tmpdir = path_temp)

#### Dateien einlesen
dem <- raster(paste0(path_input, "lidar_dem_01m.tif"))
dsm <- raster(paste0(path_input, "lidar_dsm_01m.tif"))
muf <- raster(paste0(path_input, "muf_merged_01m.tif"))
trees <- readOGR(paste0(path_output, "centroids.shp"))
#### Baumh�he errechnen
trh <- dsm-dem
plot(trh)

writeRaster(trh, file = paste0(path_input, "trh.tif"), "GTiff", overwrite = TRUE)

trh <- raster(paste0(path_input, "trh.tif"))

# crop trees & trh
ext <- extent(475000, 476000, 5630000, 5631000)
trees_crop <- crop(trees, ext)
trh_crop <- crop(trh, ext)

# Buffer 
trees_Buffer <- gBuffer(trees_crop, width=5, byid = TRUE)
count <- over(trees_Buffer, trees_crop, fn=length)
trees_Buffer$trees_crop_count <- count$NAME
plot(trees_Buffer)

writeOGR(trees_Buffer, "C:/Users/Keltoskytoi/Desktop/data/gis/output/Baeme_B.shp", "Baeume_B", 
        driver="ESRI Shapefile", overwrite_layer= TRUE)

# Density
xy <- abs(apply(as.matrix(bbox(ext)), 1, diff))
n <- 1
r <- raster(ext, ncol=xy[1]*n, nrow=xy[2]*n)
projection(r) <- CRS("+init=epsg:4326")
rr <- rasterize(trees_Buffer, r)
writeRaster(rr, "trees_Buffer", overwrite = TRUE)
plot(rr)

# Biomass
stem_biomass <- -13.595 + 8.446*mean(trh_crop) + 20.378*rr
branch_biomass <- -2.447 + 1.367*mean(trh_crop) + 3.300*rr

wooden_biomass <- stem_biomass+branch_biomass
plot(wooden_biomass)

