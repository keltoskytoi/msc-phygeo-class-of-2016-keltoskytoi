source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

#Compute
dem_fp <- paste0(path_input, "las_dsm_01m.tif")

# Transform tif to sgrd
cmd <- paste0(path_saga,
              " io_gdal 0",
              " -GRIDS ", paste0(dem_fp, ".sgrd"),
              " -FILES ", dem_fp)
system(cmd)

# Compute slope
cmd <- paste0(path_saga,
              " ta_morphometry 0",
              " -ELEVATION ", paste0(dem_fp, ".sgrd"),
              " -SLOPE ", paste0(path_lidar_derivates, "SLOPE.sgrd"),
              " -C_MINI ", paste0(path_lidar_derivates, "C_MINI.sgrd"),
              " -C_MAXI ", paste0(path_lidar_derivates, "C_MAXI.sgrd"),    
              " -C_PROF ", paste0(path_lidar_derivates, "C_PROF.sgrd"),
              " -C_TANG ", paste0(path_lidar_derivates, "C_TANG.sgrd"))
              
system(cmd)

# Convert restult to tif
outfile <- paste0(path_lidar_derivates, "SLOPE.sgrd")
outfile <- paste0(substr(outfile, 1, nchar(outfile)-4), "tif")

cmd <- paste0(path_saga,
              " io_gdal 2",
              " -GRIDS ", paste0(path_lidar_derivates, "SLOPE.sgrd"),
              " -FILE ", outfile)

system(cmd)

# Excursion to Fuzzy Land

cmd <- paste0(path_saga,
              " ta_morphometry 25",
              " -SLOPE ", paste0(path_lidar_derivates, "slope.sgrd"),
              " -MINCURV ", paste0(path_lidar_derivates, "c_mini.sgrd"),
              " -MAXCURV ", paste0(path_lidar_derivates, "c_maxi.sgrd"),
              " -PCURV ", paste0(path_lidar_derivates, "c_prof.sgrd"), 
              " -TCURV ", paste0(path_lidar_derivates, "c_tang.sgrd"),  
              " -PLAIN ", paste0(path_lidar_derivates, "plain.sgrd"))

system(cmd)


cmd.sgrd2tif <- paste0(path_saga,
                       " io_gdal 2",
                       " -GRIDS ", paste0(path_output, "plain.sgrd"),
                       " -FILE ", paste0(path_output, "plain.tif")) 
system(cmd.sgrd2tif)

## plain.tif visualisieren

library(raster)
dsm=stack(paste0(path_output, "plain.tif"))
plot(dsm)
