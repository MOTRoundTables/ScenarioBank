# scenario class

library(data.table)

# = scn class  =========================================

scnclass <- R6Class("scnclass",
    public = list(
        ky = NULL,
        name = NULL,
        scn = NULL,
        tazdata = NULL,
        tazdataSSS = NULL,
      
      initialize = function(scnnum) {
        self$ky = cfg$scnkeys[as.integer(scnnum)]
        self$scn = cfg$scenarios[[self$ky]]
        self$name = self$scn$name
      },
      
      opentazdata = function() {
        #browser()
        files = self$scn$files
        n = length(currentscn$scn$files)

        joinvar = currentscn$scn$files[[1]][[4]][[1]] 
        x <- vector(mode="list", length=n)
        for (i in 1:n) {
          fl = paste(currentscn$scn$dir, "/", currentscn$scn$files[[i]][[3]], sep="")        
          # x[[i]] <- fread(fl)  # read_csv(fl) read all vars ...
          tmp <- fread(fl)  # read_csv(fl)            
          vars = currentscn$scn$files[[i]][[4]]
          tmp = tmp %>%   # keep only vars
            select(all_of(vars))
          x[[i]] = tmp %>% rename_all( ~ paste0(currentscn$scn$files[[i]][[1]], "_", .x))
          colnames(x[[i]])[1] <- joinvar
        }
        self$tazdata = x %>% reduce(left_join, by=joinvar)
        self$tazdataSSS = x 
      },

      getscnlyr = function() {
        return(self$scn$tazlyr)
      },

      getagvars = function() {
        return(self$scn$agvars)
      },
      
      scn2lyr = function() {
        scn = self$scn # cfg$scenarios[[self$ky]]
        if (is.null(scn$tazname)) { scn$tazname = scn$tazlyr }  # can define optional tazname
        
        scnlyr <- list(
          lyr = self$getscnlyr(),        # the code of the layer
          name = scn$tazname,  
          zvar = scn$tazvar, 
          zname = "NA", 
          file = scn$tazfile,
          group = "forecasts",  # "שכבות תחזיות",
          url = paste(scn$dir, scn$tazfile, sep=""),
          pane = "other", 
          color = "#FF0000",
          weight = 2,
          fillOpacity = 0,
          popupcontent = "NA", #"'שכבת נפות<br>'+'מספר נפה =' + feature.properties.NafaNum + ' <br> שם נפה ='+feature.properties.Nafa",
          type  = "a", 
          initialstatus = 1,  # display
          status = 0
        )
        
        temp = list(scnlyr)
        temp = temp %>% 
          map_df(as_tibble)
        return(temp)
      }
      
      
  )
) # end mymap class



# = end ===========================================

