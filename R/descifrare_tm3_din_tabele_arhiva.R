library(dplyr)
library(zoo)
library(xlsx)
library(chron)
library(climatetools)
rm(list = ls())

setwd("/mnt/D/Alex/Clima/2021/cdms")

ws <- ws %>% filter(!NUME %in% c("Varadia de Mures", "Sibiu Zoo",  "Tg. Mures Zoo", "Horezu 1550", "Constanta Dig"))
statie <- "bacau"

codst <- ws$CODST[grep(statie, ws$NUME, ignore.case = T)]
files <- list.files("input/tabs/tm3/", pattern = ".csv$", full.names = T)

ani <- strsplit(files, "_|\\.") %>% do.call(rbind,.) %>%data.frame() %>% select(X2) %>% unlist()


for (i in 1:length(ani)) {
  tab.f <- NULL
  
  cat(ani[i], sep = "\n")
  tab.s <- read.table(grep(ani[i], files, value = T), sep = ",") %>% select(1:6) %>% na.locf() %>%
    mutate(time = as.POSIXct(paste0(V1,sprintf("%02d",V2),sprintf("%02d",V3),sprintf("%02d",V4),sprintf("%02d",V5)), "%Y%m%d%H%M", tz = "UTC"))
  #tab.s <- tab.s[grep("e", tab.s$V1, invert = T),]
  
  # cand incepe cu cantitate zero
  # matrice pentru fiecare secvență de ploaie
  index_zero <- which(tab.s$V6 == 0)
  index_final <- c(index_zero - 1, nrow(tab.s))[-1]
  matrix.index <- cbind(index_zero,index_final)
  ploaie.an <- NULL
  
  for (m in 1:nrow(matrix.index)) {
    
    tab.si <- tab.s[c(matrix.index[m,1]:matrix.index[m,2]),]
    #tab.si <- NA
    tab.si$cant[2:nrow(tab.si)] <- diff(tab.si$V6)
    
    
    
    tabf.f <- rbind(tab.f, tab.si[, c("time", "cant")])
  }
  
  saveRDS( tabf.f, paste0("output/tabs/tm3/",statie,"_",codst,"_",ani,".rds"))
}

#write.xlsx(val.max, "tabs/maxime/ver.xlsx", row.names = F)

