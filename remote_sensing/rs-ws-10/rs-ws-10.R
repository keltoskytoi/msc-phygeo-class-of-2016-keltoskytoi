# Set path ---------------------------------------------------------------------

source("C:/Users/Keltoskytoi/Desktop/data/remote_sensing/fun/Source_rs.R")

# Libraries --------------------------------------------------------------------
install.packages("sp")
install.packages("raster")
install.packages("tools")
install.packages("glcm")
library(sp)
library(raster)
library(tools)
library(glcm)

rasterOptions(tmpdir = path_temp)


# Get filepath of prediction
pred <- raster(paste0(path_input, "geonode_muf_lcc_prediction.tif"))
plot(pred)



# modal filter 3x3 window --------------------------------------------------------

# Calculate and plot modal filter
pred_modal_w3 <- focal(pred, w=matrix(1,3,3), fun=modal)
plot(pred_modal_w3)

# Write raster
writeRaster(pred_modal_w3, file = paste0(path_output, "geonode_muf_lcc_prediction_modal_w3.tif"), "GTiff", overwrite = FALSE)


# modal filter 3x3 window and 3x3 window ----------------------------------------

# read raster
pred_modal_w3 <- raster(paste0(path_output, "geonode_muf_lcc_prediction_modal_w3.tif"))

# Calculate and plot modal filter
pred_modal_w3_modal_w3 <- focal(pred_modal_w3, w=matrix(1,3,3), fun=modal)
plot(pred_modal_w3_modal_w3)

# Write raster
writeRaster(pred_modal_w3_modal_w3, file = paste0(path_output, "geonode_muf_lcc_prediction_modal_w3_modal_w3.tif"), "GTiff", overwrite = FALSE)


# modal filter 5x5 window ------------------------------------------------------------

# Calculate and plot modal filter
pred_modal_w5 <- focal(pred, w=matrix(1,5,5), fun=modal)
plot(pred_modal_w5)

# Write raster
writeRaster(pred_modal_w5, file = paste0(path_output, "geonode_muf_lcc_prediction_modal_w5.tif"), "GTiff", overwrite = FALSE)


# modal filter 9x9 window -------------------------------------------------------------

# Calculate and plot modal filter
pred_modal_w9 <- focal(pred, w=matrix(1,9,9), fun=modal)
plot(pred_modal_w9)

# Write raster
writeRaster(pred_modal_w9, file = paste0(path_output, "geonode_muf_lcc_prediction_modal_w9.tif"), "GTiff", overwrite = FALSE)


# Der Modalfilter mit dem 5x5 Window erzielt unserer Meinung nach die präzisesten
# Ergebnisse, die dem Luftbild am meisten ähneln. Fehlklassifizierungen sind aber auch
# hier nicht völlig ausgeschlossen (z.B. sind Hausdächer als Wasser klassifiziert oder
# Waldbereiche als Häuser oder Gärten). Daher würden wir gerne eine Vorklassifizierung
# vornehmen, bei der in bestimmten Gebieten nur vorher definierte Klassen in Frage kommen.
# Wir wissen nicht, wie das programmiert werden kann.

