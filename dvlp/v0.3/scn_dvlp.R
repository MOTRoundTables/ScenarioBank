
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
  n2 = length(cfg$scenariolist[[i]][[2]])
  for (j in 1:n2) {
  }
}


i = 1
n2 = length(cfg$scenariolist[[i]][[2]])
j = 1
y = fromJSON(paste(cfg$general$scndir, cfg$scenariolist[[i]][[2]][[j]], "/scenario.json", sep = ""))
cfg$scenarios = append(cfg$scenarios, list(list(cfg$scenariolist[[i]][[2]][[j]], y)))


j = 2
y = fromJSON(paste(cfg$general$scndir, cfg$scenariolist[[i]][[2]][[j]], "/scenario.json", sep = ""))
cfg$scenarios = append(cfg$scenarios, list(list(cfg$scenariolist[[i]][[2]][[j]], y)))


i = 1
n2 = length(cfg$scenariolist[[i]][[2]])
for (j in 1:n2) {
  y = fromJSON(paste(cfg$general$scndir, cfg$scnkeys[[i]][[j]], "/scenario.json", sep = ""))
  
}


a = list()
x = "aa"





test1 = function() {
  showmessage("test 1")
}
  