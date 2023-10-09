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
          
          selectizeInput('selectSrc', 'מקור תחזית', choices = cfg$Frcstsources,
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }')
            )
          ),
          
          selectizeInput('selectFrcst', 'תחזית', choices = character(0), #cfg$Frcstchoices,
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }')
            )
          ),
          
          selectInput('selectScn', 'תרחיש', state.name, multiple=FALSE, selectize=FALSE)          

          #radioButtons("zonetype", NULL,
          #             choiceNames = list("גבולות מקור", "אזורי על"),
          #             choiceValues = list(1, 2),
          #             inline = TRUE 
          #),

          #selectizeInput(
          #  'selectSz', 'אזורי על', choices = cfg$szchoices, 
          #  options = list(
          #    placeholder = 'בחר מתוך הרשימה ...',
          #    onInitialize = I('function() { this.setValue(""); }')
          #  )
          #),          
          
          #htmlOutput("selectedFrcst"),        # display selection  
          #br(),
          #actionButton("testbutton", "test", style='width:100%'),
          #br(),br(),br(),br(),
          #actionButton("testbutton2", "test2", style='width:100%')
          
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

  observeEvent(input$selectSrc, {  
    #showmessage("test") 
    if (input$selectSrc!="") {
      if (currentsrc!=input$selectSrc) {
        if (currentFrcstky!="") {  ## clear Frcst and map
          #HideCurrentSc()
          currentFrcstky <<- ""
          currentFrcst <<- NULL
          basemap$createmap(cfg$basemap)  # reset to initial map 
          basemap$resetmapview(cfg$basemap)
          refreshmap()
        }
        getsrcFrcst(input$selectSrc)  # --> main
        updateSelectInput(session, "selectFrcst",
                          choices = cfg$Frcstchoices,
                          selected = character(0)
        )
        currentsrc <<- input$selectSrc
        cat(paste("new SRC: ", currentsrc, "\n")) # debug
      }
    }  
  })

  observeEvent(input$selectFrcst, { 
    if (input$selectFrcst!="") {
      if (currentFrcstky!=input$selectFrcst) { # scenario changed
        #if (currentFrcstky>0) {  
        #  HideCurrentSc() 
        #} # close current sc lyr
        currentFrcstky <<- input$selectFrcst
        currentFrcst <<- setFrcst(input$selectFrcst) # set scenario  --> main
        currentFrcst$opentazdata()# --> Frcstlib
        cat(paste("set Frcst: ", currentFrcst$name, "\n"))
        #updateSelectInput(session, "selectSz",
        #                 choices = cfg$szchoices0,
        #                 selected = character(0)
        #)
        refreshmap()
        #str0 <- paste("current scenario:", currentFrcst$name, sep = " ")
      }
    }
  })
  
  refreshmap = function() {
    output$appMap <- renderLeaflet({ basemap$mapview@map })
    output$leaf = renderUI({ leafletOutput("appMap", width = "100%", height = cfg$basemap$height) })
    
    if (currentFrcstky!="") {
      Frcstsummary <<- currentFrcst$tazdata %>%
          summary()
      output$Frcstsummary <- renderPrint({ Frcstsummary })
      
      #output$Frcsttable <- renderTable({ currentFrcst$tazdata })
      
    } else { Frcstsummary <<- NULL }
  }
  
  refreshmap()
  
  # --------------------------------------

  #    output$selectedFrcst = renderPrint({
  #    #str0 = paste("set scenario:", currentFrcst$name, sep = " ")
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
  #  currentFrcst$tazdata })

    
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
  

# ===============================================================
  

}  # end server

# Run the application 
shinyApp(ui = ui, server = server)


