### Set path
source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

### Libraries
library(sp)
library(raster)
library(tools)
library(glcm)
library(RSAGA)
library(gdalUtils)
library(rgdal)

rasterOptions(tmpdir = path_temp)

### Load tiff files
dem <- raster(paste0(path_input, "lidar_dem_01m.tif"))
dsm <- raster(paste0(path_input, "lidar_dsm_01m.tif"))
pcag <- raster(paste0(path_input, "lidar_pointsaboveground_01m.tif"))
pcgr <- raster(paste0(path_input, "lidar_groundreturns_01m.tif"))

### calculate tree heights
trh <- dsm-dem
plot(trh)

writeRaster(trh, file = paste0(path_input, "trh.tif"), "GTiff", overwrite = FALSE)
trh <- raster(paste0(path_input, "trh.tif"))

### calculate forest density
allpoints <- pcag+pcgr
density <- pcag/allpoints
plot(density)
writeRaster(density, file = paste0(path_input, "density.tif"), "GTiff", overwrite = FALSE)

### calculate wooden biomass
## formula taken from He et al. (2013, S. 992)
stem_biomass <- -13.595 + 8.446*mean(trh) + 20.378*density
branch_biomass <- -2.447 + 1.367*mean(trh) + 3.300*density

wooden_biomass <- stem_biomass+branch_biomass
plot(wooden_biomass)
writeRaster(wooden_biomass, file = paste0(path_input, "wooden_biomass.tif"), "GTiff", overwrite = FALSE)

### load waldklassen and aerial
waldklassen <- stack(paste0(path_input, "muf_waldklassen.tif"))
plotRGB(waldklassen)

aerial <- stack(paste0(path_input, "muf_merged_01m.tif"))
plotRGB(aerial)

### Discussion
###There is a relation between wooden biomass, the density of the forest area and
###the structure of the forest (age, species). For example a young tree area 
###(coordinates 477555, 5632192)has low wooden biomass.

#### Literature
#### He, Q., Chen, E., An, R. & Y. Li (2013): Above-Ground Biomass and Biomass 
#### Components Estimation Using LiDAR Data in a Coniferous Forest. - 
#### In: Forests 4: 984-1002.
