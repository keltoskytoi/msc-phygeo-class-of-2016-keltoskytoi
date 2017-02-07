# Set path ---------------------------------------------------------------------
source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

# Libraries --------------------------------------------------------------------
library(sp)
library(raster)
library(tools)
library(glcm)
library(RSAGA)
library(gdalUtils)
library(rgdal)
library(rgeos)
library(vegan)

rasterOptions(tmpdir = path_temp)


# Get filepath of tree positions
trees <- readOGR("C:/Users/Keltoskytoi/Desktop/data/remote_sensing/input", "tree_positions")

# Load DEM
DEM <- raster(paste0(path_input, "lidar_dem_01m.tif"))

# Annahme des h/d Verhältnis um dbh zu berechnen:
# 0,45 bis 0,8, wobei 0,45 stabiler Wald und 0,8 labiler Wald ist
# dbh=h/hd, Eingangshöhe in m, dbh in cm
trees$stabil <- trees$height/0.45
trees$instabil <- trees$height/0.8
as.data.frame(trees)

# SDI Berechnung
N <- raster(paste0(path_input, "density_perhectar.tif"))

# Durchschnittlicher Baumdurchmesser pro Hektar
DEM[] <- 0
dbh_raster_stabil <- rasterize(trees, DEM, "stabil")
agg_dbh_stabil <- aggregate(dbh_raster_stabil,fact=100,expand=FALSE,fun=mean,na.rm=T)
plot(agg_dbh_stabil)
writeRaster(agg_dbh_stabil, file = paste0(path_input, "agg_dbh_stabil"),
            "GTiff", overwrite=T)

DEM[] <- 0
dbh_raster_instabil <- rasterize(trees, DEM, "instabil")
agg_dbh_instabil <- aggregate(dbh_raster_instabil, fact=100, expand=F, fun=mean, na.rm=T)
plot(agg_dbh_instabil)
writeRaster(agg_dbh_instabil, file = paste0(path_input, "agg_dbh_instabil"),
            "GTiff", overwrite=T)

# SDI=N*(dbh/25)^1,065; N: Stammzahl/ha; dbh: dbh der Bäume im betrachteten ha
sdi_stabil <- N*(agg_dbh_stabil/25)^1.605
plot(sdi_stabil)
writeRaster(sdi_stabil, file = paste0(path_input, "sdi_stabil"), 
            "GTiff", overwrite=T)

sdi_instabil <- N*(agg_dbh_instabil/25)^1.605
plot(sdi_instabil)
writeRaster(sdi_instabil, file = paste0(path_input, "sdi_instabil"), 
            "GTiff", overwrite=T)
```