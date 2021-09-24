library(RODBC)
library(climatetools)
library(reshape2)
library(spacetime)
library(sp)
setwd("/home/clima/operativ_clima/validare_tm1/")
source("/home/clima/operativ_clima/validare_tm1/R/filtrare_statii.R")
# # selecteaza doar datele de interes
# tab <- sinteze_lipsuri("tabele/tmin_1961_2015.csv", 20)
# ws <- ws[ws$CODGE%in%tab$CODGE,]
# 
args <- commandArgs(TRUE)
dat1 <- as.character(args[1])
dat2 <- as.character(args[2])

channel <- odbcConnect("ORACLE2")

t1 <- paste("SELECT CLIMAZIS.COD, CLIMAZIS.DAT, CLIMAZIS.tmed FROM CLIMA.CLIMAZIS CLIMAZIS WHERE CLIMAZIS.COD in(",toString(ws$CODGE),") and (CLIMAZIS.DAT>={ts '",dat1," 00:00:00'} And CLIMAZIS.DAT<={ts '",dat2,"23:00:00'})ORDER BY CLIMAZIS.DAT")
t1 <- sqlQuery(channel,t1,as.is = T)
#t1$PRECIP[is.na(t1$PRECIP)]<-0

t1$DATA <- as.Date(t1$DAT)
t1$TMED <- as.numeric(t1$TMED)
t1$COD <- as.numeric(t1$COD)
odbcClose(channel)

dc <- dcast(t1, DATA~COD,value.var = "TMED")

# tine cont de sfarstiul de an si de anii bisecti
if (substr(dat2, 6,7) != "12") {
  if (lubridate::leap_year(as.Date(dat2))) {
    
    dats.i <- seq(as.Date(paste0("2004-",format(max(dc$DATA) + 1, "%m-%d"))), as.Date("2004-12-31"), by = "day")
    
    dc.i <- data.frame( DATA = seq(max(dc$DATA) + 1,as.Date(paste0(substr(dat2,1,4),"-12-31")), "days"), 
                        dc[dc$DATA %in% dats.i,2:ncol(dc)] )
    
  } else {
    dats.i <- seq(as.Date(paste0("2001-",format(max(dc$DATA) + 1, "%m-%d"))), as.Date(paste0(substr(dat1,1,4),"-12-31")), by = "day")
    
    dc.i <- data.frame( DATA = seq(max(dc$DATA) + 1,as.Date(paste0(substr(dat2,1,4),"-12-31")), "days"), 
                        dc[dc$DATA %in% dats.i,2:ncol(dc)] )
  }   
  names(dc.i) <- names(dc)
  dc <- rbind(dc, dc.i)
  
}

dates <- as.Date(dc$DAT)
tab <- dc[,2:ncol(dc)]
names(tab) <- names(tab)
#adu ordinea coordonatelor cu numele tabelului
ws$cod <- as.character(ws$CODGE)
ws <- ws[match(names(tab), ws$cod),]
identical(ws$cod,names(tab))

cbind(ws$cod,names(tab))
# 
# #creeaza stdf
# coordinates(ws) <- ~X+Y
# tmin.st<-STFDF(ws, dates, data.frame(values = as.vector(t(tab))))

# doar 1961 -2015
dats <- seq(as.Date(dat1), by = "day", length.out = nrow(tab))
# tab <- tab[dats<= as.Date("2015-12-31"),]
# scrie metadate
ws <- as.data.frame(ws)
meta <- ws[,c("Lon", "Lat","Z","CODGE","NUME")]
identical(as.character(ws$CODGE), names(tab))
write.table(meta, paste0("tabs/omogenizare/daily/TMED_",substr(dat1, 1, 4),"-",substr(dat2, 1, 4),".est"),row.names = FALSE,col.names = FALSE)
write(as.matrix(tab),paste0('tabs/omogenizare/daily/TMED_',substr(dat1, 1, 4),'-',substr(dat2, 1, 4),'.dat'))


# space = list(values = names(tab))
# tt.st2 = stConstruct(tab, space, dates, SpatialObj = co, interval = TRUE)
# all.equal(tt.st, tt.st2)
# save(tmin.st,file="RData//tmin_zilnice_1961_2016.RData")



