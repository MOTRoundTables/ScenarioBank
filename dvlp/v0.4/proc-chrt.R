#  a chart that presents agg values by year and scenario

createChronologicalGraph <- function(userreq ,vistype = "point"){
  aFrcst = userreq$frcst
  aScn = userreq$scn
  aYr = userreq$yr  # assume 1 yr only  
  aVar = userreq$var[[1]]
  cat(aFrcst$name,  aVar)
  
  if(vistype == "point"){
    geom_first = geom_line()
    geom_second = geom_point(size = 3,shape = 15)
  } else if (vistype == "col"){
    geom_first = geom_col(position = "dodge")
    geom_second = geom_blank()
  }
  
  if(!aFrcst$tazdata%>% as_tibble() %>% pull(aVar) %>% class() %>% `%in%`(c("numeric","integer") )){
    # print(aFrcst$tazdata%>% as_tibble() %>% pull(aVar) %>% class())
    aFrcst$tazdata <- aFrcst$tazdata %>% mutate(!!aVar := !!sym(aVar) %>% parse_number())
  }
  
  x = aFrcst$tazdata  %>% 
    group_by(scenario,year) %>% 
    summarise(res = sum(!!sym(aVar))) %>% {
      (.) %>% 
        ggplot(aes(x=year,y = res,fill = scenario,color = scenario)) + 
        geom_first + 
        geom_second + 
        xlab(aVar)+ 
        expand_limits(y = 0) + 
        scale_y_continuous(labels = scales::comma)  
    } %>% ggplotly()

  return(x)  
}
# createChronologicalGraph(aFrcst,"Pop","point")
