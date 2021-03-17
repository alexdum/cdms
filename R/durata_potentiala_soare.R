setwd("~/D/Alex/Clima/2021/cdms")
# instalalere biblioteci R daca nu sunt

if (!require("maptools")) install.packages("maptools")
if (!require("remote")) install.packages("remote")
if (!require("dplyr")) install.packages("dplyr")
if (!require("climatetools")) remotes::install_github("alexdum/climatetools")


# zile de interes
days <- seq(as.POSIXct("2021-01-01 00:00:00"), as.POSIXct("2021-12-31 23:00:00"), "days")

# selecteaza statii
ws.sel <- ws %>% filter(NUME %in% c("Constanta", "Vf. Omu", "Iasi", "Ocna Sugatag")) %>% dplyr::select(CODGE, NUME, Lon, Lat) %>% 
  slice(rep(1:n(), each = length(days)))

# fisier final
durata <- data.frame(ws.sel, time = days)

# calculeaza lungimea zilei 
Hels <- SpatialPoints(as.matrix(durata[,c("Lon", "Lat")]),  proj4string=CRS("+proj=longlat +datum=WGS84"))
up <- sunriset(Hels, durata$time , direction="sunrise", POSIXct.out=TRUE)
down <- sunriset(Hels, durata$time, direction="sunset", POSIXct.out=TRUE)
durata$day_length <- as.numeric(down$time - up$time)

# scrie datele
write.csv(durata, "output/durata_potentiala.csv", row.names = F)
