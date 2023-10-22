# colors :  https://r-graph-gallery.com/38-rcolorbrewers-palettes.html
#           https://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3
library(leafsync)
createMap <- function(userreq) {  
  if (userreq$mode==1) {x = createSimpleMap(userreq)}
  else { x = createMultiMap(userreq) }
  return(x)
}


# simple map = 1 scenario,  1 year, 1 var, values 
createSimpleMap <- function(userreq) {  
  aFrcst = userreq$frcst
  aScn = userreq$scn[[1]]
  aYr = userreq$yr[[1]]  # assume 1 yr only
  dataVar = userreq$var[[1]]
  
  cat(aFrcst$name, aScn, aYr, dataVar)
  
  # # if var is not number, parse it as number
  # if (!aFrcst$tazdata %>% as_tibble() %>% pull(dataVar) %>% class() %>% `%in%`(c("numeric","integer") )) {
  #   aFrcst$tazdata <- aFrcst$tazdata %>% mutate(!!dataVar := !!sym(dataVar) %>% parse_number())
  # }
  
  x_join <- aFrcst$bankvars$taz
  y_join <- aFrcst$data$tazvar
  aFrcst$loadfrcst()
  filtered <- aFrcst$tazdata %>% as_tibble() %>% filter(scenario == aScn, year == aYr)
  with_geoms <- filtered %>% left_join(aFrcst$geolyr, by = setNames(y_join,x_join)) %>% st_sf()
  
  # update basemap 
  
  colors <- rev(RColorBrewer::brewer.pal(12, "RdYlGn")) # RColorBrewer::brewer.pal(11, "RdBu")
  
  desc = userreq$dict[[dataVar]]$description
  
  x = mapview(with_geoms, zcol = dataVar, 
              layer.name = desc,
              col.regions = colors
  )
  
  return(x)
  
}

createMultiMap <- function(userreq){
  # if var is not number, parse it as number
  if (!userreq$frcst$tazdata %>% as_tibble() %>% pull(userreq$var) %>% class() %>% `%in%`(c("numeric","integer") )) {
    userreq$frcst$tazdata <- userreq$frcst$tazdata %>% mutate(!!userreq$var := !!sym(userreq$var) %>% parse_number())
  }
  x_join <- userreq$frcst$bankvars$taz
  y_join <- userreq$frcst$data$tazvar
  list_of_maps <- userreq$frcst$tazdata %>%
    filter(year %in% userreq$yr,scenario %in% userreq$scn) %>% 
    left_join(userreq$frcst$geolyr, by = setNames(y_join,x_join)) %>% 
    st_sf() %>% 
    group_split(year,scenario) %>% 
    map(~{
      colors <- rev(RColorBrewer::brewer.pal(12, "RdYlGn")) # RColorBrewer::brewer.pal(11, "RdBu")
      x = mapview(.x, zcol = userreq$var,
                  layer.name = paste(unique(.x$scenario),
                                     unique(.x$year)),
                  col.regions = colors
      )
      return(x)
    })
  res = sync(list_of_maps,ncol = min(3,length(userreq$yr)*length(userreq$scn)))
  return(res)
}

