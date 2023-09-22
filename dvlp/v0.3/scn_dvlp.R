
library(tidyverse)
#library(tidyjson)
library(jsonlite)   # https://cran.r-project.org/web/packages/jsonlite/index.html

dr = "C:/Users/marsz/Documents/GitHub/ScenarioBank/dvlp/v0.3/"
setwd(dr)
cfg = fromJSON("scbank.json") 
cfg$general$scndir = gsub("<sysdir>", cfg$general$sysdir, cfg$general$scndir, fixed=TRUE)

n = length(cfg$scenariolist)

cfg$scnsources = list()
cfg$scnkeys = list()
cfg$scenarios = list() 


for (i in 1:n) {
  cfg$scnsources = append(cfg$scnsources, cfg$scenariolist[[i]][[1]])
  cfg$scnkeys = append(cfg$scnkeys, cfg$scenariolist[[i]][[2]])
}

i = 1
n2 = cfg$scenariolist[[i]][[2]]
for (j in 1:n2) {
  x = paste(cfg$general$scndir, cfg$scenariolist[[i]][[j]], "/scenario.json")
  x = fromJSON(paste(cfg$general$scndir, cfg$scenariolist[[i]][[j]], "/scenario.json"))
}




test1 = function() {
  showmessage("test 1")
}
  