# Pfade setzen-----------------------------------------------------------------
source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

# libraries und function einlesen----------------------------------------------
library(raster)
library(graphics)
library(rgdal)

# Dateien einlesen-------------------------------------------------------------
dem <- paste("C:/Users/Keltoskytoi/Desktop/data/gis/input/lidar_dem_01m.tif")
dsm <- paste("C:/Users/Keltoskytoi/Desktop/data/gis/input/lidar_dsm_01m.tif")
muf <- paste("C:/Users/Keltoskytoi/Desktop/data/gis/input/muf_merged_01m.tif")

raster_dem <-raster(dem)
raster_dsm <- raster(dsm)
raster_muf <- raster(muf)

writeRaster(raster_dem, paste0(path_data, "gis/input/dem.tif"), overwrite=TRUE)
writeRaster(raster_dsm, paste0(path_data, "gis/input/dsm.tif"), overwrite=TRUE)
writeRaster(raster_muf, paste0(path_data, "gis/input/muf.tif"), overwrite=TRUE)

# Transform tif to sgrd (muf f�r sp�tere Visualisierung)
system(paste0(path_saga,
              " io_gdal 0",
              " -GRIDS ", paste0(path_data, "gis/input/muf.sgrd"),
              " -FILES ", paste0(path_data, "gis/input/muf.tif")))

#Calculate the height
hoehe <- (raster_dsm-raster_dem)
writeRaster(hoehe ,paste0(path_output,"hoehe.tif"), overwrite=TRUE)

# Transform tif to sgrd
system(paste0(path_saga,
              " io_gdal 0",
              " -GRIDS ", paste0(path_output, "hoehe.sgrd"),
              " -FILES ", paste0(path_output, "hoehe.tif")))

#Smooth the canopy heights with Gaussian Filter
system(paste0(path_saga,
              " grid_filter 1",
              " -INPUT ", paste0(path_output, "hoehe.sgrd"),
              " -RESULT ", paste0(path_output, "grid_filtered.sgrd"),
              " -SIGMA=1.000000",
              " -MODE=1",
              " -RADIUS=5"))

#Segment the smoothed canopy height model
system(paste0(path_saga,
              " imagery_segmentation 0",
              " -GRID ", paste0(path_output, "grid_filtered.sgrd"),
              " -SEGMENTS ", paste0(path_output, "treehights.sgrd"),
              " -SEEDS ", paste0(path_output, "canopy.shp"),
              " -OUTPUT=0 ",
              " -DOWN=1"))


#Apply a height break limit (removing segments below a certain height)
system(paste0(path_saga,
              " grid_calculus 1",
              " -GRIDS ", paste0(path_output, "treehights.sgrd"),
              " -RESULT ", paste0(path_output, "heightlimit.sgrd"),
              " -FORMULA=ifelse(lt(a,5),-99999,a)"))

#Convert the segments into vectors
system(paste0(path_saga,
              " shapes_grid 6",
              " -GRID ", paste0(path_output, "heightlimit.sgrd"),
              " -POLYGONS ", paste0(path_output, "numberpolygons.shp")))


#Polygone Centruid
system(paste0(path_saga,
              " shapes_polygons 1",
              " -POLYGONS ", paste0(path_output, "numberpolygons.shp"),
              " -CENTROIDS ", paste0(path_output, "centroids.shp")))

#Number of trees
polygone <- readOGR("C:/Users/Keltoskytoi/Desktop/data/gis/output", "numberpolygons")                           
print(nrow(polygone@data))

#Visualisierung
![Trees](C:/Users/Keltoskytoi/Desktop/data/gis/run/Trees.jpg)

####Discussion
###B�ume z�hlen funktioniert f�r zusammenh�ngende Waldgebiete sehr gut. 
###Probleme treten bei vereinzelten Baumgruppen, #z.B.zwischen �ckern oder 
###im Siedlungsbereich auf.
