# View(cfg)
# Sys.setlocale(locale="hebrew")
# setwd("C:/Users/marsz/Documents/GitHub/ScenarioBank/dvlp/v0.3")  # for debug

# for debug

source("main.R")
#source("dvlp/v0.3/main.R")

frcstky = "jeru23v09"
frcstnum <- cfg$frcstnums[[frcstky]]  # getfrcstnum(currentfrcstky)
afrcst <<- cfg$forecasts[[frcstnum]]   #  setFrcst(aFrcst) # set scenario  --> main 
afrcst$name
afrcst$loadfrcst()

userreq = list()
userreq$frcst = afrcst
userreq$scn = c("BAU")    # "BASE", "BAU", "IPLAN", "JTMT"
userreq$yr = c(2025)      # 2020, 2025, 2030, 2035, 2040, 2045, 2050
userreq$var = "pop"       # "pop", "emp_tot":
userreq$mode = 1          # change to 3 if multiple

x = createMap(userreq)
x
# end



# ============================================


currentfrcst$data$tazvar
view(currentfrcst$geolyr)

currentfrcst$data$dict$taz
view(currentfrcst$tazdata)
currentfrcst$tazdata %>%
  summary()

# for debug
aFrcst = currentfrcst
aScn = currentscn
aYr = 2020
aVar = 'population'

createSimpleMap(aFrcst, aScn = currentscn, 
                aYr=aYr, aVar = aVar) 
basemap$mapview



cfg$forecastslist
sc = "BS_v09"

# create scenario
aFrcst <<- setFrcst(sc) 
basemap$mapview
aFrcst$opentazdata()
# view(aFrcst$tazdata)
x_join <- aFrcst$Frcst$dict$taz
y_join <- aFrcst$frcst2lyr()$zvar
# 1 generate a summary of population by scenario
scens = aFrcst$Frcst$scnlist   # the available scenarios
pop_col_name <- aFrcst$Frcst$dict$population
aFrcst$Frcst$scnnames
afrcst = 1 

years = aFrcst$Frcst$scenarios[[scens[afrcst]]]$years  # the available years for 1st scenario

# 2 create map op population for one scenario
yearvar = years[4]


# 3 mapview population of scenario
createSimpleMap(aFrcst,scens[1],yearvar,pop_col_name)
# 4 chart of pop
createChronologicalGraph(aFrcst,pop_col_name)
# 5 table of pop
createSummaryTable(aFrcst,pop_col_name)
# - - - - - - - - - - - - - - - - - -  


df <- merge(currentfrcst$geolyr, currentfrcst$tazdata, by.x = currentfrcst$Frcst$tazvar, by.y = "taz", all.x=TRUE)
view(df)


#df <- left_join(currentfrcst$geolyr, currentfrcst$tazdata, by = c( {currentfrcst$geolyr[[x]]} = "taz" ) ) # currentfrcst$Frcst$tazvar
#df <- left_join(currentfrcst$geolyr, currentfrcst$tazdata, by = c( 'TAZV41' = 'taz' ) )
#df3 <- left_join(currentfrcst$geolyr, currentfrcst$tazdata, join_by = c(id == x, taz == 'taz'))






# -------------------------------------------


alyr = currentfrcst$getfrcstlyr()
i = basemap$lyrnum(alyr)
lyrdata = basemap$lyrsdata[[i]]


HideSc(1)

x = currentfrcst$tazdata[1]
view(currentfrcst$tazdata[2])


df1 = currentfrcst$tazdata[[1]]
view(df1)
colnames(df1)
df2 = df1 %>%
  left_join(currentfrcst$tazdata[[2]], by='taz') 
view(df2)
colnames(df2)
df3 = df2 %>%
  left_join(currentfrcst$tazdata[[3]], by='taz') 
view(df3)
colnames(df3)
df4 = df3 %>%
  left_join(currentfrcst$tazdata[[4]], by='taz') 
view(df4)
colnames(df4)


xx = currentfrcst$tazdata

yy = xx %>% reduce(left_join, by='taz')

df1
class(df1)
typeof(df1)



#%>%  left_join(df3, by='Q1')



files = currentfrcst$Frcst$files
fl = paste("Frcst_lib/", currentfrcst$Frcst$dir, "/", currentfrcst$Frcst$files[[1]][[3]], sep="")
data3 <- fread(fl)



library(readr)
data1 <- read_csv(fl) 

library(readr)
data1 <- read_csv(fl) 
library(data.table)
      
fl = "C:\\Users\\marsz\\OneDrive\\temp\\shiny\\scbank\\v1\\Frcst_lib\\TA2016\\geo\\TAZ_v41.geojson"
l1 <- geojson_read(fl, what = "sp")   # at this stage only support geojson
class(l1)
b = bbox(l1)
b


b = c(34.621252,31.778535,35.05149,32.377743)

view(basemap$lyrs)
glimpse(basemap)

glimpse(basemap$lyrsdata[[1]])
x = basemap$lyrsdata[[1]]
class(x)
x@bbox
b = x@bbox

bbox(x)
bbox_get(x)
basemap$lyrsdata[i]@bbox

#COMO MIERDA RETIVEAR EL HIJUEOUTA BOUNDS DE LA PUTA NMMIERDA QUE LOAS PARIO

# OLD -------------------------------------


#setwd("C:\\Users\\marsz\\OneDrive\\temp\\shiny\\scbank\\v1\\")  # for debug
#source("maplib.R")


button_color_css <- "
#DivCompClear, #FinderClear, #EnterTimes{
/* Change the background color of the update button
to blue. */
background: DodgerBlue;

/* Change the text size to 15 pixels. */
font-size: 15px;
}"


# --------------------------------

n = length(currentfrcst$Frcst$files)
x <- vector(mode="list", length=n)
#for (i in 1:n) {
i = 1

fl = paste("Frcst_lib/", currentfrcst$Frcst$dir, "/", currentfrcst$Frcst$files[[i]][[3]], sep="")        
tmp <- fread(fl)  # read_csv(fl)            
vars = currentfrcst$Frcst$files[[i]][[4]]
tmp %>% 
  select(all_of(vars))
#}

rm(x)
view(tmp)

rm(x,y)
x = list(df1, df2, df3,df4)
y = x %>% reduce(left_join, by='team')



f_add<- function(x,y){ x + y }
f_subtract<- function(x,y){ x - y }
f_multi<- function(x,y){ x * y }

operation<- function(FUN, x, y){ FUN(x , y)}

operation(f_add, 9,2)
#> [1] 11
operation(f_subtract, 17,5)
#> [1] 12
operation(f_multi,6,8)
#> [1] 48
#> 

