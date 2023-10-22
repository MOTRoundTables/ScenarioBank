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

View(cfg$views)
x = cfg$views

basemap$mapview@map 
basemap$mapview@map %>%setView(35.211714, 32.888926, 8)

basemap$mapview@map %>%fitBounds(34.733743, 31.988063, 34.875333,  32.197471)


basemap$mapview@map %>%fitBounds(31.988063, 34.733743, 32.197471, 34.875333)


basemap$mapview@map
b1 = c(34.816826, 31.601893)
b2 = c(34.816826, 31.601893)
b = c(b1, b2)
b

b = c(31.601893, 34.816826, 31.601893, 34.816826 )
b
fitBounds(b)

basemap$mapview@map %>%  fitBounds(35.024613, 32.384443, 35.024613, 32.384443)

fitBounds(basemap$mapview@map, 32.384443, 35.024613, 32.384443, 35.024613)
#fitBounds(basemap$mapview@map, 40.712, -74.227, 40.774, -74.125)

basemap$mapview@map %>% clearBounds() 

basemap$mapview@map %>% fitBounds(-72, 40, -70, 43)


m <- leaflet() %>% addTiles() %>% setView(-71.0382679, 42.3489054, zoom = 18)
m  # the RStudio 'headquarter'
m %>% fitBounds(-72, 40, -70, 43)
m %>% clearBounds()  # world view

m %>% clearBounds()  # world view


basemap$mapview@map

fitBounds(map, lng1, lat1, lng2, lat2, options = list())
?fitbounds



alyr = currentfrcst$getfrcstlyr()
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



alyr = currentfrcst$frcst2lyr()
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



