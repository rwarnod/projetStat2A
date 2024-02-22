rm(list=ls())

# calculer la variance des balncs pour verifier l'homocedasticité
# calculer limite de detection et de quantification
# faire une fonction pour tout

#setwd("~/Documents/projet_stat/data") Camille
setwd("~/Cours2A/projetStat2/projetStat2A/data") #Raymond
library(dplyr)
library(ggplot2)
library(lmtest)

#### Calcul des limites de blancs à partir de la droite d'étalonnage

fModele <- function(
    cheminCsv, 
    nomX = names(etalonnage)[1],
    nomY= names(etalonnage)[2],
    alpha = 0.05,
    titreGraph = cheminCsv,
    retour = "df"
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
  sigma_y <- sd(etalonnage[,2])
  dll <- n - 2
  quantileStudent <- qt(1 - alpha, df = dll)
  b1ab <- abs(b1)
  SX <- sum(etalonnage[,1])
  D <- n*sum(etalonnage[,1]^2) - SX^2
  
  A <- quantileStudent * (sigma_y/b1ab)
  LOB <- A * ( (n+1) /n + (SX*SX) /(n*D) )^0.5
  
  print(paste0("Limite de blanc à partir des données d'étalonnage: ", LOB))
  # B <- A *sqrt(n) / (sqrt(D)*b1ab)
  # LOB <- B* ( (b1^2)*D*(n+1) /n^2 + mY^2 - 2*mY*b0 + b0^2)^0.5
  
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
    data.frame( b0 = b0, b1 = b1, sigma_y = sigma_y, D=D, LOB= LOB )
  }
}

liste_fichiers <- list.files(".", pattern="csv")

## Argatroban
fichiersArgatroban <- c("argatrobanEtalonAvril.csv",
                        "argatrobanEtalonJanvier.csv",
                        "argatrobanEtalonOctobre.csv")

LOB_Argatroban <-do.call("rbind", Map(fModele, fichiersArgatroban))
# les LOB sont trop haut

# Droites de régression:

Map(function (x) fModele(x,retour = "graph"), fichiersArgatroban)

# ca ne marche pas très bien pour dagi et color.



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

# il y a un truc qui ne va pas

### Calcul limite de detection



















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
