
source("main.R")


n = length(cfg$scnkeys)
cfg$scnlist = vector(mode = "list", length = n)
cfg$scnchoices = vector(mode = "list")              # for menu
for (i in 1:n) {
  ky = cfg$scnkeys[i]
  cfg$scnlist[i] = cfg$scenarios[[ky]]$name         # scn names
  cfg$scnchoices[as.character(cfg$scnlist[i])] = i
  cfg$scenarios[[i]]$dir = paste0(cfg$general$scndir, cfg$scenarios[[i]]$dir, "/")
}





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
    #browser()
    x = fromJSON(paste(cfg$general$scndir, cfg$scenariolist[[i]][[2]][[j]], "/scenario.json", sep = ""))
    y = list()
    y[[cfg$scenariolist[[i]][[2]][[j]]]] = x
    cfg$scenarios = append(cfg$scenarios, y)
  }
}



test1 = function() {
  showmessage("test 1")
}
  