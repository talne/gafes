library(shiny)
#library(rCharts)
library("DBI")
library("RMySQL")
library("sparcl")
library("ggplot2")
library("Cairo")
library("ggrepel")

shinyServer(function(input, output, session){
  
  w2v <- function(w){
    cat(as.character(w) ,file="./Gafes/wordlist/liste_rajout.txt")
    system("./Gafes/extractVectors.py -i ./Gafes/clef_microblogs_tbl_full.vector.bin -o ./Gafes/wordextract/extract_rajout.csv -w ./Gafes/wordlist/liste_rajout.txt")
    tab <- read.table("./Gafes/wordextract/extract_rajout.csv", sep = ";",header = F, row.names = 1)
    tab<-tab[,-200]
    tab <- t(tab)
    tab<-as.matrix(tab)
  }
  
  
  cosineDist <- function(x){ as.dist(1 - x%*%t(x)/(sqrt(rowSums(x^2) %*% t(rowSums(x^2)))), upper = T, diag = TRUE) }
  
  
  #system("./extractVectors.py -i clef_microblogs_tbl_full.vector.bin -o wordextract/extract.csv -w wordlist/listeinterface.txt")
  #system("awk '{n=split($0,a,";");for(i=1;i<=n;i++)T[i]=T[i]"\t"a[i]}END{for(i=1;i<=n;i++)print i T[i]}' extract.csv > extract2.csv")
  
  
  y<-read.csv("./Gafes/wordextract/extract2.csv", sep = ",",header = T)
  y<-y[,-1]
  
  
  y <-as.matrix(y)
  
  
  output$Plot <- renderPlot({
    input$goButton
    
    
    last<-read.csv("./csv/dfa.csv", sep = ",")
    
    ranges <- reactiveValues(x = NULL, y = NULL)  
    
    
    k="NULL"
    newdfa= reactive({
      k=as.character(input$rajout)
      dfa=last[,1]
      if(k %in% names(last)){
        dfa=last[,colnames(last)==k]
      }
      else{
        dfa = w2v(w=k)
      }
      dim(dfa)=c(nrow(last),1)
      colnames(dfa)=k
      dfa
    })
    
    
    newdfa= reactive({
      dfa = w2v(w=as.character(input$rajout))
    })
    
    
    X2= reactive({
      X=as.matrix(t(cbind(iso,y[,c(input$choix,input$choix2,input$choix3,input$choix4,input$choix5,input$choix6,input$choix7,input$choix8)],last[,input$nv])))
    })
    
    
    
    
    isolate({
      
      
      
      updateCheckboxGroupInput(session, "nv",'Mots rajoutés:',inline = TRUE, names(last), selected = input$nv)
      
      
      iso<-{ newdfa() }
      colnames(iso)=as.character(input$rajout)
      
      mat <- cbind(iso,y[,c(input$choix,input$choix2,input$choix3,input$choix4,input$choix5,input$choix6,input$choix7,input$choix8)],last[,input$nv])
      cos<-cosineDist(t(mat))
      cos<-as.matrix(cos)
      hc<-hclust(as.dist(cos),method = input$method)
      
      
      ColorDendrogram(hc, y=c( rep("#FFFFFF",length(input$rajout)),rep("green",length(input$choix)),
                               rep("#FFFF00",length(input$choix2)),rep("#003300",length(input$choix3)),
                               rep("#660066",length(input$choix4)),rep("#FF0000",length(input$choix5)),
                               rep("#000066",length(input$choix6)),rep("#00CCFF",length(input$choix7)),
                               rep("#FF6699",length(input$choix8)),rep("black",length(input$nv))),
                      main = input$title, branchlength = 0.2, labels = colnames(cos))
      
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)
      
      
      legend("bottomleft", legend=c("Nouveaux mots", "Tréâtre", "Jardin", "Cinéma","Musique", "Mots rajoutés"),
             col=c("#FFFFFF", "green", "#FFFF00", "#003300", "#660066","black"), lty=1, cex=1, box.lty=0)
      legend("bottomright", legend=c("Villes ou il fait bon vivre", "Villes célèbres pour leur festival de musique",
                                     "Villes célèbres pour leur festival de théâtre", "Villes célèbres pour leur festival de cinéma"),
             col=c("#FF0000", "#000066", "#00CCFF", "#FF6699"), lty=1, cex=1, box.lty=0)
      
      
      if(colnames(iso) %in% names(last))
      {
        
      }
      else {
        last<-cbind(last,iso)
        write.table(last, file = "./csv/dfa.csv",sep=",", row.names = FALSE);
      }
      
      system("chgrp rstudio_users ./csv/dfa.csv")  
      system("chmod g+w ./csv/dfa.csv")
      
      
      
      
      
      
      ### ACP ###
      
      
      
      X<-{ X2() }
      
      
      if (sum(ls()=="L")==0) L=2
      n=nrow(X)
      p=ncol(X)
      
      X=scale(X)*sqrt(n/(n-1))
      
      V=cor(X)
      d=eigen(V,symmetric=T)
      cp=X%*% d$vectors
      colnames(cp)=paste("cp",1:p,sep="")
      
      contributions=d$values
      
      
      
      ranges <- reactiveValues(x = c(min(cp[,1]),max(cp[,1])), y = c(min(cp[,2]),max(cp[,2])))
      
      output$Plot2 <- renderPlot({
        
        
        qplot(x=cp[,1],y=cp[,2],
              xlab=paste("Axe 1   -   ",round(100*contributions[1]/p,2)," %",sep=""), 
              ylab=paste("Axe 2   -   ",round(100*contributions[2]/p,2)," %",sep="") ,main = "ACP axes 1 et 2", xlim=ranges$x, ylim=ranges$y)+
          geom_text_repel(aes(label=rownames(X)), size = 5)
        
      })
      
      
      
      observeEvent(input$plot2_dblclick, {
        brush <- input$plot2_brush
        if (!is.null(brush)) {
          ranges$x <- c(brush$xmin, brush$xmax)
          ranges$y <- c(brush$ymin, brush$ymax)
          
        } else {
          ranges$x <- c(min(cp[,1]),max(cp[,1]))
          ranges$y <- c(min(cp[,2]),max(cp[,2]))
        }
        
      }) 
      
      
      
      ranges2 <- reactiveValues(x = c(min(cp[,2]),max(cp[,2])), y = c(min(cp[,3]),max(cp[,3])))
      
      output$Plot3 <- renderPlot({
        
        
        qplot(x=cp[,2],y=cp[,3],
              xlab=paste("Axe 2   -   ",round(100*contributions[2]/p,2)," %",sep=""), 
              ylab=paste("Axe 3   -   ",round(100*contributions[3]/p,2)," %",sep="") ,main = "ACP axes 2 et 3", xlim=ranges2$x, ylim=ranges2$y)+
          geom_text_repel(aes(label=rownames(X)), size = 5)
        
      })
      
      
      
      observeEvent(input$plot3_dblclick, {
        brush <- input$plot3_brush
        if (!is.null(brush)) {
          ranges2$x <- c(brush$xmin, brush$xmax)
          ranges2$y <- c(brush$ymin, brush$ymax)
          
        } else {
          ranges2$x <- c(min(cp[,2]),max(cp[,2]))
          ranges2$y <- c(min(cp[,3]),max(cp[,3]))
        }
        
      }) 
      
      
      
      
    })
  })
})