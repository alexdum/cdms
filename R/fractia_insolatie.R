setwd("~/D/Alex/Clima/2021/cdms")
if (!require("dplyr")) install.packages("dplyr")

# citeste durata potentiala
durata <- read.csv("output/durata_potentiala.csv") %>% mutate(date = substr(time, 1, 10))

# citeste durata de stralucire
stralucire <- read.csv("input/stralucire_soare_2021.csv") %>% mutate(date = substr(dat, 1, 10))


fractia <- stralucire %>% left_join(durata, by = c("cod" = "CODGE", "date" = "date")) %>%
           mutate(fractia = durs/day_length)

# scrie datele
write.csv(fractia, "output/fractia_insolatie.csv", row.names = F)

