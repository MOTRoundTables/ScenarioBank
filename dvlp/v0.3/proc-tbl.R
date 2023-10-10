

# a table that summarizes the forecast
createSummaryTable <- function(aFrcst,aVar=NA){
  if(is.na(aVar)){
    aVar =  aFrcst$Frcst$dict$population
  }
  if(!aFrcst$tazdata%>% as_tibble() %>% pull(aVar) %>% class() %>% `%in%`(c("numeric","integer") )){
    # print(aFrcst$tazdata%>% as_tibble() %>% pull(aVar) %>% class())
    aFrcst$tazdata <- aFrcst$tazdata %>% mutate(!!aVar := !!sym(aVar) %>% parse_number())
  }
  cat(aFrcst$name,  aVar)
  aFrcst$tazdata  %>% 
    group_by(Scenario,Year) %>% 
    summarise(res = scales::comma(round(sum(!!sym(aVar))))) %>% 
    ungroup() %>% 
    spread(Year,res) %>% 
    gt()
  
}
# createSummaryTable(aFrcst,aFrcst$Frcst$dict$population)
