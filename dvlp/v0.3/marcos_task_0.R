library(leaflet)
library(mapview)
library(sf)
library(geojsonsf) 
library(jsonlite)
library(tidyverse)
cfg = fromJSON("dvlp/v0.3/scbank.json") 
cfg$general$geodir = gsub("<sysdir>", cfg$general$sysdir, cfg$general$geodir, fixed=TRUE)
cfg$general$scndir = gsub("<sysdir>", cfg$general$sysdir, cfg$general$scndir, fixed=TRUE)
cfg$general$rsltdir = gsub("<sysdir>", cfg$general$sysdir, cfg$general$rsltdir, fixed=TRUE)

# load scenario dicts
n = length(cfg$scenariolist)
cfg$scenarios = list() 
cfg$scnsources = list()
cfg$scnkeys = vector()  
for (i in 1:n) {
  cfg$scnsources = append(cfg$scnsources, cfg$scenariolist[[i]][[1]])
  n2 = length(cfg$scenariolist[[i]][[2]])
  for (j in 1:n2) {
    cfg$scnkeys = append(cfg$scnkeys, cfg$scenariolist[[i]][[2]][[j]])
    x = fromJSON(paste(cfg$general$scndir, cfg$scenariolist[[i]][[2]][[j]], "/scenario.json", sep = ""))
    y = list()
    y[[cfg$scenariolist[[i]][[2]][[j]]]] = x
    cfg$scenarios = append(cfg$scenarios, y)
  }
}



scn <- cfg$scenarios$TA2016

# 1 open geo json
url = paste0("Scn_lib/",scn$dir,"/", scn$tazfile)
geolyr <- geojson_sf(url)
# 2 open taz data
fl = paste("Scn_lib/",scn$dir, "/", scn$file, sep="")        
tazdata = read_csv(fl)  

# 3 find a list of years in tazdata
years <- tazdata %>% distinct(Year) %>% pull(Year)
# 4 find a list of scenarios in tazdata
scens <- tazdaty = a %>% distinct(Scenario)%>% pull(Scenario)

# 5 generate a summary of population by scenario
tazdata %>% 
  group_by(Scenario) %>% 
  summarise(population = sum(population))

# 6 filter 1 scenario
filtered <- tazdata %>% filter(Scenario == scens[1])

# 7 leftjoin geolyr with tazdata
with_geoms <- filtered %>% left_join(geolyr,by = setNames("TAZV41","taz")) %>% st_sf()

# 8 mapview population of scenario
with_geoms %>% mapview(zcol = "population")
