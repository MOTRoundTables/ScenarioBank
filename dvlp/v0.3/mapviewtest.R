# View(cfg)
# Sys.setlocale(locale="hebrew")
setwd("C:/Users/marsz/Documents/GitHub/ScenarioBank/v0.3")  # for debug

source("main.R")
source("maplib.R")
source("Frcstlib.R")

currentfrcstnum <<- "7"  # new jer
currentfrcst <<- setFrcst(currentfrcstnum) # set scenario, session
currentfrcst$opentazdata()

View(basemap)
view(basemap$lyrs)


basemap$mapview
basemap$mapview@map
basemap$displaymap()
class(basemap$mapview@map)

x = currentfrcst$Frcst$tazlyr
basemap$mapview@map <- basemap$mapview@map %>% hideGroup(x)
basemap$mapview


basemap$hidelyr(temp$lyr)



alyr = currentfrcst$getFrcstlyr()
i = basemap$lyrnum(alyr)
lyrdata = basemap$lyrsdata[[i]]

yourDF <- as.data.frame(lyrdata)

m = mapview(lyrdata, zcol = "DISTRICT", col.regions = clrs, legend = TRUE )
m

lyrdata %>%
  mutate(dist = as.character("DISTRICT")) %>%
  mapview(zcol = "dist", legend = TRUE)

class(lyrdata)


clrs <- sf.colors
m = mapview(lyrdata, zcol = "DISTRICT", col.regions = clrs, legend = TRUE )
#m = mapview(lyrdata, zcol = "DISTRICT", col.regions = clrs, burst=TRUE, legend = FALSE)
m

colors <- mapviewColors(x=lyrdata,
                        zcol = "DISTRICT", 
                        colors = c("Red", "Green", "Blue"),
                        at = c("1","7", "4"))
m = mapview(lyrdata, zcol = "DISTRICT",col.regions = colors)
m
view(lyrdata)



alyr = currentfrcst$Frcst2lyr()
#i = self$addlyr(alyr)

currentfrcst$getgeolyr()
m = mapview(currentfrcst$geolyr, layer.name = alyr$lyr, legend = FALSE,
            color = alyr$color, alpha.regions = alyr$fillOpacity,lwd = alyr$weight)
self$mapview <- self$mapview + m




basemap$mapview = basemap$mapview + m


basemap$mapview(breweries) 

m = basemap$mapview + breweries



m = basemap$mapview() %>%
  basemap$mapview(alyr, zcol = "ISPALE")

m = basemap$mapview(alyr, zcol = "ISPALE")
basemap$mapview <- basemap$mapview + m

myfun <- function(map){
  addCircles(map,12.5,42,radius=500) %>% addMarkers(12,42,popup="Rome")
}

mapview()

mymap() %>% myfun() %>% setView(lng = (lngRng[1]+lngRng[2])/2, lat = (latRng[1]+latRng[2])/2, zoom = input$map_zoom)

i = basemap$lyrnum(alyr)
b = basemap$lyrsdata[[i]]@bbox  # bbox(basemap$lyrsdata[[i]])
basemap$mapview@map <- basemap$mapview@map %>% 
  fitBounds(b[1], b[2], b[3], b[4])

mapview(breweries)

basemap$mapview@map(franconia)

mapview(franconia)

breweries  
  
  basemap$mapview@map(layer.name = alyr, zcol = "ISPALE")

lyr

lyr %>%
  basemap$mapview(zcol = "ISPALE")

  basemap$mapview(breweries, zcol = "founded") 

basemap$mapview(layer.name =lyr, zcol = "ISPALE")

basemap$mapview

m = mapview(l1, layer.name = alyr$lyr, legend = FALSE,
            color = alyr$color, alpha.regions = alyr$fillOpacity,lwd = alyr$weight)



currentfrcst$tazdata
currentfrcst$tazdata %>%
  summary()




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



