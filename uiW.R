library("shiny")
library("ggplot2")
library("Cairo")

shinyUI(fluidPage(
  
  
  headerPanel("Modèle Word2Vec"),
  br(),
  br(),
  br(),
  titlePanel("Classification ascendante hiérarchique"),
  
  sidebarPanel(
    
    textInput(inputId= "title",
              label= "Choisir un titre au graphique:",
              value= "Classification hiérarchique"),
    
    selectInput("method", "Choisir une méthode de classification:", 
                choices=c("complete", "ward.D", "single"))),
  
  sidebarPanel(
    checkboxGroupInput('nv', 'Mots rajoutés:', inline = TRUE, names(read.csv("./csv/dfa.csv", sep = ",")), selected = names(read.csv("./csv/dfa.csv", sep = ",")))),
  
  plotOutput("Plot"),
  
  #plotOutput("Plot", dblclick = "plot_dblclick",
  #         brush = brushOpts(
  #        id = "plot_brush",
  #       resetOnNew = TRUE
  #      )),
  
  
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  br(),
  
  
  h2("Choix des mots:"),
  
  sidebarPanel(
    textInput('rajout', 'Rajouter un mot:', value = "austin"),
    actionButton("goButton", "Go!"),
    br(),
    br(),
    "La récupération d'un nouveau mot peut prendre quelques instants.",
    "Toute action nécessite le lancement du boutton Go!"
  ),
  
  
  
  
  sidebarPanel(
    
    
    checkboxGroupInput('choix', 'Théâtre:', inline = TRUE,
                       names(read.csv("mot.theatre.csv", sep = ",")), selected = names(read.csv("mot.theatre.csv", sep = ","))),
    
    checkboxGroupInput('choix2', 'Jardin:', inline = TRUE,
                       names(read.csv("mot.jardin.csv", sep = ",")), selected = names(read.csv("mot.jardin.csv", sep = ","))),
    
    checkboxGroupInput('choix3', 'Cinéma:', inline = TRUE,
                       names(read.csv("mot.film.csv", sep = ",")), selected = names(read.csv("mot.film.csv", sep = ","))),
    
    checkboxGroupInput('choix4', 'Musique:', inline = TRUE,
                       names(read.csv("mot.musique.csv", sep = ",")), selected = names(read.csv("mot.musique.csv", sep = ",")))),
  
  sidebarPanel(
    
    checkboxGroupInput('choix5', 'Villes où il fait bon vivre:', inline = TRUE,
                       names(read.csv("villes.bonvivre.csv", sep = ",")), selected = NULL),
    
    checkboxGroupInput('choix6', 'Villes célèbres pour leur festival de musique:', inline = TRUE,
                       names(read.csv("villes.musique.csv", sep = ",")), selected = NULL),
    
    checkboxGroupInput('choix7', 'Villes célèbres pour leur festival de théâtre:', inline = TRUE,
                       names(read.csv("villes.theatre.csv", sep = ",")), selected = NULL),
    
    checkboxGroupInput('choix8', 'Villes célèbres pour leur festival de cinéma:', inline = TRUE,
                       names(read.csv("villes.cinema.csv", sep = ",")), selected = NULL)),
  
  titlePanel("Analyse en composantes principales"),
  
  #plotOutput("Plot2"),
  
  
  plotOutput("Plot2",dblclick = "plot2_dblclick",brush = brushOpts(id = "plot2_brush",resetOnNew = TRUE)),
  
  plotOutput("Plot3",dblclick = "plot3_dblclick",brush = brushOpts(id = "plot3_brush",resetOnNew = TRUE))
  
  
))

