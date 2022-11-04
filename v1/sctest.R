# View(cfg)
# Sys.setlocale(locale="hebrew")
setwd("C:/Users/marsz/Documents/GitHub/ScenarioBank/v1")  # for debug

source("main.R")




basemap$mapview
basemap$mapview@map

source("scnlib.R")


currentscn$tazdata %>%
  summary()




currentscn <- setScn(1)
HideSc(1)

currentscn$opentazdata()

currentscn$tazdata

x = currentscn$tazdata[1]
view(currentscn$tazdata[2])

n = length(currentscn$scn$files)
x <- vector(mode="list", length=n)
#for (i in 1:n) {
i = 1

  fl = paste("Scn_lib/", currentscn$scn$dir, "/", currentscn$scn$files[[i]][[3]], sep="")        
  tmp <- fread(fl)  # read_csv(fl)            
  vars = currentscn$scn$files[[i]][[4]]
  tmp %>% 
    select(all_of(vars))
#}

rm(x)
view(tmp)


  
  
rm(x,y)
x = list(df1, df2, df3,df4)
y = x %>% reduce(left_join, by='team')



df1 = currentscn$tazdata[[1]]
view(df1)
colnames(df1)
df2 = df1 %>%
  left_join(currentscn$tazdata[[2]], by='taz') 
view(df2)
colnames(df2)
df3 = df2 %>%
  left_join(currentscn$tazdata[[3]], by='taz') 
view(df3)
colnames(df3)
df4 = df3 %>%
  left_join(currentscn$tazdata[[4]], by='taz') 
view(df4)
colnames(df4)


xx = currentscn$tazdata

yy = xx %>% reduce(left_join, by='taz')

df1
class(df1)
typeof(df1)



%>%  left_join(df3, by='Q1')



files = currentscn$scn$files
fl = paste("Scn_lib/", currentscn$scn$dir, "/", currentscn$scn$files[[1]][[3]], sep="")
data3 <- fread(fl)



library(readr)
data1 <- read_csv(fl) 

library(readr)
data1 <- read_csv(fl) 
library(data.table)
      
fl = "C:\\Users\\marsz\\OneDrive\\temp\\shiny\\scbank\\v1\\Scn_lib\\TA2016\\geo\\TAZ_v41.geojson"
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


