# scenario bank application

library(shiny)
library(shinythemes)  # https://rstudio.github.io/shinythemes/
library(shinyWidgets) # https://dreamrs.github.io/shinyWidgets/index.html
library(waiter) # https://waiter.john-coene.com/#/  #https://shiny.john-coene.com/waiter/

source("main.R")


# Define UI for application that draws a histogram
ui <- fluidPage(
  waiter::use_waiter(),
  titlePanel("בנק תחזיות"),
  
  navbarPage(" ", theme = shinytheme("united"),  # "lumen"  "united"  "cerulean"
  
    tabPanel("צפייה", fluid = TRUE, #icon = icon("globe-americas"), #tags$style(button_color_css),
             
      sidebarLayout(position = "right",
                    
        sidebarPanel( width = 4,

          #titlePanel("בנק"),
          
          selectizeInput('selectsrc', 'מקור תחזית', choices = cfg$frcstsources,
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }') ) ),
          
          selectizeInput('selectfrcst', 'תחזית', choices = character(0), 
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }') ) ),
          
          hr(), 
          selectInput('selectscn', 'תרחיש', "", multiple=FALSE, selectize=FALSE),

          #selectInput('selectyr', 'שנה', "", multiple=FALSE, selectize=FALSE),
          prettyCheckboxGroup(inputId = "selectyr", label = "שנה", 
                              status = "danger", fill = FALSE),

          hr(), 
          selectInput('selectvar', 'משתנה', "", multiple=FALSE, selectize=FALSE),

          selectInput('selectanalysis', 'עיבוד', choices = analisystype, 
                    selected = 1, multiple=FALSE, selectize=FALSE),

          hr(),
          actionButton("doanalisys", "הפעל", style='width:100%')

          # --------------------------------------          

          #updateSelectInput(session, "selectSz",
          #                 choices = cfg$szchoices0,
          #                 selected = character(0) )
          
          #radioButtons("zonetype", NULL,
          #             choiceNames = list("גבולות מקור", "אזורי על"),
          #             choiceValues = list(1, 2),
          #             inline = TRUE ),

          #selectizeInput(
          #  'selectSz', 'אזורי על', choices = cfg$szchoices, 
          #  options = list(
          #    placeholder = 'בחר מתוך הרשימה ...',
          #    onInitialize = I('function() { this.setValue(""); }')
          #  ) )

        ),

    # Show a plot of the generated distribution
    mainPanel(

          tabsetPanel(id = "tabs1", type = "tabs",
              tabPanel("map", br(), 
                       uiOutput("leaf")
              ),
              tabPanel("Summary", 
                       uiOutput("Frcstsummary") #verbatimTextOutput("Frcstsummary") 
              ),
              tabPanel("chart",
                       uiOutput("FrcstChart") # plotOutput("FrcstChart")
              ),
              tabPanel("Table", 
                       dataTableOutput("Frcsttable") 
              )
          )
          
        )
      
      ) # sidebarLayout
    ), # tabPanel צפייה

    # ------------------------------------------------------
    
    tabPanel("השוואה",

     ) # tabPanel השוואה
               
  ) # navbarPage
)

# --------------------------------------------------

server <- function(input, output, session) {

  # --------- tabPanel "צפייה"

  observeEvent(input$selectsrc, {  
    if (setnewsource(input$selectsrc)) {
      updateSelectInput(session, "selectfrcst",
                        choices = cfg$frcstchoices,
                        selected = character(0) )  
      refreshmap()
      updateSelectInput(session, "selectscn", choices = "", selected = character(0) )
      updatePrettyCheckboxGroup(session, "selectyr", choices = NULL, selected = character(0) )
      updateSelectInput(session, "selectvar", choices = "", selected = character(0) )
    }
  })

  observeEvent(input$selectfrcst, { 
    waiter <- waiter::Waiter$new( html = spin_3(), color = transparent(.5)) 
    waiter$show()
    on.exit(waiter$hide())    
    if (setnewfrcst(input$selectfrcst)) {
      updateSelectInput(session, "selectscn",
                        choices = currentfrcst$scnchoices,
                        selected = character(0) )
      updateSelectInput(session, "selectvar",
                        choices = currentfrcst$varchoices,  # currentfrcst$getfrcstvars() 
                        selected = character(0) )
      updatePrettyCheckboxGroup(session, "selectyr", choices = NULL, selected = character(0) )
      refreshmap()
    }
  })
  
  observeEvent(input$selectscn, {
    if (input$selectscn!="") {
      if (setnewscn(input$selectscn)) {
        updatePrettyCheckboxGroup(session, "selectyr",  # updateSelectInput
                        choices = as.list(currentfrcst$getscnyears(currentscn)),
                        inline = TRUE, selected = character(0) )
      }
    }
  })

  observeEvent(input$tabs1, {
    cat(paste0(input$tabs1,"\n"))
    doanalisys()
  })
  
  observeEvent(input$doanalisys, {
    #showmessage("pressed button")
    doanalisys()
  })  

  doanalisys = function() {
    req(currentfrcst, currentscn, input$selectyr, input$selectvar)
    
    userreq = list()
    userreq$frcst = currentfrcst
    userreq$scn   = currentscn
    if (length(input$selectyr)==1) {
      userreq$yr = input$selectyr[1]
      userreq$yrmode = 1
    } else {
      userreq$yr = input$selectyr
      userreq$yrmode = 2
    }
    userreq$var   = input$selectvar

    if (input$tabs1=='map') {
      createSimpleMap(userreq)  
      refreshmap()
    } else if (input$tabs1=='Summary') {
      frcstsummary = createSummaryTable(userreq)  
      #output$Frcstsummary <- renderPrint({ frcstsummary })
      output$Frcstsummary <- renderUI({ frcstsummary })
      
    } else if (input$tabs1=='chart') {
      frcstchart = createChronologicalGraph(userreq)  
      #output$FrcstChart <- renderPlot({ frcstchart })
      output$FrcstChart <- renderUI({ frcstchart })
      
    } else if (input$tabs1=='Table') {
      atable = subtable(userreq)
      output$Frcsttable <-  renderDataTable(atable)
      #output$Frcsttable <-  renderDataTable(currentfrcst$tazdata)
    }

  }

  # -------------------------------------
  
  refreshmap = function() {
    output$appMap <- renderLeaflet({ basemap$mapview@map })
    output$leaf = renderUI({ leafletOutput("appMap", width = "100%", height = cfg$basemap$height) })
  }
  
  refreshmap()

}  # end server

# Run the application 
shinyApp(ui = ui, server = server)


# = end ==============================================

# servet tests

#htmlOutput("selectedFrcst"),        # display selection  
#br()

#    output$selectedFrcst = renderPrint({
#    #str0 = paste("set scenario:", currentfrcst$name, sep = " ")
#    str1 = paste("scenario:", input$selectfrcst, sep = " ")
#    str2 = paste("super zone:", input$selectSz, sep = " ")
#    HTML(paste(str0, str1, str2, sep = '<br/>'))
#  })

# --------------------------------------

#output$appMap <- renderLeaflet({ 
#  basemap$mapview@map })

## prepare map
#output$leaf = renderUI({
#  leafletOutput("appMap", width = "100%", height = cfg$basemap$height) })

# Generate a summary of the data ----
#output$Frcstsummary <- renderPrint({
#  Frcstsummary })

## Generate an HTML table view of the data ----
#output$Frcsttable <- renderTable({
#  currentfrcst$tazdata })


# ---------------------------------------------------------

# test button 
#observeEvent(input$testbutton, {
#  test1()
#if (input$selectsrc=="") {
#  showmessage("no scr")
#}
#else {
#  showmessage(input$selectsrc)
#} 
#if (input$selectfrcst=="") {
#  showmessage("no Frcst")
#}
#else {
#  showmessage(input$selectfrcst)
#} 

#showmessage("testbutton")
#test2(basemap$name, session)    
#test3(basemap$name, session)    
#  sss <<- leafletProxy("myMap", session) %>%
#   addMarkers(lng=35.0, lat=31.4, popup="<b>Hello</b>")      

#})  

#observeEvent(input$testbutton2, {
#  showmessage("testbutton2")
#  amap = leafletProxy(basemap$name, session)
#  #addlyrtoLLmap(amap, "metrorings2008")
#})  
