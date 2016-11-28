

library (raster)
setwd("C:/users/Keltoskytoi/Desktop/WS2016_2017/msc-phygeo-class-of-2016-keltoskytoi/remote_sensing/")
R1<-stack("476000_5630000.tif")
R2<-stack("476000_5630000_1.tif")
R3<-stack("476000_5632000_1.tif") 
R4<-stack("geonode__476000_5632000.tif")
 
plot (R1)

R <- R1 + R2 -255
writeRaster(R,"C:/users/Keltoskytoi/Desktop/WS2016_2017/msc-phygeo-class-of-2016-keltoskytoi/remote_sensing/added_raster,tif", "GTiff")

RR <- R3 + R4 -255
writeRaster(RR,"C:/users/Keltoskytoi/Desktop/WS2016_2017/msc-phygeo-class-of-2016-keltoskytoi/remote_sensing/added_raster_2,tif", "GTiff")

str(R1)




