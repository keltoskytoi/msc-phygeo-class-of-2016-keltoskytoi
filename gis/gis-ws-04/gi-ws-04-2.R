source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")

install.packages("gdalUtils")
library(gdalUtils)
library(raster)

### kernelsize for smoothing (meanfilter)
ksize<-3

### kernelsize for smothing modal filter
msize<-5

###[FuzzyLf]

slopetodeg<-   0
t_slope_min<- 3.0
t_slope_max<- 10.0
t_curve_min<-  0.00000001
t_curve_max<-  0.0001


                 #### (1) Filter the input data (DEM) and do not apply a final modal filter. ######

### Compute
dsm<- paste0(path_input, "las_dsm_01m.tif")

### Raster aus ursprüngliches DGM
dem=raster(dsm)

### R Meanfilter auf ursprüngliches DGM
demf<- raster::focal(dem, w=matrix(1/(ksize*ksize)*1.0, nc=ksize, nr=ksize))

### Visualisierung
plot(demf)

### export it to tif format
writeRaster(demf,paste0(path_temp,"rt_fildemR.tif"),overwrite=TRUE)

dem_fp<- paste0(path_temp, "rt_fildemR.tif")


### Transform tif to sgrd
cmd.tif2sgrd <- paste0(path_saga,
                       " io_gdal 0",
                       " -GRIDS ", paste0(dem_fp, ".sgrd"),
                       " -FILES ", dem_fp)
system(cmd.tif2sgrd)

### Compute slope
cmd.all_in_1 <- paste0(path_saga,
                       " ta_morphometry 0",
                       " -ELEVATION ", paste0(dem_fp, ".sgrd"),
                       " -SLOPE ", paste0(path_temp, "slope.sgrd"),
                       " -C_MINI ", paste0(path_temp, "mincurv.sgrd"),
                       " -C_MAXI ", paste0(path_temp, "maxcurv.sgrd"),
                       " -C_PROF ", paste0(path_temp, "pcurv.sgrd"),
                       " -C_TANG ", paste0(path_temp, "tcurv.sgrd"))
system(cmd.all_in_1)


cmd.fuzzy <- paste0(path_saga,
                    " ta_morphometry 25",
                    " -SLOPE ", paste0(path_temp, "slope.sgrd"),
                    " -MINCURV ", paste0(path_temp, "mincurv.sgrd"),
                    " -MAXCURV ", paste0(path_temp, "maxcurv.sgrd"),
                    " -PCURV ", paste0(path_temp, "pcurv.sgrd"),
                    " -TCURV ", paste0(path_temp, "tcurv.sgrd"),
                    " -PLAIN ", paste0(path_output, "plain.sgrd"),
                    " -FORM ", paste0(path_output, "rt_LANDFORM.sgrd"),
                    " -SLOPETODEG", slopetodeg, " ",
                    " -T_SLOPE_MIN", t_slope_min, " ",
                    " -T_SLOPE_MAX", t_slope_max, " ",
                    " -T_CURVE_MIN", t_curve_min, " ",
                    " -T_CURVE_MAX", t_curve_max)
system(cmd.fuzzy)


### Umwandeln Saga-grid in Tiff

cmd.plain.sgrd2tif <- paste0(path_saga,
                             " io_gdal 2",
                             " -GRIDS ", paste0(path_output, "plain.sgrd"),
                             " -FILE ", paste0(path_output, "plain.tif")) 
system(cmd.plain.sgrd2tif)

cmd.form.sgrd2tif <- paste0(path_saga,
                            " io_gdal 2",
                            " -GRIDS ", paste0(path_output, "rt_LANDFORM.sgrd"),
                            " -FILE ", paste0(path_output, "rt_LANDFORM.tif")) 
system(cmd.form.sgrd2tif)


landformSAGA_modal<-raster::raster(paste0(path_output,"rt_LANDFORM.tif"))

###Reclass to plain/plateau

flat.saga<-raster::reclassify(landformSAGA_modal, c(0,99,0, 99,100,1,100,200,0 ))

flat.saga[flat.saga==1 & dem>300]<-3  
flat.saga[flat.saga==1 & dem>240 & dem <= 300]<-0  
flat.saga[flat.saga==1 & dem<=240 ]<-2

writeRaster(flat.saga,paste0(path_output,"flat.saga.tif"),overwrite=TRUE)

plot(flat.saga)


###(2)Do not filter the input data (DEM) but this time apply a modal filter to the derived fuzzy landforms. 

### Compute
dsm<- paste0(path_input, "las_dsm_01m.tif")

### Raster aus ursprüngliches DGM
dem=raster(dsm)

### R Meanfilter auf ursprüngliches DGM
demf<- raster::focal(dem, w=matrix(1/(ksize*ksize)*1.0, nc=ksize, nr=ksize))

### Visualisierung
plot(demf)

### export it to tif format
writeRaster(dem,paste0(path_temp,"rt_fildemR_nofocal.tif"),overwrite=TRUE)

dem_nf<- paste0(path_temp, "rt_fildemR_nofocal.tif")


### Transform tif to sgrd
cmd.tif2sgrd <- paste0(path_saga,
                       " io_gdal 0",
                       " -GRIDS ", paste0(dem_nf, ".sgrd"),
                       " -FILES ", dem_nf)
system(cmd.tif2sgrd)

### Compute slope
cmd.all_in_1 <- paste0(path_saga,
                       " ta_morphometry 0",
                       " -ELEVATION ", paste0(dem_nf, ".sgrd"),
                       " -SLOPE ", paste0(path_temp, "slope.sgrd"),
                       " -C_MINI ", paste0(path_temp, "mincurv.sgrd"),
                       " -C_MAXI ", paste0(path_temp, "maxcurv.sgrd"),
                       " -C_PROF ", paste0(path_temp, "pcurv.sgrd"),
                       " -C_TANG ", paste0(path_temp, "tcurv.sgrd"))
system(cmd.all_in_1)


cmd.fuzzy <- paste0(path_saga,
                    " ta_morphometry 25",
                    " -SLOPE ", paste0(path_temp, "slope.sgrd"),
                    " -MINCURV ", paste0(path_temp, "mincurv.sgrd"),
                    " -MAXCURV ", paste0(path_temp, "maxcurv.sgrd"),
                    " -PCURV ", paste0(path_temp, "pcurv.sgrd"),
                    " -TCURV ", paste0(path_temp, "tcurv.sgrd"),
                    " -PLAIN ", paste0(path_output, "plain_nomodal.sgrd"),
                    " -FORM ", paste0(path_output, "rt_LANDFORM_nomodal.sgrd"),
                    " -SLOPETODEG", slopetodeg, " ",
                    " -T_SLOPE_MIN", t_slope_min, " ",
                    " -T_SLOPE_MAX", t_slope_max, " ",
                    " -T_CURVE_MIN", t_curve_min, " ",
                    " -T_CURVE_MAX", t_curve_max)
system(cmd.fuzzy)


### Umwandeln Saga-grid in Tiff

cmd.plain.sgrd2tif <- paste0(path_saga,
                             " io_gdal 2",
                             " -GRIDS ", paste0(path_output, "plain_nomodal.sgrd"),
                             " -FILE ", paste0(path_output, "plain_nomodal.tif")) 
system(cmd.plain.sgrd2tif)

cmd.form.sgrd2tif <- paste0(path_saga,
                            " io_gdal 2",
                            " -GRIDS ", paste0(path_output, "rt_LANDFORM_nomodal.sgrd"),
                            " -FILE ", paste0(path_output, "rt_LANDFORM_nomodal.tif")) 
system(cmd.form.sgrd2tif)


landformSAGA_nomodal<-raster::raster(paste0(path_output,"rt_LANDFORM_nomodal.tif"))


### Focal Filter ######## Get rid of the noise ##
landformModalR<- raster::focal(landformSAGA_nomodal, 
                               w=matrix(1, nc=msize, nr=msize),
                               fun=raster::modal,na.rm = TRUE, pad = TRUE)
plot(landformModalR)

###  reclass to plain / plateau

flat.modal<-raster::reclassify(landformModalR, c(0,99,0, 99,100,1,100,200,0 ))

### finally reclass it according to fixed altitude tresholds

flat.modal[flat.modal==1 & dem>300]<-3  
flat.modal[flat.modal==1 & dem>240 & dem <= 300]<-0  
flat.modal[flat.modal==1 & dem<=240 ]<-2

writeRaster(flat.modal,paste0(path_output,"flat.modal.tif"),overwrite=TRUE)

plot(flat.modal)


########################### for Markdown ######################

source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")
library(raster)

### Visualisierung Aufgabe 1: 
plot(raster(paste0(path_output, "flat.saga.tif")))


### Visualisierung Aufgabe 2: 
plot(raster(paste0(path_output, "flat.modal.tif")))



```{r}
source("C:/Users/Keltoskytoi/Desktop/data/gis/fun/Source_gis.R")
library(raster)

## Visualisierung Aufgabe 1: 
plot(raster(paste0(path_output, "flat.saga.tif")))


## Visualisierung Aufgabe 2: 
plot(raster(paste0(path_output, "flat.modal.tif")))


```{r}

