rm(list=ls())

# calculer la variance des balncs pour verifier l'homocedasticité
# calculer limite de detection et de quantification
# faire une fonction pour tout

#setwd("~/Documents/projet_stat/data") Camille
setwd("~/Cours2A/projetStat2/projetStat2A/data") #Raymond

library(dplyr)
library(ggplot2)
library(lmtest)

#### limites de blancs à partir de la droite d'étalonnag

#retourne vecteur:
  # - b0 et b1 les paramètres de la droite de regression lineaire de col2 
  #  en fonction de col1
  # - sigma_y l'écat type de col2
  # - D = n*sum(etalonnage[,1]^2) - SX^2 
  #       n = nrow(etalonnage) ; SX = sum(etalonnage[,1])
  # - limites de blancs à partir de la droite d'étalonnage (LOB)
  # - limites de detection, solution de l'équation du second degré (LID1 et LID2)
  # - limites de quantification (LIQ1 et LIQ2)
  # - limites de quantification relative (LIQR1 et LIQR2)

fModele <- function(
    # chemin des données d'étalonnage x = col1 et y = col2
    cheminCsv,
    # C'est de le nom des axes pour la représentation graphique
    nomX = names(etalonnage)[1],
    nomY= names(etalonnage)[2],
    # c'est le alpha pour les quantiles  de la loi de Student
    alpha = 0.05,
    # Titre du graphique de la regression
    titreGraph = cheminCsv,
    # si "graph retourne le graph sinon le vecteur
    retour = "df",
    # Precision absolue pour le calcul de la limite de quantification
    precision = 10,
    # Precision relative pour le calcul de la limite de quantification
    precisionRelative = sd(etalonnage[,1])/ mean(etalonnage[,1])
  ){
  print(cheminCsv)
  #etalonnage <- read.csv2(paste0(cheminCsv, ".csv"), sep = ",")
  etalonnage <- read.csv2(cheminCsv)
  etalonnage
  # print("Summary :")
  # print( summary(etalonnage) )
  modele <- lm(etalonnage[,2]~etalonnage[,1])
  print(paste0("Regression linéaire de ", nomY," en fonction de ",nomX))
  print(summary(modele))
  

  # print("Test de Breusch-Pagan")
  # bp_test <- bptest(modele)
  # print(bp_test)
  
  
  b0 <- coef(modele)[1]
  b1 <- coef(modele)[2]

  #LOB <-  (qt(1 - alpha/2, df = df)*sigma_y-b0)/b1
  

  # calcul du LOB à partir de l'étalon
  n <- nrow(etalonnage)
  #sigma_y <- sd(etalonnage[,2])
  sigma_y <- sigma(modele)
  dll <- n - 2
  quantileStudent <- qt(1 - alpha, df = dll)
  b1ab <- abs(b1)
  SX <- sum(etalonnage[,1])
  D <- n*sum(etalonnage[,1]^2) - SX^2
  
  A <- quantileStudent * (sigma_y/b1ab)
  LOB <- A * ( (n+1)/n + (SX*SX)/(n*D) )^0.5
  
  # On calcul la limite de détection LID 
  
  print(paste0("Limite de blanc à partir des données d'étalonnage: ", LOB))
  # B <- A *sqrt(n) / (sqrt(D)*b1ab)
  # LOB <- B* ( (b1^2)*D*(n+1) /n^2 + mY^2 - 2*mY*b0 + b0^2)^0.5
  
  # On calcul la limite de détection LID
  quantileStudent <- qt(alpha, df = dll)
  K <- (quantileStudent*sigma_y/b1)^2
  mX <- SX/n
  
  a <- (1 - n*K/D)
  b <- 2*(n*K*mX/D - LOB)
  c <- LOB^2 - K*(n+1)/n - (n*K*mX^2)/D
  delta <- b^2 - 4*a*c
  print(paste0("Delta LID: ", delta))
  if (delta<0){
    LID1 <- 0
    LID2 <- 0
  }else{
    LID1 <- (-b - sqrt(delta)) / (2*a)
    LID2 <- (-b + sqrt(delta)) / (2*a)
  }

  
  # On calcul la limite de quantification absolue
  quantileStudent <- qt(1 - alpha/2, df = dll)
  
  t <- (quantileStudent*sigma_y/b1)^2
  a <- t*n/D
  b <- -2*mX*a
  c <- t*((n+1)/n + (n*mX^2)/D) - precision^2
  delta <- b^2 - 4*a*c
  print(paste0("Delta LIQ: ", delta))
  if (delta<0){
    LIQ1 <- 0
    LIQ2 <- 0
  }else{
    LIQ1 <- (-b - sqrt(delta)) / (2*a)
    LIQ2 <- (-b + sqrt(delta)) / (2*a)
  }

  
  # On calcul la limite de quantification relative
  print(paste0("Presicion relative : ", precisionRelative))
  a <- t*n/D - precisionRelative^2
  b <- -2*mX*t*n/D
  c <- t*((n+1)/n + (n*mX^2)/D)
  delta <- b^2 - 4*a*c
  print(paste0("Delta LIQR: ", delta))
  if (delta < 0 ){
    LIQR1 <- 0
    LIQR2 <- 0
  }else{
    LIQR1 <- (-b - sqrt(delta)) / (2*a)
    LIQR2 <- (-b + sqrt(delta)) / (2*a)
  }

  
  
  if (retour == "graph"){
    ggplot(etalonnage) +
    aes(x = etalonnage[,1], y = etalonnage[,2]) +
    #aes(x = Concentration, y = DO) +
    geom_point(colour = "red", alpha = 1) +
    labs(title = titreGraph, x = nomX, y = nomY) +
    geom_smooth(method = "lm") +
  #    geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = T, color = "green") +
    theme_light()
  }else{
    data.frame( b0 = b0, b1 = b1, sigma_y = sigma_y,D=D,
                LOB= LOB, LID1 = LID1, LID2 = LID2, LIQ1 = LIQ1,
                LIQ2 = LIQ2, LIQR1 = LIQR1,
                LIQR2 = LIQR2  )
  }
}

liste_fichiers <- list.files(".", pattern="csv")

## Argatroban
fichiersArgatroban <- c("argatrobanEtalonAvril.csv",
                        "argatrobanEtalonJanvier.csv",
                        "argatrobanEtalonOctobre.csv")

Argatroban <-do.call("rbind", Map(fModele, fichiersArgatroban))


Argatroban <-do.call("rbind", 
                     Map(function (x) fModele(x, precisionRelative = 0.5), 
                         fichiersArgatroban) )

# Modele hétérogene

fModeleHetero <- function(
  # chemin des données d'étalonnage x = col1 et y = col2
  cheminCsv,
  # C'est de le nom des axes pour la représentation graphique
  nomX = names(etalonnage)[1],
  nomY= names(etalonnage)[2],
  # c'est le alpha pour les quantiles  de la loi de Student
  alpha = 0.05,
  # Precision absolue pour le calcul de la limite de quantification
  precision = 10,
  # Precision relative pour le calcul de la limite de quantification
  precisionRelative = sd(etalonnage[,1])/ mean(etalonnage[,1])
){
  etalonnage <- read.csv2(cheminCsv)
  
  #Modele generalisé
  model<-glm(etalonnage[,2]~etalonnage[,1], family=gaussian(link="identity"))
  print(paste0("Regression linéaire de ", nomY," en fonction de ",nomX))
  print(summary(model))
  b0 <- coef(model)[1]
  b1 <- coef(model)[2]
  
  # calcul du LOB à partir de l'étalon
  n <- nrow(etalonnage)
  sigma_y <- sigma(model)
  dll <- n - 2
  quantileStudent <- qt(1 - alpha, df = dll)
  b1ab <- abs(b1)
  S1surX <- sum(1/(etalonnage[,1] + 0.01)) # comment on fait pour les zeros
  SX <- sum(etalonnage[,1])
  D <- n*sum(etalonnage[,1]^2) - SX^2 # a modifier
  A <- quantileStudent * (sigma_y/b1ab)
  LOB <- A * ( 1/S1surX + (n*n)/(S1surX*D) )^0.5
  
  # Calcul des limites de détection
  
  quantileStudent <- qt(1 - alpha, df = dll)
  K <- (quantileStudent*sigma_y/b1)^2
  S1surX <- sum(1/(etalonnage[,1] + 0.01)) # a modifier
  
  a <- (1 - S1surX*K/D)
  b <- 2*(n*K/D - LOB) - K
  c <- LOB^2 - (K/S1surX)*(1 + n*n/D)
  
  delta <- b^2 - 4*a*c
  print(paste0("Delta LID: ", delta))
  if (delta<0){
    LID1 <- 0
    LID2 <- 0
  }else{
    LID1 <- (-b - sqrt(delta)) / (2*a)
    LID2 <- (-b + sqrt(delta)) / (2*a)
  }
  # On calcul la limite de quantification absolue
  quantileStudent <- qt(1 - alpha/2, df = dll)
  
  t <- (quantileStudent*sigma_y/b1)^2
  a <- t*S1surX/D
  b <- -2*t*n/D
  c <- (t/S1surX)*(1 + (n^2)/D) - precision^2
  delta <- b^2 - 4*a*c
  print(paste0("Delta LIQ: ", delta))
  if (delta<0){
    LIQ1 <- 0
    LIQ2 <- 0
  }else{
    LIQ1 <- (-b - sqrt(delta)) / (2*a)
    LIQ2 <- (-b + sqrt(delta)) / (2*a)
  }
  # On calcul la limite de quantification relative
  print(paste0("Presicion relative : ", precisionRelative))
  
  a <- t*S1surX/D - precisionRelative^2
  b <- t*(1 - 2*n/D)
  c <- (t/S1surX)*(1 + (n^2)/D)
  delta <- b^2 - 4*a*c
  print(paste0("Delta LIQR: ", delta))
  if (delta < 0 ){
    LIQR1 <- 0
    LIQR2 <- 0
  }else{
    LIQR1 <- (-b - sqrt(delta)) / (2*a)
    LIQR2 <- (-b + sqrt(delta)) / (2*a)
  }
  data.frame( b0 = b0, b1 = b1, sigma_y = sigma_y,D=D,
              LOB= LOB, LID1 = LID1, LID2 = LID2, LIQ1 = LIQ1,
              LIQ2 = LIQ2, LIQR1 = LIQR1,
              LIQR2 = LIQR2  )
  
}


ArgatrobanHetero <-do.call("rbind", Map(fModeleHetero, fichiersArgatroban))


ArgatrobanHetero <-do.call("rbind", 
                     Map(function (x) fModeleHetero(x, precisionRelative = 0.5), 
                         fichiersArgatroban) )















# les LOB sont trop haut

# Droites de régression:

Map(function (x) fModele(x,retour = "graph"), fichiersArgatroban)


#### Calcul des limites de blancs avec des mesures dédiées

fLOBDedie <- function(blanc,etalonnage,alpha=0.05){
  modele <- lm(etalonnage[,2]~etalonnage[,1])
  b0 <- coef(modele)[1]
  b1 <- coef(modele)[2]
  n <- length(blanc)
  dll <- n - 1
  quantileStudent <- qt(1 - alpha, df = dll)
  mY <- mean(blanc)
  sigma_y <- sd(blanc)
  LOB <- mY + (quantileStudent * sigma_y * ((n+1)/n)^0.5 - b0 ) / b1
  return (LOB)
}

blanc <-read.csv2("blancDabitranChrono.csv")[,1]
etalonnage <- read.csv2("etalonnage_dagi.csv",sep=",")
write.csv2(etalonnage_03_04_21,"etalonnage_03_04_21.csv",sep=",")
fLOBDedie(read.csv2("blancDabitranChrono.csv")[,1],
          read.csv2("etalonnage_dagi.csv",sep=",")
          )

etalonnage <- read.csv2("etalonnage_color.csv",sep=",") %>% 
  mutate(DO=log(DO))

fLOBDedie(read.csv2("blancDabitranColor.csv")[,1],etalonnage)





















# ouverture des fichiers pour vérifier
etalonnage_11_01_23 <- read.csv2("etalonnage_11_01_23.csv", sep = ",")
etalonnage_20_10_23 <- read.csv2("etalonnage_20_10_23.csv", sep = ",")
etalonnage_color <- read.csv2("etalonnage_color.csv", sep = ",")
etalonnage_dagi<- read.csv2("etalonnage_dagi.csv", sep = ",")


#III

#etalonnage3 = read.csv2("etalonnage_9_02_23.csv", sep = ",")
etalonnage3 = read.csv2("etalonnage_color.csv", sep = ",")


etalonnage3$logDO <- log(1+etalonnage3$DO)
summary(etalonnage3)

ggplot(etalonnage3) +
  aes(x = Concentration, y = logDO) +
  geom_point(colour = "red", alpha = 1) +
  labs(x = "Concentration", y = "logDO") +
  geom_smooth(method = "lm") +
    geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = T, color = "green") +
  theme_light()

modele3 <- lm(Concentration~logDO+I(DO**2), data = etalonnage2)
summary(modele3)
BIC(modele3)
