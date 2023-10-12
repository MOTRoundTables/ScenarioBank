#  a chart that presents agg values by year and scenario

createChronologicalGraph <- function(aFrcst, aVar,vistype = "point"){
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
  aFrcst$tazdata  %>% 
    group_by(Scenario,Year) %>% 
    summarise(res = sum(!!sym(aVar))) %>% {
      (.) %>% 
        ggplot(aes(x=Year,y = res,fill = Scenario,color = Scenario)) + 
        geom_first + 
        geom_second + 
        xlab(aVar)+ 
        expand_limits(y = 0) + 
        scale_y_continuous(labels = scales::comma)  
    } %>% ggplotly()
    
}
# createChronologicalGraph(aFrcst,"Pop","point")
