if (!require("dplyr")) install.packages("dplyr")

# citeste durata potentiala
durata <- read.csv("tabs/durata_potentiala.csv") %>% mutate(date = substr(time, 1, 10))

# citeste durata de stralucire
stralucire <- read.csv("tabs/stralucire_soare_2021.csv") %>% mutate(date = substr(dat, 1, 10))


fractia <- stralucire %>% left_join(durata, by = c("cod" = "CODGE", "date" = "date")) %>%
           mutate(fractia = durs/day_length)

# scrie datele
write.csv(fractia, "tabs/fractia_insolatie.csv", row.names = F)
