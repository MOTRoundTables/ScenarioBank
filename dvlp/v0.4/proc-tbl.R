
subtable <- function(userreq) {
  aFrcst = userreq$frcst
  
  vrs = aFrcst$getfrcstbankvars()
  
  vrs = append(c('scenario','year'), vrs)
  x = aFrcst$tazdata %>% select(vrs)
  return(x)
  
}

# a table that summarizes the forecast
createSummaryTable <- function(userreq){

  aFrcst = userreq$frcst
  aScn = userreq$scn
  aVar = userreq$var
  aYr = userreq$yr  # assume 1 yr only  

  cat(aFrcst$name,  aVar)
  
  if(!aFrcst$tazdata%>% as_tibble() %>% pull(aVar) %>% class() %>% `%in%`(c("numeric","integer") )){
    # print(aFrcst$tazdata%>% as_tibble() %>% pull(aVar) %>% class())
    aFrcst$tazdata <- aFrcst$tazdata %>% mutate(!!aVar := !!sym(aVar) %>% parse_number())
  }
  
  x = aFrcst$tazdata  %>% 
    group_by(scenario, year) %>% 
    summarise(res = scales::comma(round(sum(!!sym(aVar))))) %>% 
    ungroup() %>% 
    spread(year,res) %>% 
    gt()
  
  return(x)
}
# createSummaryTable(aFrcst,aFrcst$Frcst$dict$population)
#frcstsummary <<- currentfrcst$tazdata %>%
#  summary()

#if(is.na(aVar)){
#  aVar =  aFrcst$Frcst$dict$population
#}


