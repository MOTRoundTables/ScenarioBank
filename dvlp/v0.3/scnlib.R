# scenario class

library(data.table)

# = Frcst class  =========================================

frcstclass <- R6Class("Frcstclass",
    public = list(
      num = NULL,
      ky = NULL,
      name = NULL,
      dir = NULL,
      
      # scenarios
      scnlist = NULL, 
      scenarios = NULL,
      scnnames = NULL, 
      scnchoices = NULL, 

      # vars
      vars = NULL, 
      dict = NULL, 

      # data
      geolyr = NULL,
      tazdata = NULL,

      initialize = function(num, frcstky, frcstdir) {
        self$num = num
        self$ky = frcstky
        
        x = fromJSON(paste0(frcstdir, frcstky, "/scenario.json"))
        self$name = x$name
        self$dir = paste0(frcstdir, x$dir, "/")
        
        self$scnlist = names(x$scenarios)
        self$scenarios = x$scenarios
        #self$scenarios = list()
        #for (i in 1:self$scnlist.length) {
        #  self$scenarios = append(self$scenarios, x$scenarios[i])
        #}
        
        self$scnnames = list()
        self$scnchoices = vector(mode = "list") 
        for (i in 1:length(self$scnlist)) {
          y = x$scenarios[[self$scnlist[i]]]
          self$scnnames = append(self$scnnames, y$desc)
          self$scnchoices[y$desc] = self$scnlist[i]
        }
        
        self$vars = names(x$dict)
        self$dict = x$dict
        # self$dict = list()
        # for (i in 1:self$vars) {
        #   self$dict = append(self$dict, x$dict[i])
        # }
      },
      

      # - forecast layer -------------------------------------      
      
      getFrcstlyr = function() {
        return(self$Frcst$tazlyr)
      },

      getgeolyr = function() {
        if (is.null(self$geolyr)) {
          url = paste(self$dir, self$Frcst$tazfile, sep="")
          #self$geolyr <- geojson_read(url, what = "sp")   # at this stage only support geojson
          self$geolyr <- geojson_sf(url)
        }
        #return(self$geolyr)
      },
      
      Frcst2lyr = function() {
        Frcst = self$Frcst # cfg$forecasts[[self$ky]]
        if (is.null(Frcst$tazname)) { Frcst$tazname = Frcst$tazlyr }  # can define optional tazname

        Frcstlyr <- list(
          lyr = self$getFrcstlyr(),        # the code of the layer
          name = Frcst$tazname,  
          zvar = Frcst$tazvar, 
          zname = "NA", 
          #file = Frcst$tazfile,
          group = "forecasts",  # "שכבות תחזיות",
          pane = "other", 
          color = "#FF0000",
          weight = 2,
          fillOpacity = 0,
          popupcontent = "NA", #"'שכבת נפות<br>'+'מספר נפה =' + feature.properties.NafaNum + ' <br> שם נפה ='+feature.properties.Nafa",
          type  = "a", 
          initialstatus = 1,  # display
          status = 0
        )
        
        temp = list(Frcstlyr)
        temp = temp %>% 
          map_df(as_tibble)
        return(temp)
      },
      
      # - forecast data  -------------------------------------      
      
      opentazdata = function() {
        fl = paste(self$Frcst$dir, "/", self$Frcst$file, sep="")        
        self$tazdata = fread(fl)  # read_csv(fl)            
      },


      # - aggregation data  -------------------------------------      
      
      getagvars = function() {
        return(self$Frcst$agvars)
      }
      
  )
) # end mymap class



# = end ===========================================

# old code
#opentazdata = function() {
#  #browser()
#  files = self$Frcst$files
#  n = length(currentfrcst$Frcst$files)
#  
#  flnew = ""
#  joinvar = currentfrcst$Frcst$files[[1]][[4]][[1]] 
#  x <- vector(mode="list", length=n)
#  for (i in 1:n) {
#    fl = paste(currentfrcst$Frcst$dir, "/", currentfrcst$Frcst$files[[i]][[3]], sep="")        
#    # x[[i]] <- fread(fl)  # read_csv(fl) read all vars ...
#    if (fl!=flnew) {
#      tmp <- fread(fl)  # read_csv(fl)            
#      flnew = fl
#    }
#    vars = currentfrcst$Frcst$files[[i]][[4]]
#    vars = vars[ !vars == "None"]
#    tmp1 = tmp %>%   # keep only vars
#      select(all_of(vars))
#    x[[i]] = tmp1 %>% rename_all( ~ paste0(currentfrcst$Frcst$files[[i]][[1]], "_", .x))
#    colnames(x[[i]])[1] <- joinvar
#  }
#  self$tazdata = x %>% reduce(left_join, by=joinvar)
#  self$tazdataSSS = x 
#},
#




