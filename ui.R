

library(shinyalert)
library(VennDiagram)
library(tools)
library(shinythemes)
library(gplots)
library(shiny)
library(shinyjs)
library(openxlsx)
library(V8)


jsResetCode <- "shinyjs.reset = function() {history.go(0)}"
jscloseW    <- "shinyjs.closeWindow = function() { window.close(); }"


ui = fluidPage(
  titlePanel("DGINN additional GUI"),
  useShinyjs(),                                           # Include shinyjs in the UI
  extendShinyjs(text = jsResetCode, functions = c("reset")), 
  extendShinyjs(text = jscloseW , functions = c("closeWindow")),
  
  
  # conditionalPanel(
  #   condition="!($('html').hasClass('shiny-busy'))",
  #   img(src="images/busy.gif")
  # ),
  
  theme = shinytheme("darkly"),
  
  
  titlePanel(h1(
    a(href = "https://academic.oup.com/nar/article/48/18/e103/5907962?login=true",
      "Visualization of DGINN results", style = "color:skyblue; font-size:130% "), align = "center"
  )) ,
  #titlePanel(h1("Insight into genes involved in evolutionary 'arms-races'",style = "color:skyblue; font-size:300% ", align = "center")) ,
  
  
  
  
  
  
  #_________________________________fluidRow de l'espace de t?l?versement du document ? traiter____________________________________________________ 
  fluidRow(
    sidebarLayout(
      sidebarPanel(position = "left", width = 3 ,
                   h6(HTML("Upload your .txt/.csv/.tsv Tab-separated values Or Excel .xlsx sheet (<i> must be the first in case of multiple sheets workbook </i>)")),
                   tags$div(title = "The tab-separated or .xlsx file must contain the 'Gene', 'GeneSize', 'Omega', 'Method', 'PosSel', 'NbSites' & 'PSS' columns. 
                 In 'Method' column, BUSTED and MEME methods are mandatory." ,
                            fileInput("boutonUpload" , "Must conform with DGINN's formatting",placeholder = "No DGINN's file selected")
                   ),#tags$div(
                   
                   tags$div(title = "The coverage table must be in '.tab/.txt/.csv/.tsv' format" ,
                            fileInput("covrageUpload" , "Optional - Uploald here Covrage file", placeholder = "300 MB maximum")
                                      
                   )#tags$div(
                   ,
                   tags$div(title="Choose how many genes should appear in each one page of the pdf downloadable file",
                            sliderInput("nbGene", "Genes by pdf page", 15 , min = 1, max = 50 , width = 160)
                   )
                   ,
                   tags$div(title = "Once desired data uploaded, press 'Submit' button to launch calculations" ,
                            actionButton("soumettre" , "Submit" , style="color: indianred ;  font-size:150%" , class = "btn-warning")

                   )
                   ,
                   hr()
                   ,
                   tags$div(title="Clicking this button will erase current dataset. Reset GUI before uploading a new dataset",
                            actionButton('resetData', 'Reset GUI', icon("refresh"),
                                         style="color:snow; background-color: #337ab7; border-color: dodgerblue")
                   )
                  
      ), # sidebarPanel(

      mainPanel ()
    )#sidebarLayout(
  ), #  fluidRow( 
  

  
 
  
  #________________________fluidRow tableCsv & heat_____________________________________________________________
  fluidRow(   
    mainPanel(
      column(
        width = 12 , div(style = "height:100px;"),
        align = "right" ,
        offset = 3 ,
        
        #Affichage de texte.
        textOutput("fpath"),
        
        #Affichage de tables.
        tableOutput("tableCsv"),
        
        #Affichage d'un plot.
        plotOutput("heat"     , width = "120%" , height = "1200px")
        #,
        # plotOutput("barPlots" ,height = "1000px") 
        # ,
        # 
        # plotOutput("sitePos" ,height = "1400px" )
        
      )#column(width = 8
    )#mainPanel)
  ),# fluidRow(
  
  #________________________fin fluidRow tableCsv & heat_____________________________________________________________
  
  
  #________________________fluidRow barplots_____________________________________________________________
  fluidRow(
    
    mainPanel(
      column(
        width = 12 , div(style = "height:100px;"),
        align = "right" ,
        offset = 3 ,
        plotOutput("barPlots", width = "120%" ,height = "1200px" )
        
      )#column
    )#mainPanel)
  ),# fluidRow(
  #________________________fin fluidRow barplots_____________________________________________________________
  
  #________________________fluidRow sitePos_____________________________________________________________
  
  fluidRow(
    mainPanel(
      column(
        width = 12 , div(style = "height:100px;"), #height:100px c'est la distance entre les graphs.
        align = "right" ,
        offset = 3 ,
        plotOutput("sitePos" , width = "120%" , height = "6000" )
      )#column
    )#mainPanel)
  ),#fluidRow(
  #________________________fin fluidRow sitePos_____________________________________________________________
  
  #________________________fluidRow vide, jsute pour ne pas arr?ter la page pile ? la fin du dernier graphique_____________________________________________________________
  
  fluidRow(
    mainPanel(
      column(
        width = 12 , div(style = "height:100px;"),
        align = "right" ,
        offset = 3
        #,
        # plotOutput("sitePos" ,height = "1800px" )
      )#column
    )#mainPanel)
  ),#fluidRow(
  #________________________fin fluidRow vide_____________________________________________________________
  
  
  absolutePanel(
    fluidRow(
      column(
        width = 3,
        align = "left",
        offset = 1,
     
        #-- Display 'counting ...' 
        conditionalPanel(
          condition="$('html').hasClass('shiny-busy')", 
          tags$div(style="color:indianred ; background-color:snow ; font-family:courier; font-size:120%; width:200% ;padding:10px", paste("Please wait! Calculation in progress ..."))
        ),
        
        #hr(),
        actionButton('showHideData'   , 'Show/Hide data' ),
        
        hr(),
        actionButton('showHideVenn'   , 'Show/Hide Figures'),
       
        hr(),
        tags$div(title="Download the figures in a pdf format",
        downloadButton('download_PDF', 'Download Figures' ,  style="color:pink; background-color: seagreen; border-color: snow ;font-size:80%")
       
        ) 
        ,
        hr(), 
        tags$div(title="Close application",
                 actionButton('quit', 'Quit', icon("off" , lib = "glyphicon" ),
                              style="color:snow; background-color: orange; border-color: white ;padding:4px; font-size:80%")
        )
      )
    ) #fluidRow(
    ,
    
    top = 720,
    left = 0,
    right = NULL,
    bottom = NULL,
    width = 600,
    height = 10,
    draggable = T,
    fixed = F,
    cursor = c("auto", "move", "default", "inherit")
    ,
  
    br(),br(),br(),br(),br(),
    br(),
    h6(
      "By the",
      a(href = "http://ciri.inserm.fr/service-bioinformatique-et-biostatistique-bibs/",
        "CIRI-BIBS Service", style = "background-color:purple ; color:white; font-size:80%;"),
      style = "margin-left:10%;"
    )#h6
  )# absolutePanel
  
)# fluidPage