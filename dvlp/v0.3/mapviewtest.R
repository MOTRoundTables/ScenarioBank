# View(cfg)
# Sys.setlocale(locale="hebrew")
setwd("C:/Users/marsz/Documents/GitHub/ScenarioBank/v0.3")  # for debug

source("main.R")
source("maplib.R")
source("scnlib.R")

currentscnnum <<- "7"  # new jer
currentscn <<- setScn(currentscnnum) # set scenario, session
currentscn$opentazdata()

alyr = currentscn$getscnlyr()
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



basemap$mapview = basemap$mapview + m

basemap$mapview



basemap$mapview
basemap$mapview@map
basemap$displaymap()


class(basemap$mapview)


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



currentscn$tazdata
currentscn$tazdata %>%
  summary()





