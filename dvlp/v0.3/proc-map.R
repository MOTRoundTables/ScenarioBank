
# simple map = 1 scenario,  1 year, 1 var, values 
createSimpleMap <- function(userreq) {  
  
  aFrcst = userreq$frcst
  aScn = userreq$scn
  aYr = userreq$yr
  dataVar = userreq$var

  #if(is.na(aScn)){
  #  aScn = aFrcst$Frcst$scnlist[1]
  #}
  #if(is.na(aYr)){
  #  aYr = aFrcst$Frcst$scenarios[[aScn]]$years[1]
  #}
  #if(is.na(aVar)){
  #  aVar =  aFrcst$data$dict$population
  #}

  #browser()
  
  cat(aFrcst$name, aScn, aYr, dataVar)  
    
  #if (!aFrcst$tazdata %>% as_tibble() %>% pull(dataVar) %>% class() %>% `%in%`(c("numeric","integer") )) {
  #  # print(aFrcst$tazdata%>% as_tibble() %>% pull(dataVar) %>% class())
  #  aFrcst$tazdata <- aFrcst$tazdata %>% mutate(!!dataVar := !!sym(dataVar) %>% parse_number())
  #}
  
  x_join <- aFrcst$bankvars$taz
  y_join <- aFrcst$data$tazvar
  
  filtered <- aFrcst$tazdata %>% as_tibble() %>% filter(scenario == aScn, year == aYr)
  with_geoms <- filtered %>% left_join(aFrcst$geolyr, by = setNames(y_join,x_join)) %>% st_sf()
  
  # update basemap 
  basemap$mapview =
    mapview(with_geoms,zcol = dataVar)
}



