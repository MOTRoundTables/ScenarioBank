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
          
          selectizeInput('selectSrc', 'מקור תחזית', choices = cfg$scnsources,
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }')
            )
          ),
          
          selectizeInput('selectScn', 'תרחיש', choices = character(0), #cfg$scnchoices,
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }')
            )
          ),          

          radioButtons("zonetype", NULL,
                       choiceNames = list("גבולות מקור", "אזורי על"),
                       choiceValues = list(1, 2),
                       inline = TRUE 
          ),
                
          selectizeInput(
            'selectSz', 'אזורי על', choices = cfg$szchoices, 
            options = list(
              placeholder = 'בחר מתוך הרשימה ...',
              onInitialize = I('function() { this.setValue(""); }')
            )
          ),          
          
          #selectInput("selectSz", label = "אזורי על",   # h3("Super zones"), 
          #            choices = cfg$szchoices, 
          #            selected = 0),

          #htmlOutput("selectedscn"),        # display selection  #verbatimTextOutput("selected")
          
          #br(),
          #actionButton("testbutton", "test", style='width:100%'),

          #br(),br(),br(),br(),
          #actionButton("testbutton2", "test2", style='width:100%')
          
        ),

    # Show a plot of the generated distribution
    mainPanel(

          tabsetPanel(id = "tabs1", type = "tabs",
              tabPanel("map", br(), uiOutput("leaf") ),
              tabPanel("Summary", verbatimTextOutput("scnsummary") ),
              tabPanel("chart"),
              tabPanel("Table", tableOutput("scntable") )
          )
          
          # display application map

          # option 1
          # leafletOutput("appMap")  

          # option 2 -> esta
          # uiOutput("leaf")

          # plotOutput("distPlot")
        )
      
      ) # sidebarLayout
    ), # tabPanel צפייה

    tabPanel("השוואה",

          # Sidebar layout with input and output definitions ----
          sidebarLayout(
                 
                 # Sidebar panel for inputs ----
                 sidebarPanel(
                   # App title ----
                   titlePanel("Tabsets"),
                   
                   # Input: Select the random distribution type ----
                   radioButtons("dist", "Distribution type:",
                                c("Normal" = "norm",
                                  "Uniform" = "unif",
                                  "Log-normal" = "lnorm",
                                  "Exponential" = "exp")),
                   
                   # br() element to introduce extra vertical spacing ----
                   br(),
                   
                   # Input: Slider for the number of observations to generate ----
                   sliderInput("n",
                               "Number of observations:",
                               value = 500,
                               min = 1,
                               max = 1000)
                   
                 ),
                 
                 # Main panel for displaying outputs ----
                 mainPanel(
                   
                   # Output: Tabset w/ plot, summary, and table ----
                   tabsetPanel(type = "tabs",
                               tabPanel("Plot", plotOutput("plot")),
                               tabPanel("Summary", verbatimTextOutput("summary")),
                               tabPanel("Table", tableOutput("table"))
                   )
                   
                 )
          ) # sidebar Layout

     ) # tabPanel השוואה
               
  ) # navbarPage
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  observeEvent(input$selectSrc, {  
    #showmessage("hihi") 
    if (input$selectSrc!="") {
      if (currentsrc!=input$selectSrc) {
        if (currentscnnum>0) {
          HideCurrentSc()
          currentscn <<- NULL
          currentscnnum <<- 0
          refreshmap()
        }
        getsrcscn(input$selectSrc)
        updateSelectInput(session, "selectScn",
                          choices = cfg$scnchoices,
                          selected = character(0)
        )
        currentsrc <<- input$selectSrc
        cat(paste("new SRC: ", currentsrc, "\n")) # debug
      }
    }  
  })

  observeEvent(input$selectScn, { 
    if (input$selectScn>0) {
      if (currentscnnum!=input$selectScn) { # scenario changed
        if (currentscnnum>0) {  
          HideCurrentSc() 
        } # close current sc
        currentscnnum <<- input$selectScn
        currentscn <<- setScn(input$selectScn) # set scenario, session
        currentscn$opentazdata()
        cat(paste("set scn: ", currentscn$name, "\n"))
        updateSelectInput(session, "selectSz",
                         choices = cfg$szchoices0,
                         selected = character(0)
        )
        refreshmap()
        str0 <- paste("current scenario:", currentscn$name, sep = " ")
      }
    }
  })  
  
  refreshmap = function() {
    output$appMap <- renderLeaflet({ basemap$mapview@map })
    output$leaf = renderUI({ leafletOutput("appMap", width = "100%", height = cfg$basemap$height) })
    
    if (currentscnnum>0) {
      scnsummary <<- currentscn$tazdata %>%
          summary()
    } else { scnsummary <<- NULL }
    output$scnsummary <- renderPrint({ scnsummary })

    output$scntable <- renderTable({
      currentscn$tazdata
    })
  }
  
  refreshmap()
  
  # --------------------------------------

  #    output$selectedscn = renderPrint({
  #    #str0 = paste("set scenario:", currentscn$name, sep = " ")
  #    str1 = paste("scenario:", input$selectScn, sep = " ")
  #    str2 = paste("super zone:", input$selectSz, sep = " ")
  #    HTML(paste(str0, str1, str2, sep = '<br/>'))
  #  })

  # --------------------------------------
  
  #output$appMap <- renderLeaflet({ 
  #  basemap$mapview@map
  #})
  #
  ## prepare map
  #output$leaf = renderUI({
  #  leafletOutput("appMap", width = "100%", height = cfg$basemap$height) 
  #})
  
  # Generate a summary of the data ----
  #output$scnsummary <- renderPrint({
  #  scnsummary
  #})
  
  ## Generate an HTML table view of the data ----
  #output$scntable <- renderTable({
  #  currentscn$tazdata
  #})
  
    
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
    #if (input$selectScn=="") {
    #  showmessage("no scn")
    #}
    #else {
    #  showmessage(input$selectScn)
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
  
  # Reactive expression to generate the requested distribution ----
  # This is called whenever the inputs change. The output functions
  # defined below then use the value computed from this expression
  d <- reactive({
    dist <- switch(input$dist,
                   norm = rnorm,
                   unif = runif,
                   lnorm = rlnorm,
                   exp = rexp,
                   rnorm)
    
    dist(input$n)
  })
  
  # Generate a plot of the data ----
  # Also uses the inputs to build the plot label. Note that the
  # dependencies on the inputs and the data reactive expression are
  # both tracked, and all expressions are called in the sequence
  # implied by the dependency graph.
  output$plot <- renderPlot({
    dist <- input$dist
    n <- input$n
    
    hist(d(),
         main = paste("r", dist, "(", n, ")", sep = ""),
         col = "#75AADB", border = "white")
  })
  
  # Generate a summary of the data ----
  output$summary <- renderPrint({
    summary(d())
  })
  
  # Generate an HTML table view of the data ----
  output$table <- renderTable({
    d()
  })
  
  
  # -------------------------------------------
  
  #    output$distPlot <- renderPlot({
  #        # generate bins based on input$bins from ui.R
  #        x    <- faithful[, 2]
  #       bins <- seq(min(x), max(x), length.out = input$bins + 1)
  
  #       # draw the histogram with the specified number of bins
  #        hist(x, breaks = bins, col = 'darkgray', border = 'white',
  #            xlab = 'Waiting time to next eruption (in mins)',
  #           main = 'Histogram of waiting times')
  #   })
  
  
  
  
}  # end server

# Run the application 
shinyApp(ui = ui, server = server)

#      showmessage(input$selectScn) # debug


