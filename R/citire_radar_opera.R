library(terra)
library(rnaturalearth)
gra <- ne_countries(continent = 'europe')
tt <- rast("h5/T_PASH21_C_EUOC_20211012081500.hdf")
tt1 <- tt[[2]] 
tt1[tt1 < 0] <- 0
plot(tt1)

ttwgs <- project(tt1, "+proj=longlat +datum=WGS84")
plot(ttwgs)
plot(gra, add = T)
