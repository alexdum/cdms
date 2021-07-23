library(maptools)
library(rgdal)
library(RODBC)
library(raster)
library(climatetools)


#incarca predictori
dem <- raster("input/grids/dem_focal.tif")
names(dem) <- "alt"
dem[is.na(dem)] <- 0
projection(dem) <- "+init=epsg:3844"


# descarca datele meteo pentru luna care a trecut
data <- Sys.Date()
data2 <- as.Date(paste0(format(data,"%Y-%m"),"-01")) - 1
data1 <- as.Date(paste0(format(data2,"%Y-%m"),"-01"))

# # conectare BD not RUN
#  am salvat local dupa ce am extras ca sa poata fi rulat si fara accesa la BD
# channel <- odbcConnect(dsn = "ORACLE2")
# tt <- paste("SELECT CLIMALU.COD,CLIMALU.DAT,  CLIMALU.TEMP_MEDL FROM CLIMA.CLIMALU CLIMALU WHERE  
#             (CLIMALU.DAT>={ts '", data1," 00:00:00'} and CLIMALU.DAT<={ts '", data2," 00:00:00'})
#             ORDER BY  CLIMALU.DAT")
# tt <- sqlQuery(channel,tt) 
# odbcClose(channel)
# tt <- na.omit(tt)
# write.csv(tt, "input/tabs/temp.data.csv", row.names = F)

# citire date descarcate din BD
tt <- read.csv("input/tabs/temp.data.csv")


tt.co <- merge(ws,tt, by.x = "CODGE", by.y = "COD")
coordinates(tt.co) = c("X", "Y")
proj4string(tt.co) = CRS("+init=epsg:3844")

tt.co$alt <- extract(dem, tt.co)

# regresie liniara 
lm <- lm(TEMP_MEDL~alt, tt.co)

print(summary(lm)$r.squared)

# estimare model regresie pe grid
pr <- predict(dem, lm)
plot(pr)

# extragere reziduuri
tt.co$res <- lm$residuals

# functie_interpolare
source("R/krige1_functii.R")

rbf_tt <- krige1(res~1,tt.co, as(pr,"SpatialPixelsDataFrame"), model = v)

# raster residuuri regresie
rr <- rasterFromXYZ(cbind(coordinates(dem),rbf_tt[,1]))
# raster finala
rt <- pr + rr
spplot(rt)


# salveaza geotif
writeRaster(rt, paste0("output/grids/tt_", gsub("-","_",substr(data1, 1, 7)),".tif"), overwrite = T)
