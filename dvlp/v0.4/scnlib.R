# scenario class

library(data.table)

# = Frcst class  =========================================

frcstclass <- R6Class("Frcstclass",
    public = list(
      num = NULL,           # ordinal # of frcst in cfg
      ky = NULL,            # frcst code
      name = NULL,          # frcst name
      dir = NULL,           # frcst directory
      
      data = NULL,          # a copy of scenario.json

      # scenarios
      scnlist = NULL,       # vector of available scn codes
      scnnames = NULL,      # vector of available scn names
      scnchoices = NULL,    # list of scn for menu [[name:code]]

      # data
      geolyr = NULL,        # the geojson data
      geodef = NULL,        # taz lyr def
      #geofile = NULL,
      
      tazdata = NULL,       # the frcst csv data
      tazfile = NULL,       # data file name
      tazfilevar = NULL,    # var name holding taz in data file
      
      aglvls = NULL,        # aggreagate levels     
      aglvl = NULL,         # current aggreagate level
      
      # vars
      vars = NULL,          # vector of dict vars
      vardesc = NULL,       # vector of dict vars descriptions
      bankvars = NULL,      # vector of bank vars in dict

      dispvars = NULL,      # vars 4 menu
      dispvarsgroup = NULL, # vars 4 menu grps
      dispvarsdesc = NULL,  # vars 4 menu descs
      dispvarssrc = NULL,   # vars 4 menu source (data/geo)
      
      varstree = NULL,      # list of vars for menu [[name:var]]
      varchoices = NULL,    # list of vars for menu [[name:var]]

      geochoices = NULL,    # list of ag for menu


      initialize = function(num, frcstky, frcstdir) {
        self$num = num
        self$ky = frcstky
        
        x = fromJSON(paste0(frcstdir, frcstky, "/scenario.json"))
        self$name = x$name
        self$dir = paste0(frcstdir, x$dir, "/")
        
        self$scnlist = names(x$scenarios)
        self$scnnames = list()
        self$scnchoices = vector(mode = "list") 
        for (i in 1:length(self$scnlist)) {
          y = x$scenarios[[self$scnlist[i]]]
          self$scnnames = append(self$scnnames, y$desc)
          self$scnchoices[y$desc] = self$scnlist[i]
        }
        
        # - prepare data vars (dict)
        self$vars = names(x$dict)   # list of ALL vars
        self$vardesc = list()       # list of ALL var descriptions
        self$dispvars = list()      # list of menu vars
        self$dispvarsgroup = list() # list of menu groups
        self$dispvarsdesc = list()  # list of menu var descriptions
        self$dispvarssrc = list()   # list of menu var sources
        self$bankvars = list()      # list of bank vars in scenario (bank=scenario pair)
        for (i in 1:length(self$vars)) {
          x$dict[[self$vars[i]]]$source = "data"
          y = x$dict[[self$vars[i]]]
          if (!is.null(y$bank)) {
            self$bankvars[[y$bank]] = self$vars[i]
          }
          self$vardesc = append(self$vardesc, ifelse(!is.null(y$description), y$description, self$vars[i]))
          #if (!is.null(y$description)) { self$vardesc = append(self$vardesc, y$description) }

          if ((y$group!="לא בשימוש")&&(y$group!="זיהוי")) {
            self$dispvars = append(self$dispvars, self$vars[i])
            self$dispvarsgroup = append(self$dispvarsgroup, y$group)
            self$dispvarsdesc = append(self$dispvarsdesc, ifelse(!is.null(y$description), y$description, self$vars[i]))
            self$dispvarssrc =  append(self$dispvarssrc, "data")
          }
        }
        
        # - add geo vars (geo dict)
        tmp = names(x$geodict)  
        self$vars = append(self$vars, tmp)   # list of ALL vars
        for (i in 1:length(tmp)) {
          x$geodict[[tmp[i]]]$source = "geo"
          y = x$geodict[[tmp[i]]]
          if (!is.null(y$bank)) {
            self$bankvars[[y$bank]] = tmp[i]
          }
          self$vardesc = append(self$vardesc, ifelse(!is.null(y$description), y$description, tmp[i]))

          if ((y$group!="לא בשימוש")&&(y$group!="זיהוי")) {
            self$dispvars = append(self$dispvars, tmp[i])
            self$dispvarsgroup = append(self$dispvarsgroup, y$group)
            self$dispvarsdesc = append(self$dispvarsdesc, ifelse(!is.null(y$description), y$description, tmp[i]))
            self$dispvarssrc =  append(self$dispvarssrc, "geo")
          }
        }

        self$varchoices = vector(mode = "list") 
        for (i in 2:length(self$dispvars)) {
          self$varchoices[as.character(self$dispvarsdesc[i])] = self$dispvars[i]
        }

        # - geo/ag zones
        self$tazfile = x$file
        self$tazfilevar = self$bankvars$taz
        self$aglvl = "taz"   # starts with taz
        if (!is.null(x$ag)) { self$aglvls = x$ag }  # add aggregate options

        # - keep scenario.json
        self$data = x  # save scenario json data
        self$geodef = self$frcst2lyr()        
      },  # - end initialize
      
      
      # - scenario functions  -------------------------------------      
      
      loadfrcst = function() {  # loads frcst data: geo + csv
        self$getgeolyr()
        self$opentazdata()  
      },
      
      getscnyears = function(ascn = NULL) { # ascn may be: 1 scenario, null or a vector 
        if (is.null(ascn)) { ascn = self$scnlist }   # null for all scenarios
        
        if (length(ascn)==1) {                    # 1 scn
          result = self$data$scenarios[[ascn[[1]]]]$years
        } else {
          result = vector()
          for (i in 1:length(ascn)) {
            result = append(result, self$data$scenarios[[ascn[i]]]$years)
          }
          result = sort(unique(result))
        }
        return(result)
      },
      
      
      # - forecast layer -------------------------------------      
      
      getfrcstlyr = function() {
        return(self$data$tazlyr)
      },

      getgeolyr = function() {
        #if (is.null(self$geolyr)) {
          #url = paste(self$geodef$dir, self$geodef$file, sep="")
          #self$geolyr <- geojson_read(url, what = "sp")   # at this stage only support geojson
          self$geolyr <- geojson_sf(self$geodef$url)
        #}
      },
      
      frcst2lyr = function() {
        if (is.null(self$data$tazname)) { self$data$tazname = self$data$tazlyr }  # can define optional tazname

        frcstlyr <- list(
          lyr = self$data$tazlyr,     # self$getfrcstlyr(),        # the code of the layer
          name = self$data$tazname,  
          file = self$data$tazfile,
          #dir  = self$dir,
          url  = paste0(self$dir, self$data$tazfile),
          
          zvar = self$data$tazvar, 
          zname = "NA", 
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
        
        #temp = list(frcstlyr)
        #temp = temp %>% 
        #  map_df(as_tibble)
        #return(temp)
      },

            
      # - forecast data functions  --------------------------------
      
      opentazdata = function() {
        #if (is.null(self$tazdata)) {
          fl = paste(self$dir, "/", self$tazfile, sep="")        
          self$tazdata = fread(fl)  # read_csv(fl)            
        #}
      },

      getfrcstvars = function() {
        v = self$vars[2:length(self$vars)]
        return(v)
      },

      getfrcstbankvars = function() {
        v = unlist(self$bankvars, use.names = FALSE)
        return(v)  #(v[2:length(v)])
      },

      # - aggregation functions  -------------------------------------      

      setaglvl = function(aglvl, geodef) {
        self$aglvl = aglvl   
        if (self$aglvl=="taz") {
          self$geodef = self$frcst2lyr()  #self$data$tazfile        
          self$tazfile = self$data$file
          self$tazfilevar <- self$bankvars$taz
        } else {
          self$geodef = geodef
          self$tazfile = paste0("ag_", self$ky, "_", aglvl,".csv")
          self$tazfilevar <- geodef$zvar
        }
        self$loadfrcst()
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




