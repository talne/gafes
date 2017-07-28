library(shiny)
#library(rCharts)
library("DBI")
library("RMySQL")
library("sparcl")
library("ggplot2")
library("Cairo")
library("ggrepel")

shinyServer(function(input, output, session){
  
  #fonctions pour récupérer les effectifs lissés par semaines 
  fest.default <- function(){
    hdb=list() ;hdb$u='miner' ;hdb$p='' ;hdb$h='localhost' ;hdb$d="gafes"
    return(hdb)
  }
  numsem<-function(n){
    if (n<201600) 
      return(n-201518)
    else
      return(n-201600+34)
  }
  fest.tag3 <- function(w,d1="2015-05-01",d2="2016-10-30"){
    hdb=fest.default()
    mydb=dbConnect(MySQL(),
                   user=hdb$u,password=hdb$p,host=hdb$h,dbname=hdb$d)
    q=paste("select YEARWEEK(created_at) as y, count(*) as \"",w,"\"
            from clef_microblogs_tbl where match (content) against (\"+",w,"\" IN BOOLEAN MODE)
            and timestamp(created_at)>='",d1,"' and timestamp(created_at)<='",d2,"' group by y ORDER by y;", sep="")
    df=dbGetQuery(mydb,q)
    dbDisconnect(mydb)
    
    tab=rep(0,78)
    for(i in 1:length(df$y)){
      tab[numsem(df[i,1])]=df[i,2]
    }
    tab<-as.matrix(tab)
    
    tab1=rep(0,78)
    tab1<-as.matrix(tab1)
    tab1[1,1]=tab[1,1]
    tab1[78,1]=tab[78,1]
    for(i in 2:77){
      tab1[i,1]=mean(c(tab[(i-1),1],tab[i,1],tab[(i+1),1]))
    }
    colnames(tab1)="Nouveau mot"
    return(tab1)
  }
  
  
  #fonction qui récupère le vecteur du mot demandé
  w2v <- function(w){
    cat(as.character(w) ,file="./Gafes/wordlist/liste_rajout.txt")
    system("./Gafes/extractVectors.py -i ./Gafes/clef_microblogs_tbl_full.vector.bin -o ./Gafes/wordextract/extract_rajout.csv -w ./Gafes/wordlist/liste_rajout.txt")
    tab <- read.table("./Gafes/wordextract/extract_rajout.csv", sep = ";",header = F, row.names = 1)
    tab<-tab[,-200]
    tab <- t(tab)
    tab<-as.matrix(tab)
  }
  
  #fonction qui calcule la distance cosinus (1-cosinus)
  cosineDist <- function(x){ as.dist(1 - x%*%t(x)/(sqrt(rowSums(x^2) %*% t(rowSums(x^2)))), upper = T, diag = TRUE) }
  
  #récupération de la matrice des vecteurs des mots de base
  y<-read.csv("./Gafes/wordextract/extract2.csv", sep = ",",header = T)
  y<-y[,-1]
  
  y <-as.matrix(y)
  
  #récupération de la matrice des effectifs des mots de base
  y2<-read.csv("YSM4.csv", sep = ",")
  
  output$Plot <- renderPlot({
    input$goButton
    
    #récupération de la matrice des vecteurs des mots rajoutés
    last<-read.csv("./csv/dfa.csv", sep = ",")
    
    #récupération de la matrice des effectifs des mots rajoutés
    last2<-read.csv("./csv/dfa2.csv", sep = ",")
    
    ranges <- reactiveValues(x = NULL, y = NULL)  
    
    #fonction réactive pour récupérer les vecteurs du mots demandé en input$rajout  
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
    
    
    #fonction réactive pour obtenir la matrice des vecteurs de tous les mots cochés
    X2= reactive({
      X=as.matrix(t(cbind(iso,y[,c(input$choix,input$choix2,input$choix3,input$choix4,input$choix5,input$choix6,input$choix7,input$choix8)],last[,input$nv])))
    })
    
    k="NULL"
    #fonction réactive pour récupérer les effectifs du mots demandé en input$rajout 
    newdfa2= reactive({
      k = as.character(input$rajout)
      dfa2=last2[,1]
      if(k %in% names(last)){
        dfa2=last2[,colnames(last2)==k]
      }
      else{  
        dfa2 = fest.tag3(w=k)
        colnames(dfa2)=k
      }
      dim(dfa2)=c(nrow(last2),1)
      colnames(dfa2)=k
      dfa2
    })
    
    
    #fonction réactive pour obtenir la matrice des effectifs de tous les mots cochés
    X22= reactive({
      X2=as.matrix(cbind(iso2,y2[,c(input$choix,input$choix2,input$choix3,input$choix4,input$choix5,input$choix6,input$choix7,input$choix8)],last2[,input$nv]))
    })    
    
    isolate({            
      #met a jour l'affichage des mots rajoutés
      updateCheckboxGroupInput(session, "nv",'Mots rajoutés:',inline = TRUE, names(last), selected = input$nv)
      
      iso<-{ newdfa() }
      
      #calcul le cosinus de la matrice des vecteurs des mots séléctionnés
      mat <- cbind(iso,y[,c(input$choix,input$choix2,input$choix3,input$choix4,input$choix5,input$choix6,input$choix7,input$choix8)],last[,input$nv])
      cos<-cosineDist(t(mat))
      cos<-as.matrix(cos)
      #création et affichage du dendrogramme
      hc<-hclust(as.dist(cos),method = input$method)
      
      ColorDendrogram(hc, y=c( rep("#FFFFFF",length(input$rajout)),rep("green",length(input$choix)),
                               rep("#FFFF00",length(input$choix2)),rep("#003300",length(input$choix3)),
                               rep("#660066",length(input$choix4)),rep("#FF0000",length(input$choix5)),
                               rep("#000066",length(input$choix6)),rep("#00CCFF",length(input$choix7)),
                               rep("#FF6699",length(input$choix8)),rep("black",length(input$nv))),
                      main = input$title, branchlength = 0.2, labels = colnames(cos))
      
      coord_cartesian(xlim = ranges$x, ylim = ranges$y, expand = FALSE)
      
      abline(h=hc$height[dim(mat)[2]-input$clusters],lty=2, col="red")
      
      #legendes des couleurs
      legend("bottomleft", legend=c("Nouveaux mots", "Tréâtre", "Jardin", "Cinéma","Musique", "Mots rajoutés"),
             col=c("#FFFFFF", "green", "#FFFF00", "#003300", "#660066","black"), lty=1, cex=1, box.lty=0)
      legend("bottomright", legend=c("Villes ou il fait bon vivre", "Villes célèbres pour leur festival de musique",
                                     "Villes célèbres pour leur festival de théâtre", "Villes célèbres pour leur festival de cinéma"),
             col=c("#FF0000", "#000066", "#00CCFF", "#FF6699"), lty=1, cex=1, box.lty=0)
      
      
      #boucle qui rajoute a dfa.csv le mot rajouté si celui-ci n'existe pas déja dans le fichier
      if(colnames(iso) %in% names(last))
      {
        
      }
      else {
        last<-cbind(last,iso)
        write.table(last, file = "./csv/dfa.csv",sep=",", row.names = FALSE);
      }
      
      system("chgrp rstudio_users ./csv/dfa.csv")  
      #system("chmod g+w ./csv/dfa.csv")
      system("chown -R uapv1600713:rstudio_users ts_w2v")
      system("chmod -R g+rwx ts_w2v")
      
      
      
      iso2<-{ newdfa2() }
      colnames(iso2)=as.character(input$rajout)
      
      
      #boucle qui rajoute a dfa2.csv le mot rajouté si celui-ci n'existe pas déja dans le fichier
      if(colnames(iso2) %in% names(last2))
      {
        
      }
      else {
        last2<-cbind(last2,iso2)
        write.table(last2, file = "./csv/dfa2.csv",sep=",", row.names = FALSE);
      }
      
      
      ### ACP ###
      
      
      
      X<-{ X2() }
      
      
      #script pmbo pour calculer les CP
      if (sum(ls()=="L")==0) L=2
      n=nrow(X)
      p=ncol(X)
      
      X=scale(X)*sqrt(n/(n-1))
      
      V=cor(X)
      d=eigen(V,symmetric=T)
      cp=X%*% d$vectors
      colnames(cp)=paste("cp",1:p,sep="")
      
      contributions=d$values
      
      
      #initilisation de la fenetre de l'ACP pour que touts les mots soient visibles
      ranges <- reactiveValues(x = c(min(cp[,1]),max(cp[,1])), y = c(min(cp[,2]),max(cp[,2])))
      
      output$Plot2 <- renderPlot({
        
        #Affichage des ACP
        qplot(x=cp[,1],y=cp[,2],
              xlab=paste("Axe 1   -   ",round(100*contributions[1]/p,2)," %",sep=""), 
              ylab=paste("Axe 2   -   ",round(100*contributions[2]/p,2)," %",sep="") ,main = "ACP axes 1 et 2", xlim=ranges$x, ylim=ranges$y)+
          geom_text_repel(aes(label=rownames(X)), size = 5)
        
      })
      
      
      #boucle pour le zoom en séléctionnant une zone, et revenir a la fenetre initiale en double cliquant
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
      
      
      #idem pour les axes 2 et 3
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
      
      
      
      #somme des effectifs en fonction des classes déterminés par le modèle word2vec
      Y<-{ X2() } 
      Y2<-{ X22() }
      
      Y2<-t(Y2)
      cos<-as.matrix(cos)
      hc<-hclust(as.dist(cos),method = "complete")
      
      classif=cutree(hc,input$clusters)
      somme <- aggregate(Y2, list(classif), sum)
      Y <- somme[,-1]
      Y<-t(Y)
      Y5=Y
      Y<-scale(Y)
      Y<-t(Y)
      
      
      #boucle pour afficher les mots compris dans chaque classe
      z<-vector("numeric",dim(Y)[1])
      
      for(i in 1:dim(Y)[1]) z[i]=paste(names(classif[classif==i]),collapse="; ")
      
      rownames(Y) <- z
      colnames(Y5)=z     
      
      if (sum(ls()=="L")==0) L=2
      n=nrow(Y)
      p=ncol(Y)
      
      Y=scale(Y)*sqrt(n/(n-1))
      
      W=cor(Y)
      d=eigen(W,symmetric=T)
      cpc=Y%*% d$vectors
      colnames(cpc)=paste("cp",1:p,sep="")
      
      contributionsc=d$value      
      
      #ACP par cluster
      ranges3 <- reactiveValues(x = c(min(cpc[,1]),max(cpc[,1])), y = c(min(cpc[,2]),max(cpc[,2])))      
      
      output$Plot4 <- renderPlot({  
        
        
        qplot(x=cpc[,1],y=cpc[,2],
              xlab=paste("Axe 1   -   ",round(100*contributionsc[1]/p,2)," %",sep=""), 
              ylab=paste("Axe 2   -   ",round(100*contributionsc[2]/p,2)," %",sep="") ,main = "ACP axes 1 et 2", xlim=ranges3$x, ylim=ranges3$y) + 
          
          geom_text_repel(aes(label=rownames(Y)), size = 5)
        
        
      })
      
      
      observeEvent(input$plot4_dblclick, {
        brushc <- input$plot4_brush
        if (!is.null(brushc)) {
          ranges3$x <- c(brushc$xmin, brushc$xmax)
          ranges3$y <- c(brushc$ymin, brushc$ymax)
          
        } else {
          ranges3$x <- c(min(cpc[,1]),max(cpc[,1]))
          ranges3$y <- c(min(cpc[,2]),max(cpc[,2]))
        }
        
      })   
      output$Plot5 <- renderPlot({
        par(mar=c(6,20,1,1))
        boxplot(Y5,horizontal=TRUE,outline=FALSE, las=2)
      })
      
    })
  })
})
