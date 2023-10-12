# scenario bank application

library(shiny)
library(shinythemes)  # https://rstudio.github.io/shinythemes/
library(shinyWidgets) # https://dreamrs.github.io/shinyWidgets/index.html

source("main.R")


# Define UI for application that draws a histogram
ui <- fluidPage(

  titlePanel("בנק תחזיות"),
  
  navbarPage(" ", theme = shinytheme("united"),  # lumen
  
    tabPanel("צפייה", fluid = TRUE, #icon = icon("globe-americas"), #tags$style(button_color_css),
             
      sidebarLayout(position = "right",
                    
        sidebarPanel(

          titlePanel("בנק"),
          
          selectizeInput('selectSrc', 'מקור תחזית', choices = cfg$frcstsources,
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }') ) ),
          
          selectizeInput('selectFrcst', 'תחזית', choices = character(0), 
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }') ) ),
          
          selectInput('selectScn', 'תרחיש', "", multiple=FALSE, selectize=FALSE),

          selectInput('selectYr', 'שנה', "", multiple=FALSE, selectize=FALSE),

          hr(), 
          
          selectInput('selectVar', 'משתנה', "", multiple=FALSE, selectize=FALSE),

          selectInput('selectAnalysis', 'עיבוד', "", multiple=FALSE, selectize=FALSE)

          # --------------------------------------          

          #updateSelectInput(session, "selectSz",
          #                 choices = cfg$szchoices0,
          #                 selected = character(0)
          #)
          
          #radioButtons("zonetype", NULL,
          #             choiceNames = list("גבולות מקור", "אזורי על"),
          #             choiceValues = list(1, 2),
          #             inline = TRUE ),

          #selectizeInput(
          #  'selectSz', 'אזורי על', choices = cfg$szchoices, 
          #  options = list(
          #    placeholder = 'בחר מתוך הרשימה ...',
          #    onInitialize = I('function() { this.setValue(""); }')
          #  )
          #)

        ),

    # Show a plot of the generated distribution
    mainPanel(

          tabsetPanel(id = "tabs1", type = "tabs",
              tabPanel("map", br(), uiOutput("leaf") ),
              tabPanel("Summary", verbatimTextOutput("Frcstsummary") ),
              tabPanel("chart"),
              tabPanel("Table", tableOutput("Frcsttable") )
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
  
  resetInputs = function () {
    updateSelectInput(session, "selectYr", choices = "", selected = character(0) )
    updateSelectInput(session, "selectVar", choices = "", selected = character(0) )
    updateSelectInput(session, "selectAnalysis", choices = "", selected = character(0) )
  }
  
  observeEvent(input$selectSrc, {  
    if (setnewSource(input$selectSrc)) {
      updateSelectInput(session, "selectFrcst",
                        choices = cfg$frcstchoices,
                        selected = character(0) )  
      refreshmap()
      resetInputs()
    }
  })

  observeEvent(input$selectFrcst, { 
    if (setnewFrcst(input$selectFrcst)) {
      updateSelectInput(session, "selectScn",
                        choices = currentfrcst$scnchoices,
                        selected = character(0) )
      refreshmap()
      resetInputs()
    }
  })
  
  observeEvent(input$selectScn, {
    if (input$selectScn!="") {
      if (setnewScn(input$selectScn)) {
        updateSelectInput(session, "selectYr",
                        choices = currentfrcst$Frcst$scenarios[[currentscn]]$years,
                        selected = character(0) )
      }
    }  
  })

  # -------------------------------------
  
  refreshmap = function() {
    output$appMap <- renderLeaflet({ basemap$mapview@map })
    output$leaf = renderUI({ leafletOutput("appMap", width = "100%", height = cfg$basemap$height) })
    
    if (currentfrcstky!="") {
      Frcstsummary <<- currentfrcst$tazdata %>%
          summary()
      output$Frcstsummary <- renderPrint({ Frcstsummary })
      
      #output$Frcsttable <- renderTable({ currentfrcst$tazdata })
      
    } else { Frcstsummary <<- NULL }
  }
  
  refreshmap()

}  # end server

# Run the application 
shinyApp(ui = ui, server = server)


# = end ==============================================

#htmlOutput("selectedFrcst"),        # display selection  
#br(),
#actionButton("testbutton", "test", style='width:100%'),
#br(),br(),br(),br(),
#actionButton("testbutton2", "test2", style='width:100%')


# servet tests

# --------------------------------------

#    output$selectedFrcst = renderPrint({
#    #str0 = paste("set scenario:", currentfrcst$name, sep = " ")
#    str1 = paste("scenario:", input$selectFrcst, sep = " ")
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
#if (input$selectSrc=="") {
#  showmessage("no scr")
#}
#else {
#  showmessage(input$selectSrc)
#} 
#if (input$selectFrcst=="") {
#  showmessage("no Frcst")
#}
#else {
#  showmessage(input$selectFrcst)
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
