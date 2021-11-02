library(terra)
library(rnaturalearth)
library(rgeos)
gra <- ne_countries(continent = 'europe')

#buffer 50 km 
rou.buff <- gra[gra$sov_a3 == "ROU",] %>% gBuffer(width = "0.5")

tt <- rast("h5/T_PASH21_C_EUOC_20211012081500.hdf")
tt1 <- tt[[2]] 


#
tt1[tt1 < 0] <- 0
plot(tt1)

ttwgs <- project(tt1, "+proj=longlat +datum=WGS84")

plot(ttwgs)
plot(gra, add = T)


ttwgs.crop <- crop(ttwgs, rou.buff)
plot(rou.buff, add = T)