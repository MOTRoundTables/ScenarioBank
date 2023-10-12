

# simple map = 1 year, 1 var, values
# 2 create map op population for one scenario
createSimpleMap <- function(aFrcst, aScn = NA, aYr=NA, aVar0 = NA) {  
  #if(is.na(aScn)){
  #  aScn = aFrcst$Frcst$scnlist[1]
  #}
  #if(is.na(aYr)){
  #  aYr = aFrcst$Frcst$scenarios[[aScn]]$years[1]
  #}
  #if(is.na(aVar)){
  #  aVar =  aFrcst$data$dict$population
  #}

  aVar =  aFrcst$data$dict[[aVar0]]
  
  if (!aFrcst$tazdata%>% as_tibble() %>% pull(aVar) %>% class() %>% `%in%`(c("numeric","integer") )) {
    # print(aFrcst$tazdata%>% as_tibble() %>% pull(aVar) %>% class())
    aFrcst$tazdata <- aFrcst$tazdata %>% mutate(!!aVar := !!sym(aVar) %>% parse_number())
  }
  
  cat(aFrcst$name, aScn, aYr, aVar)
  x_join <- aFrcst$Frcst$dict$taz
  y_join <- aFrcst$frcst2lyr()$zvar
  filtered <- aFrcst$tazdata %>% as_tibble() %>% filter(Scenario == aScn, Year == aYr)
  with_geoms <- filtered %>% left_join(aFrcst$geolyr,by = setNames(y_join,x_join)) %>% st_sf()
  
  # 3 mapview population of scenario
  basemap$mapview +
    mapview(with_geoms,zcol = aVar)
}


