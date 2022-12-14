# maplib - handle map operations with mymapclass# 

#Sys.setlocale(locale="hebrew")

library(R6)
library(leaflet)
library(mapview)
#library(sp)
library(sf)
library(geojson)
library(geojsonio)

mymap <- R6Class("mymapclass",
        public = list(
            name = NULL,
            mapview = NULL,
            lyrs = NULL,         # a dataframe of the layers in the map "lyr" is the layer name
            lyrsdata = NULL,
            loadedlayers = 0,
                 
            # - creates map with mapview()
            createmap = function(mapproperties) {
                #browser()

                self$name = mapproperties$mapname
                mapviewOptions(basemaps = c("CartoDB.Positron", "CartoDB.Voyager"))

                self$mapview = mapview()
                
                #self$mapview@map <- self$mapview@map %>% 
                #   setView(lng = mapproperties$initial_lon, lat = mapproperties$initial_lat, zoom = mapproperties$initial_zm)   
                   
                self$mapview@map <- self$mapview@map %>%
                   addMapPane("back", zIndex = 500) %>%
                   addMapPane("other", zIndex = 1000) %>%
                   addMapPane("front", zIndex = 1500)
                   
                #self$mapview@map <- self$mapview@map %>% addLayersControl(
                #    baseGroups = c("CartoDB.Positron", "CartoDB.Voyager"),
                #    options = layersControlOptions(collapsed = FALSE)
                #)
            },
            
            resetmapview = function(mapproperties) {
              self$mapview@map <- self$mapview@map %>% 
                setView(lng = mapproperties$initial_lon, lat = mapproperties$initial_lat, zoom = mapproperties$initial_zm)   
            },

            getnumloadedlayers = function() {
              print(self$loadedlayers)
            },
            
            displaymap = function() {
              #m <- self$mapview@map
              return(self$mapview@map)
            },

            # - layer functions
            
            lyrnum = function(alyr) {  
              i <- which(self$lyrs$lyr == alyr)
              if (length(i)==0) {  # showmessage("bad layer code")
                i = 0 
              }
              return(i)
            },

            setlayerscale = function(alyr) {
              i = self$lyrnum(alyr)
              b = basemap$lyrsdata[[i]]@bbox  # bbox(basemap$lyrsdata[[i]])
              self$mapview@map <- self$mapview@map %>% 
                fitBounds(b[1], b[2], b[3], b[4])
            },

            loadlyr = function(alyr) {  # alyr is a DF of lyr attributes
              #browser()
              
              cat(paste(alyr$lyr, "\n"))

              l1 <- geojson_read(alyr$url, what = "sp")   # at this stage only support geojson
              m = mapview(l1, layer.name = alyr$lyr, legend = FALSE,
                          color = alyr$color, alpha.regions = alyr$fillOpacity,lwd = alyr$weight)
              
              if (self$loadedlayers == 0) {
                self$mapview <- m
              } else {
                self$mapview <- self$mapview + m
              }
              self$loadedlayers = self$loadedlayers + 1
              return(list("name" = alyr$lyr, "data" = l1))
            },

            hidelyr = function(alyr) { 
              self$mapview@map <- self$mapview@map %>% hideGroup(alyr)
            },

            showlyr = function(alyr) { 
              self$mapview@map <- self$mapview@map %>% showGroup(alyr)
            },

            # ------------------------------------------------------------
            # add layers - set a lyrs is a df with initialstatus : 0 do not load, 1 load&display, 2 load&no display
            # status 1 = loaded
            addlayers = function(lyrs) { # view(basemap$lyrs)
              #browser()

              if (is.null(self$lyrs)) {
                self$lyrs <- lyrs
                self$lyrsdata <- vector(mode = "list", length = nrow(lyrs))
                nstrt = 1
                nend = nrow(self$lyrs)
                load = 1
              } else {  
                i = self$lyrnum(lyrs[1,]$lyr) # assume one at a time ...
                if (i==0) { # new layer
                  self$lyrs <<- bind_rows(self$lyrs, lyrs) # append
                  nstrt = nrow(self$lyrs)
                  nend = nrow(self$lyrs)
                  load = 1
                } else {
                  load = 0
                }
                
              }
              
              # add layers
              if (load) {
                for (i in nstrt:nend) {       # for-loop over rows
                  if (self$lyrs$initialstatus[i]>0) {
                    result = self$loadlyr(self$lyrs[i,])  #  Load the layer to the map
                    #self$lyrs$name[i] = result$name
                    self$lyrs$status[i] = 1
                    self$lyrsdata[[i]] = result$data
                    if (self$lyrs$initialstatus[i] == 2) { self$hidelyr(self$lyrs$lyr[i]) }
                  }
                }
              } else  {  # display existing layer
                self$showlyr(self$lyrs[i,]$lyr)
                self$lyrs$status[i] = 1
              }

            },
            
            addlayersfromurl = function(url) {
              lyrs = fromJSON(url) %>% as.data.frame      # View(basemap$lyrs)
              #addlayers(map, lyrs) 
            }  
            
      ) # end public
) # end mymap class


# OLD CODE ------------------------------------------

#lyrs$status[i] = 1
#if (lyrs$initialstatus[i] == 2) { self$hidelyr(lyrs$name[i]) }


# test add lyr
# addlyr("metrorings2008")
# basemap$map



# ------------------------------------------------------

test1 <- function(amap, session) {
  sss <<- leafletProxy(amap, session) %>%
   addMarkers(lng=35.0, lat=31.4, popup="<b>Hello</b>")      
  sss <<- leafletProxy(amap, session) %>%
    addMarkers(lng=35.0, lat=32.4, popup="<b>Hello1</b>")      
}

test2 <- function(amap, session) {
  m = leafletProxy(amap, session) 
  m %>%
    addMarkers(lng=35.0, lat=31.4, popup="<b>Hello</b>")      
  m %>%
    addMarkers(lng=35.0, lat=32.4, popup="<b>Hello1</b>")      
}

test3 <- function(amap, session) {
  m = leafletProxy(amap, session) 
  m %>%
    addMarkers(lng=34.5, lat=31.4, popup="<b>Hello</b>")      
  m %>%
    addMarkers(lng=34.5, lat=32.4, popup="<b>Hello1</b>")      
}



# = dialog functions =========================================

showmessage <- function(msg) {
  showNotification(
    msg,
    duration = NA,   # or set seconds
    closeButton = TRUE,
    type = "message"  # "default", "message", "warning", "error", NULL
  )
}  

showmodalmessage <- function(ttl, msg) {
  showModal(modalDialog(
  title = ttl, msg ))
}


# = leaflet =========================================

# leaflet functions
# https://rstudio.github.io/leaflet/
# https://www.rdocumentation.org/packages/leaflet/versions/2.1.1
# https://www.r-bloggers.com/2021/01/visualizing-geospatial-data-in-r-part-3-making-interactive-maps-with-leaflet/
# https://bookdown.org/nicohahn/making_maps_with_r5/docs/introduction.html
# panes
# https://gis.stackexchange.com/questions/284112/order-of-vector-layers-in-leaflet-r
#https://r-spatial.github.io/leafem/index.html
# add custom plugin:
# https://gist.github.com/jcheng5/c084a59717f18e947a17955007dc5f92
# https://bhaskarvk.github.io/leaflet.extras/


# map,  layerId = NULL, group = NULL, 
# stroke = TRUE, color = "#03F", weight = 5, opacity = 0.5, fill = TRUE, fillColor = color, fillOpacity = 0.2, 
# dashArray = NULL, smoothFactor = 1, noClip = FALSE, 
# popup = NULL, popupOptions = NULL, label = NULL, labelOptions = NULL, 
# options = pathOptions(), highlightOptions = NULL, data = getMapData(map)
# options = pathOptions(pane = "polygons"))

#  addLegend("bottomright", pal = cv_pal, values = ~cv_large_countries$deaths_per_million,
#            title = "<small>Deaths per million</small>") 

#addLayersControl(
#  position = "bottomright",
#  overlayGroups = c("2019-COVID (new)", "2019-COVID (cumulative)", "2003-SARS", "2009-H1N1 (swine flu)", "2014-Ebola"),
#  options = layersControlOptions(collapsed = FALSE)) 


#onEachFeature: function(feature, layer) {
#  if (feature.properties) {
#    var popupcontent = '????:????<br>'+'???? ????? ?????:' + feature.properties.TAZ_1250 + ' <br> ?? ????:'+feature.properties.city_name;
#    layer.bindPopup(popupcontent);
#  }
#}


# geojson : 
# https://cran.r-project.org/web/packages/geojsonR/vignettes/the_geojsonR_package.html
# https://www.rdocumentation.org/packages/geojsonio/versions/0.7.0/topics/geojson_r
# https://cran.r-project.org/web/packages/geojsonR/vignettes/the_geojsonR_package.html

# = end ===========================================

# adress cell (basemap$lyrs$loadonstart[i]==1) 
#basemap$lyrs['status'] <- 0                 # lyrs %>% add_column(status = 0)  # NA
#   alyr <- subset(basemap$lyrs, code == lyrcode)    #alyr = basemap$lyrs %>% filter(code == lyrcode)


#addlyrtoLLmap <- function(amap, lyrcode) {  #, session
#  #browser()
#  i <- which(basemap$lyrs$lyr == lyrcode)
#  if (length(i)==0) {
#    showmessage("bad layer code")
#    return(0)
#  }
  
#  #result <- loadlyr(amap, basemap$lyrs[i,])  #  return(list("map" = map, "data" = l1))
  
#  alyr = basemap$lyrs[i,]
#  cat(alyr$name)    #cat(alyr$url)
#  cat("\n")
  
#  l1 <- geojson_read(alyr$url, what = "sp")
#  b = bbox(l1)
  
#  amap <- amap %>%
##    addPolygons(data = l1, group = alyr$name,
#               stroke = TRUE, weight = alyr$weight, 
#                color = alyr$color, fillOpacity = alyr$fillOpacity,
#                options = pathOptions(pane = alyr$pane)
#                #,popup = ~alyr$zoneid # esto no funciono
#    ) 
#  #return(list("map" = map, "data" = l1))
  
  #basemap$map <<- result$map
#  basemap$lyrs$status[i] <<- 1
#  basemap$lyrsdata[[i]] <<- l1 # result$data
  
# loadedlayers = basemap$lyrs %>% filter(status == 1)    
  
  # add layers control 
  #basemap$map <<- basemap$map %>%
#  amap <<- amap %>%
#   addLayersControl(                    # Layers control
#     baseGroups = c("base", "color"),
#     overlayGroups = loadedlayers$name,   # c("back", "other"),
#     options = layersControlOptions(collapsed = FALSE)
#   )
#  amap <<- amap %>% fitBounds(b[1], b[2], b[3], b[4])
#}

#lyrs['status'] <- 0                         # lyrs %>% add_column(status = 0)  # NA



# loadedlayersnames = lyrs %>% filter(status == 1)    
# add layers control    
# map = map %>%
#  addLayersControl(                    # Layers control
#    baseGroups = c("base", "color"),
#    overlayGroups = loadedlayersnames$name,   # c("back", "other"),
#    options = layersControlOptions(collapsed = FALSE)
#  )


# add layers control 
#loadedlayers = basemap$lyrs %>% filter(status == 1)    
#basemap$map <<- basemap$map %>%
#  addLayersControl(                    # Layers control
#    baseGroups = c("base", "color"),
#    overlayGroups = loadedlayers$name,   # c("back", "other"),
#    options = layersControlOptions(collapsed = FALSE)
#  )
