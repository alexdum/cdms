setwd("~/D/Alex/Clima/2021/cdms")
if (!require("ClimClass")) library(ClimClass)


prec <- read.csv("input/prec_monthly.csv") # cantitati medii multianuale 
tmed <- read.csv("input/tmed_monthly.csv") # temperatura medie multianuala
tmax <- read.csv("input/tmax_monthly.csv") # mediile temperaturilor maxime
tmin <- read.csv("input/tmin_monthly.csv") #  mediile temperaturilor minime
tmin.abs <- read.csv("input/tmin.abs_monthly.csv") # minimele absolute

# incepe iteratia pentru fiecare statie
tabf <- NULL
for (i in 1:nrow(prec)) {
  
  print(prec$NUME[i])
  # tabel pentru calcul
  tab <- data.frame( month = 1:12, P = t(prec[i,3:14]), Tn = t(tmin[i,3:14]), Tx = t(tmax[i,3:14]), t(tmed[i,3:14]),  AbsTn = t(tmin.abs[i,3:14]))
  names(tab) <- c("month", "P", "Tn", "Tx", "Tm", "AbsTn")
  # calculeaza tabel final
  tabi <- koeppen_geiger(clim_norm = tab,A_B_C_special_sub.classes = F, class.nr = F)
  
  tabf <- rbind(tabf,cbind(nume = prec$NUME[i], tabi))
}

write.csv(tabf, "output/statii_3_koeppen_1961_2015.csv")
