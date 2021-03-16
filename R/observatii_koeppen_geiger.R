library(ClimClass)
library(raster)
library(climatetools)


sinteze_lipsuri<-function(path,missing)
{
  norm<-read.table(path,skip=4,nrows =262,sep=";",na.strings="-")
  lipsuri<-read.table(path,skip=267,sep=";",na.strings="-")
  lipsuri[is.na(lipsuri)]<-0
  norm<-norm[lipsuri[,15]<= missing,]
  #numele coloanelor
  names(norm)<-c("CODGE","NUME","Jan","Feb","Mar","Apr","May","Jun","Jul",
                 "Aug","Sep","Oct","Nov","Dec")
  
  return(norm[,1:14])
}

tmed <- sinteze_lipsuri("tabele/tmed_1961_2015.csv", 0)
tmax <- sinteze_lipsuri("tabele/tmaxmed_1961_2015.csv", 0)
tmin <- sinteze_lipsuri("tabele/tminmed_1961_2015.csv", 0)
prec <- sinteze_lipsuri("tabele/pp_1961_2015.csv", 0)
tmin.abs <- sinteze_lipsuri("tabele/tminmin_1961_2015.csv", 0)
# selectare doar statii care au sir de observatii complete
prec <- prec[prec$CODGE%in%tmin$CODGE,]
tmed <- tmed[tmed$CODGE%in%prec$CODGE,]
tmax <- tmax[tmax$CODGE%in%tmed$CODGE,]
tmin <- tmin[tmin$CODGE%in%tmax$CODGE,]
prec <- prec[prec$CODGE%in%tmin$CODGE,]
tmed <- tmed[tmed$CODGE%in%prec$CODGE,]
tmin.abs <- tmin.abs[tmin.abs$CODGE%in%tmed$CODGE,]
identical(tmed$CODGE, tmin$CODGE)
identical(prec$CODGE, tmin$CODGE)
identical(prec$CODGE, tmax$CODGE)
identical(prec$CODGE, tmin.abs$CODGE)



# write.csv(prec[prec$CODGE %in% c("413838", "710736", "527527"),],"prec_monthly.csv", row.names = F)
# write.csv(tmed[tmed$CODGE %in% c("413838", "710736", "527527"),],"tmed_monthly.csv", row.names = F)
# write.csv(tmax[tmax$CODGE %in% c("413838", "710736", "527527"),],"tmax_monthly.csv", row.names = F)
# write.csv(tmin[tmin$CODGE %in% c("413838", "710736", "527527"),],"tmin_monthly.csv", row.names = F)
# 

# incepe iteratia pentru coordonate
tabf <- NULL
for (i in 1:nrow(prec))
{
  print(i)
  # tabel pentru calcul
  tab <- data.frame( month = 1:12, P= t(prec[i,3:14]), Tn=t(tmin[i,3:14]), Tx = t(tmax[i,3:14]), t(tmed[i,3:14]),  AbsTn = t(tmin.abs[i,3:14]))
  names(tab) <- c("month", "P", "Tn", "Tx", "Tm", "AbsTn")
  # calculeaza tabel final
  tabi <- koeppen_geiger(clim_norm = tab,A_B_C_special_sub.classes = F, class.nr = F)
  
  tabf <- rbind(tabf,cbind(nume = prec$NUME[i], tabi))
}

write.csv(tabf, "tabele/statii_59_koeppen_1961_2015.csv")
