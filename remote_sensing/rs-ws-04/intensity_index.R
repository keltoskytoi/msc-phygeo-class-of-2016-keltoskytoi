
source(paste0(path_scripts, "intensity_index"))


intensity_index <- function(x,r=1,g=2,b=3){
  require(raster)
  intensity <- (1/30.5)/(x[[r]] +x[[g]] +x[[b]])
  return(intensity)
} 
intensity_index(r1)