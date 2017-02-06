# set path
source("C:/Users/Keltoskytoi/Desktop/data/remote_sensing/fun/Source_rs.R")

install.packages("sp")
install.packages("raster")
install.packages("tools")
install.packages("glcm")
install.packages("rgdal")
install.packages("vegan")
install.packages("rgeos")
library(gdalUtils)
library(glcm)
library(raster)
library(rgdal)
library(rgeos)
library(RSAGA)
library(sp)
library(tools)
library(vegan)

rasterOptions(tmpdir = path_temp)

# start loop, j = radius
for(j in seq(from=10, to=100, by=10)){

# get filepath of tree positions
trees <- NULL
trees <- readOGR("C:/Users/Keltoskytoi/Desktop/data/remote_sensing/input", "tree_positions")

# remove NAs
trees <- trees[!is.na(trees$tree_type), ]

# extract species
beech <- trees[trees@data$tree_type == "beech",]
douglas <- trees[trees@data$tree_type == "douglas",]
larch <- trees[trees@data$tree_type == "larch",]
oak <- trees[trees@data$tree_type == "oak",]
premium <- trees[trees@data$tree_type == "premium",]
soft <- trees[trees@data$tree_type == "soft",]
spruce <- trees[trees@data$tree_type == "spruce",]

# put buffer around trees
trees_buffer <- buffer(trees, width=2*j, dissolve=FALSE)

# count trees in buffer
count <- over(trees_buffer, trees, returnList = TRUE)

tree_number <- list()
for(i in seq(length(count))){
  tree_number[[i]] <- nrow(count[[i]])
}

trees@data$tree_nbr <- unlist(tree_number)

# count beech trees in buffer
count <- over(trees_buffer, beech, returnList = TRUE)

tree_number <- list()
for(i in seq(length(count))){
  tree_number[[i]] <- nrow(count[[i]])
}

trees@data$beech_nbr <- unlist(tree_number)

# count douglas trees in buffer
count <- over(trees_buffer, douglas, returnList = TRUE)

tree_number <- list()
for(i in seq(length(count))){
  tree_number[[i]] <- nrow(count[[i]])
}

trees@data$douglas_nbr <- unlist(tree_number)

# count larch trees in buffer
count <- over(trees_buffer, larch, returnList = TRUE)

tree_number <- list()
for(i in seq(length(count))){
  tree_number[[i]] <- nrow(count[[i]])
}

trees@data$larch_nbr <- unlist(tree_number)

# count oak trees in buffer
count <- over(trees_buffer, oak, returnList = TRUE)

tree_number <- list()
for(i in seq(length(count))){
  tree_number[[i]] <- nrow(count[[i]])
}

trees@data$oak_nbr <- unlist(tree_number)

# count premium trees in buffer
count <- over(trees_buffer, premium, returnList = TRUE)

tree_number <- list()
for(i in seq(length(count))){
  tree_number[[i]] <- nrow(count[[i]])
}

trees@data$premium_nbr <- unlist(tree_number)

# count soft trees in buffer
count <- over(trees_buffer, soft, returnList = TRUE)

tree_number <- list()
for(i in seq(length(count))){
  tree_number[[i]] <- nrow(count[[i]])
}

trees@data$soft_nbr <- unlist(tree_number)

# count spruce trees in buffer
count <- over(trees_buffer, spruce, returnList = TRUE)

tree_number <- list()
for(i in seq(length(count))){
  tree_number[[i]] <- nrow(count[[i]])
}

trees@data$spruce_nbr <- unlist(tree_number)

head(trees@data)
trees_counted <- as.data.frame(trees)
saveRDS(trees_counted, file = paste0(path_input, "trees_counted_r",as.character(j),".rds"))

#trees_counted <- readRDS(paste0(path_input, "trees_counted_r",as.character(j),".rds"))

# calculate shannon index
trees_counted_species <- trees_counted[,8:14]
shannon <- diversity(trees_counted_species, index ="shannon", MARGIN = 1, base = exp(1))

trees@data$shannon <- shannon
trees@data <- trees@data[,c(1:6,ncol(trees@data))]

writeOGR(trees, paste0(path_input, "shannon_r",as.character(j),".shp"), paste0(path_input, "shannon_r", as.character(j)), driver="ESRI Shapefile", overwrite = TRUE)
}
