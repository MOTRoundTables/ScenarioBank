# scenario class

library(data.table)

# = Frcst class  =========================================

frcstclass <- R6Class("Frcstclass",
    public = list(
      num = NULL,
      ky = NULL,
      name = NULL,
      dir = NULL,
      
      data = NULL, 
      
      # scenarios
      scnlist = NULL, 
      scnnames = NULL, 
      scnchoices = NULL, 

      # vars
      vars = NULL, 
      vardesc = NULL, 
      varchoices = NULL, 
      bankvars = NULL, 

      # data
      geolyr = NULL,
      tazdata = NULL,

      initialize = function(num, frcstky, frcstdir) {
        self$num = num
        self$ky = frcstky
        
        x = fromJSON(paste0(frcstdir, frcstky, "/scenario.json"))
        self$name = x$name
        self$dir = paste0(frcstdir, x$dir, "/")
        self$data = x
        
        self$scnlist = names(x$scenarios)
        self$scnnames = list()
        self$scnchoices = vector(mode = "list") 
        for (i in 1:length(self$scnlist)) {
          y = x$scenarios[[self$scnlist[i]]]
          self$scnnames = append(self$scnnames, y$desc)
          self$scnchoices[y$desc] = self$scnlist[i]
        }
        
       self$vars = names(x$dict)
       self$vardesc = list()
       self$bankvars = list()
       for (i in 1:length(self$vars)) {
         y = x$dict[[self$vars[i]]]
         if (!is.null(y$bank)) {
           self$bankvars[[y$bank]] = self$vars[i]
         }
         if (!is.null(y$description)) {
           self$vardesc = append(self$vardesc, y$description)
         }
       }

       self$varchoices = vector(mode = "list") 
       for (i in 2:length(self$vars)) {
         self$varchoices[as.character(self$vardesc[i])] = self$vars[i]
         }

      },
      
      loadfrcst = function() {
        currentfrcst$getgeolyr()
        currentfrcst$opentazdata()  
      },
      
      
      # - forecast layer -------------------------------------      
      
      getfrcstlyr = function() {
        return(self$data$tazlyr)
      },

      getgeolyr = function() {
        if (is.null(self$geolyr)) {
          url = paste(self$dir, self$data$tazfile, sep="")
          #self$geolyr <- geojson_read(url, what = "sp")   # at this stage only support geojson
          self$geolyr <- geojson_sf(url)
        }
        #return(self$geolyr)
      },
      
      frcst2lyr = function() {
        if (is.null(self$data$tazname)) { self$data$tazname = self$data$tazlyr }  # can define optional tazname

        frcstlyr <- list(
          lyr = self$getfrcstlyr(),        # the code of the layer
          name = self$data$tazname,  
          zvar = self$data$tazvar, 
          zname = "NA", 
          #file = self$data$tazfile,
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
        
        temp = list(frcstlyr)
        temp = temp %>% 
          map_df(as_tibble)
        return(temp)
      },

            
      # - forecast data functions  --------------------------------
      
      opentazdata = function() {
        fl = paste(self$dir, "/", self$data$file, sep="")        
        self$tazdata = fread(fl)  # read_csv(fl)            
      },

      getfrcstvars = function() {
        v = self$vars[2:length(self$vars)]
        return(v)
      },

      getfrcstbankvars = function() {
        v = unlist(self$bankvars, use.names = FALSE)
        return(v)  #(v[2:length(v)])
      },

      # - scenario functions  -------------------------------------      
      
      getscnyears = function(ascn) {
        return(self$data$scenarios[[ascn]]$years)
      },


      # - aggregation functions  -------------------------------------      
      
      getagvars = function() {
        return(self$data$agvars)
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




