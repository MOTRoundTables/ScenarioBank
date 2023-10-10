#Sys.setlocale(locale="hebrew")

library(tidyverse)
library(dplyr)
library(gt)
library(plotly)
#library(tidyjson)
library(jsonlite)   # https://cran.r-project.org/web/packages/jsonlite/index.html

# setwd("C:\\Users\\marsz\\OneDrive\\temp\\shiny\\scbank\\v1\\v1\\")  # for debug


idoenv = "dvlp/v0.3/"
source(paste0(idoenv,"maplib.R"))
source(paste0(idoenv,"scnlib.R"))
source(paste0(idoenv,"utillib.R"))
# source(paste0(idoenv,"scn_dvlp.R"))
source(paste0(idoenv,"proc-tbl.R"))
source(paste0(idoenv,"proc-chrt.R"))
source(paste0(idoenv,"proc-map.R"))



# - initialize
initapp <- function() {
  cfg = fromJSON(paste0(idoenv,"scbank.json")) 
  cfg$general$geodir = gsub("<sysdir>", cfg$general$sysdir, cfg$general$geodir, fixed=TRUE)
  cfg$general$Frcstdir = gsub("<sysdir>", cfg$general$sysdir, cfg$general$frcstdir, fixed=TRUE)
  cfg$general$rsltdir = gsub("<sysdir>", cfg$general$sysdir, cfg$general$rsltdir, fixed=TRUE)

  # -- load scenario dict
  n = length(cfg$forecastslist)
  cfg$forecasts = list() 
  cfg$Frcstsources = list()
  cfg$Frcstkeys = vector()  
  for (i in 1:n) {
    cfg$Frcstsources = append(cfg$Frcstsources, cfg$forecastslist[[i]][[1]])
    n2 = length(cfg$forecastslist[[i]][[2]])
    for (j in 1:n2) {
      cat(cfg$forecastslist[[i]][[2]][[j]])
      cfg$Frcstkeys = append(cfg$Frcstkeys, cfg$forecastslist[[i]][[2]][[j]])
      x = fromJSON(paste(cfg$general$Frcstdir, cfg$forecastslist[[i]][[2]][[j]], "/scenario.json", sep = ""))
      x$scnlist = names(x$scenarios)
      x$scnnames = list()
      for (k in 1:length(x$scnlist)) {
        y = x$scenarios[[x$scnlist[k]]]
        x$scnnames = append(x$scnnames, y$desc) 
      }
      y = list()
      y[[cfg$forecastslist[[i]][[2]][[j]]]] = x
      cfg$forecasts = append(cfg$forecasts, y)
    }
  }
  
  # -- build Frcstchoices
  n = length(cfg$Frcstkeys)
  cfg$Frcstlist = vector(mode = "list", length = n)
  cfg$Frcstchoices = vector(mode = "list")              # for menu
  for (i in 1:n) {
    ky = cfg$Frcstkeys[i]
    cfg$forecasts[[ky]]$num = i                       # save as internal ID
    cfg$Frcstlist[i] = cfg$forecasts[[ky]]$name         # Frcst names
    #cfg$Frcstchoices[as.character(cfg$Frcstlist[i])] = i # Frcst numb
    cfg$allFrcstchoices[as.character(cfg$Frcstlist[i])] = ky # Frcst ky
    cfg$forecasts[[i]]$dir = paste0(cfg$general$Frcstdir, cfg$forecasts[[i]]$dir, "/")
  }

  # -- load super-zones dict
  tmp = fromJSON(paste(cfg$general$geodir, "szlyrs.json", sep=""))
  cfg$superzones = tmp$superzones

  # -- process forecasts
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

  # -- process super-zones
  cfg$szlyrs = cfg$szlyrs %>% 
    map_df(as_tibble)
  #cfg$szlyrs['name'] <- ""
  cfg$szlyrs['status'] <- 0                        # lyrs %>% add_column(status = 0)  # NA
  
  cfg$szchoices0 = vector(mode = "list")  
  cfg$szchoices0[cfg$messages$orgzns] = as.integer(0)
  # cfg$szchoices0 = append (cfg$szchoices0, cfg$szchoices)
  list("Choice 1" = 1, "Choice 2" = 2)  
  
  return(cfg)
}  

# define global vars

cfg <- initapp()

currentsrc <- ""
currentFrcstky <- ""
currentFrcst <- NULL

#Frcstsummary <- NULL


# start map
basemap = mymap$new()
basemap$createmap(cfg$basemap)
#basemap$addlayers(cfg$szlyrs)
basemap$resetmapview(cfg$basemap)

# basemap$mapview
# basemap$map

# - main functions --------------------------------------------

# returns a list of scenarions for a selected source
getsrcFrcst <- function(asrc) {    #   asrc = "מודל תל אביב"
  n = length(cfg$forecasts)
  cfg$Frcstchoices <<- vector(mode = "list")  # view(cfg$Frcstchoices)
  for (i in 1:n) {
    ky = cfg$Frcstkeys[i]
    if (cfg$forecasts[[ky]]$source==asrc) {
#      cfg$Frcstchoices[as.character(cfg$Frcstlist[i])] <<- i
      cfg$Frcstchoices[as.character(cfg$Frcstlist[i])] <<- ky
    }
  }
  return()
}  

setFrcst <- function(Frcstky) {   # , session
  cat(Frcstky)
  #browser()
  Frcst1 = Frcstclass$new(Frcstky)
  basemap$addFrcst(Frcst1)  #, session
  return(Frcst1)  # cfg$forecasts[[Frcst1$ky]])
}

  ############  basemap$lyrs <<- bind_rows(basemap$lyrs, temp) # view(basemap$lyrs)
  # ky = "metrorings2008"  # to test
  # amap = leafletProxy(map, session)
  # addlyrtoLLmap(amap, ky)  #, session

HideCurrentSc <- function() {   # , session
  lyr = currentFrcst$getFrcstlyr()
  basemap$hidelyr(lyr)
}

HideSc <- function(Frcstnum) {   # , session
  # browser()
  ky = cfg$Frcstkeys[as.integer(Frcstnum)]
  temp = Frcst2lyr(cfg$forecasts[[ky]])
  basemap$hidelyr(temp$lyr)
  #return(cfg$forecasts[[ky]])
}

getFrcstFiles <- function(Frcstnum) {
  Frcstnum = 1 # to test
  ky = cfg$Frcstkeys[as.integer(Frcstnum)]
  Frcst = cfg$forecasts[[ky]]
  files = Frcst$files
  n = length(files)
  
  Frcstfiles = list()
  Frcstfiles$name = vector(mode = "list", length = n)
  for (i in 1:n) {
    Frcstfiles$name[i] = files[[i]][[1]]
  }
  return(Frcstfiles)
}



# = end =================================================

# rm(list=ls())


