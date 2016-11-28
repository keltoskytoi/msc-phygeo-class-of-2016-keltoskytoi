library(raster)
setwd("C:/Users/Keltoskytoi/Desktop/WS2016_2017/msc-phygeo-class-of-2016-keltoskytoi/remote_sensing")

s1=stack("474000_5630000.tif")
s2=stack("474000_5632000.tif")

s1.data.frame=as.data.frame(s1, optional = FALSE)
s2.data.frame=as.data.frame(s2, optional = FALSE)

row.values.1=s1.data.frame[c(99990001:100000000),]
row.values.2=s2.data.frame[c(1:10000), ]

nrow(s1.data.frame)
ncol(s1.data.frame)
head(s1.data.frame)
nrow(s2.data.frame)
ncol(s2.data.frame)
head(s2.data.frame)