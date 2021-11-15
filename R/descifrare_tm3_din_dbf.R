library(readxl)
library(dplyr)
library(tidyr)
library(foreign)
options(warn = 2)

tab <- read.dbf("input/tabs/tm3/OCNASUG.DBF")
# write.csv(tab, "tabs/dbfs/zalau_1983_1990.csv", row.names = F)

# tab <- read.csv("tabs/dbfs/pitesti_1949_1990.csv")
# # elimina randurile cu probleme identificate
# tab <- tab[grep("e", tab$CODL, invert = T),]

# numar ploaie cu an 
tab$an_nrp <-  paste0(tab$AN,sprintf("%03d", tab$NRP))

nrp <- unique(tab$an_nrp)

df.f <- NULL

for (i in 1:length(nrp)) {
  
  tab1 <- tab %>% filter(an_nrp %in% nrp[i]) %>%
    distinct() # remove duplicated rows
  # tab1 <- tab %>% filter(an_nrp %in% "87029")
  
  # elimină sfârșitul unei ploi, care nu are început în luna aprilie
  if (tab1$SECVT[1] != 10) tab1 <- tab1[-1,]
  
  # dacă nu ai mai mult de o secvență dar și cu precipitații 
  # s-a întmplat la timișoara să ai doar o secvență de precipitații fără cantități
  if (nrow(tab1) == 1) next
  
  
  date.start1 <- as.POSIXct(paste0("19",tab1$AN[1], sprintf("%02d",tab1$LUNA[1]),sprintf("%02d",tab1$ZI[1]),
                                   sprintf("%04d",tab1$ORA1[1])), format = "%Y%m%d%H%M", tz = "UTC")
  # date.start2 <-  as.POSIXct(paste0("19",tab1$AN[2], sprintf("%02d",tab1$LUNA[2]),sprintf("%02d",tab1$ZI[2]),
  #                                   sprintf("%04d",tab1$ORA1[2])), format = "%Y%m%d%H%M", tz = "UTC")
  if (is.na(date.start1)) next
  
  df.i <- data.frame(time = date.start1, cant = NA)
  dff1 <- NULL
  
  for (r in 2:nrow(tab1)) {
    #print(r)
    
    tab2b  <- tab1[r,] 
    
    if (r == 2)  {
      
      df.time1  <- date.start1 +  tab2b$DUR1 * 60
    } else {
      df.time1 <- df$time[nrow(df)] + tab2b$DUR1 * 60
    }
    
    df1 <- data.frame(time = df.time1, cant = tab2b$CANT1)
    df2 <- data.frame(time = df1$time + tab2b$DUR2 * 60, cant = tab2b$CANT2)
    df3 <- data.frame(time = df2$time + tab2b$DUR3 * 60, cant = tab2b$CANT3)
    df4 <- data.frame(time = df3$time + tab2b$DUR4 * 60, cant = tab2b$CANT4)
    df5 <- data.frame(time = df4$time + tab2b$DUR5 * 60, cant = tab2b$CANT5)
    df6 <- data.frame(time = df5$time + tab2b$DUR6 * 60, cant = tab2b$CANT6)
    
    df <- do.call("rbind", list(df1, df2, df3, df4, df5, df6))
    # elimina NA-urile cand nu ai cantitati
    df <- df[complete.cases(df), ]
    
    dff1 <- rbind(dff1, df)
    
    
    
  }
  
  # cand nu ai cantitati
  if (max(dff1$cant) == 0) next
  
  dff1 <- rbind(df.i,dff1)
  
  df.f <- rbind(df.f, dff1)
  
  
}

# identificare suprapunere ploi
time.dupl <- df.f$time[duplicated(df.f$time)]
# selectare secvente suprapuse
df.s <- df.f[df.f$time %in% time.dupl,]

write.csv(df.s, "output/tabs/tm3/dbf_probleme/ocsug_1968_1990._suprapuneri.csv", row.names = F)

# eliminare secvente care se suprapun
df.f <- df.f[!df.f$time %in% time.dupl,]


df.f$cant <- df.f$cant * 0.1

saveRDS(df.f, "output/tabs/tm3/ocsug_1968_1990.rds")



#View(tab %>% filter(AN == 90, LUNA == 4) )
