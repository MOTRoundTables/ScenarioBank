source("main.R")
source("maplib.R")
source("scnlib.R")


currentscnnum <<- "11"
currentscn <<- setScn(currentscnnum) # set scenario, session
currentscn$opentazdata()





test1 = function() {
  showmessage("test 1")
}
  