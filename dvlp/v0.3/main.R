#Sys.setlocale(locale="hebrew")

library(tidyverse)
#library(tidyjson)
library(jsonlite)   # https://cran.r-project.org/web/packages/jsonlite/index.html

# setwd("C:\\Users\\marsz\\OneDrive\\temp\\shiny\\scbank\\v1\\v1\\")  # for debug

source("maplib.R")
source("scnlib.R")
source("scn_dvlp.R")


currentsrc <- ""
currentscnnum <- 0
currentscn <- NULL
sss <- 0  # test variable

# - initialize
initapp <- function() {
  cfg = fromJSON("scbank.json") 
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
  
  n = length(cfg$scnkeys)
  cfg$scnlist = vector(mode = "list", length = n)
  cfg$scnchoices = vector(mode = "list")              # for menu
  for (i in 1:n) {
    ky = cfg$scnkeys[i]
    cfg$scenarios[[ky]]$num = i                       # save as internal ID
    cfg$scnlist[i] = cfg$scenarios[[ky]]$name         # scn names
    cfg$scnchoices[as.character(cfg$scnlist[i])] = i
    cfg$scenarios[[i]]$dir = paste0(cfg$general$scndir, cfg$scenarios[[i]]$dir, "/")
  }

  cfg$szkeys = names(cfg$superzones)                  # vector of SZ keys    
  n = length(cfg$szkeys)
  cfg$szlist = vector(mode = "list", length = n)      # for menu
  cfg$szchoices = vector(mode = "list")               # for menu 
  cfg$szlyrs = vector(mode = "list", length = n)      # for menu
  for (i in 1:n) {
    ky = cfg$szkeys[i]
    cfg$superzones[[ky]]$name = cfg$superzones[[ky]]$ename # alyr$hname  # set Eng or Heb
    cfg$superzones[[ky]]$url = gsub("<geodir>", cfg$general$geodir, cfg$superzones[[ky]]$url, fixed=TRUE)
    
    cfg$szlist[i] = cfg$superzones[[ky]]$lyr  #name
    cfg$sznames[i] = cfg$superzones[[ky]]$hname  # set Heb for menu
    cfg$szchoices[as.character(cfg$sznames[i])] = i
    cfg$szlyrs[i] = cfg$superzones[ky]
  }
  #cfg$szchoices0 = vector(mode = "list")  
  #cfg$szchoices0[cfg$messages$orgzns] = as.integer(0)
  #cfg$szchoices0 = append (cfg$szchoices0, cfg$szchoices)

  cfg$szlyrs = cfg$szlyrs %>% 
    map_df(as_tibble)
  #cfg$szlyrs['name'] <- ""
  cfg$szlyrs['status'] <- 0                        # lyrs %>% add_column(status = 0)  # NA


  cfg$szchoices0 = vector(mode = "list")  
  cfg$szchoices0[cfg$messages$orgzns] = as.integer(0)
  
  list("Choice 1" = 1, "Choice 2" = 2)  
  
  return(cfg)
}  

cfg <- initapp()
basemap = mymap$new()
basemap$createmap(cfg$basemap)
basemap$addlayers(cfg$szlyrs)
basemap$resetmapview(cfg$basemap)

# basemap$mapview
# basemap$map

# - main functions --------------------------------------------

# returns a list of scenarions for a selected source
getsrcscn <- function(asrc) {    #   asrc = "מודל תל אביב"
  n = length(cfg$scenarios)
  cfg$scnchoices <<- vector(mode = "list")  # view(cfg$scnchoices)
  for (i in 1:n) {
    ky = cfg$scnkeys[i]
    if (cfg$scenarios[[ky]]$source==asrc) {
      cfg$scnchoices[as.character(cfg$scnlist[i])] <<- i
    }
  }
  #return()
}  

setScn <- function(scnnum) {   # , session
  #browser()
  scn1 = scnclass$new(scnnum)
  
  # browser()
  # ky = cfg$scnkeys[as.integer(scnnum)]
  
  temp = scn1$scn2lyr()   # scn2lyr(cfg$scenarios[[ky]])
  basemap$addlayers(temp)  #, session
  basemap$setlayerscale(temp$lyr)
  return(scn1)  # cfg$scenarios[[scn1$ky]])
  }
############  basemap$lyrs <<- bind_rows(basemap$lyrs, temp) # view(basemap$lyrs)
#ky = "metrorings2008"  # to test
# amap = leafletProxy(map, session)
# addlyrtoLLmap(amap, ky)  #, session

HideCurrentSc <- function() {   # , session
  lyr = currentscn$getscnlyr()
  basemap$hidelyr(lyr)
}

HideSc <- function(scnnum) {   # , session
  # browser()
  ky = cfg$scnkeys[as.integer(scnnum)]
  temp = scn2lyr(cfg$scenarios[[ky]])
  basemap$hidelyr(temp$lyr)
  #return(cfg$scenarios[[ky]])
}

getScnFiles <- function(scnnum) {
  scnnum = 1 # to test
  ky = cfg$scnkeys[as.integer(scnnum)]
  scn = cfg$scenarios[[ky]]
  files = scn$files
  n = length(files)
  
  scnfiles = list()
  scnfiles$name = vector(mode = "list", length = n)
  for (i in 1:n) {
    scnfiles$name[i] = files[[i]][[1]]
  }
  return(scnfiles)
}


# - tests ------------------------- 

# add a layer from the array that was not loaded
#lyrcode = "ta2019"
#addlyr(lyrcode)


# = end =================================================

# rm(list=ls())

#basemap$map %>%
#  addMarkers(lng=35.0, lat=31.4, popup="<b>Hello</b>")

