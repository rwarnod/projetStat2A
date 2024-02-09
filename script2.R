rm(list=ls())

# calculer la variance des balncs pour verifier l'homocedasticité
# calculer limite de detection et de quantification
# faire une fonction pour tout

#setwd("~/Documents/projet_stat/data") Camille
setwd("~/Cours2A/projetStat2/projetStat2A/data") #Raymond
library(dplyr)
library(ggplot2)
library(lmtest)

cheminCsv<- "etalonnage_color"

fModele <- function(
    cheminCsv, 
    nomX = names(etalonnage)[1],
    nomY= names(etalonnage)[2],
    alpha = 0.05
  ){
  print(cheminCsv)
  #etalonnage <- read.csv2(paste0(cheminCsv, ".csv"), sep = ",")
  etalonnage <- read.csv2(cheminCsv, sep = ",")
  print("Summary :")
  print( summary(etalonnage) )
  modele <- lm(etalonnage[,2]~etalonnage[,1])
  print(paste0("Regression linéaire de ", nomY,"en fonction de ",nomX))
  print(summary(modele))
  
  # par(mfrow=c(2,2))
  # plot(modele)
  # par(mfrow=c(1,1))
  print("Test de Breusch-Pagan")
  bp_test <- bptest(modele)
  print(bp_test)
  
  #alpha = 0.95
    #df = as.numeric(nobs(modele))
    #sigma_y <- summary(modele)$sigma
  b0 <- coef(modele)[1]
  b1 <- coef(modele)[2]

  #LOB <-  (qt(1 - alpha/2, df = df)*sigma_y-b0)/b1
  
  # calcul du LOB Gaussien
  #rrrrrrrrrrrrrr
    n <- nrow(etalonnage)
    dll <- n - 1
    quantileStudent <- qt(1 - alpha, df = dll)
    mY <- mean(etalonnage[,2])
    sigma_y <- sd(etalonnage[,2])
    LOB <- (mY + quantileStudent * sigma_y * ((n+1)/n)^0.5 - b0 ) / b1
  #rrrrrrrrrrrrrrrrrrrrrr
  print(paste0("Limite de blanc gaussien: ", LOB))
  
  # calcul du LOB à partir des données
  dll <- n - 2
  quantileStudent <- qt(1 - alpha, df = dll)
  b1ab <- abs(b1)
  SX <- sum(etalonnage[,1])
  D <- n*sum(etalonnage[,1]^2) - SX^2
  
  A <- quantileStudent * (sigma_y/b1ab)
  LOB <- A * ( (n+1) /n + (SX*SX) /(n*D) )^0.5
  
  print(paste0("Limite de blanc à partir des données: ", LOB))
  # B <- A *sqrt(n) / (sqrt(D)*b1ab)
  # LOB <- B* ( (b1^2)*D*(n+1) /n^2 + mY^2 - 2*mY*b0 + b0^2)^0.5
  
  
  # etalonnage <- etalonnage %>%
  #   mutate(esti = b0 +b1*Concentration)
  # plot(etalonnage$Concentration, etalonnage$esti)
  
  
  ggplot(etalonnage) +
    aes(x = etalonnage[,1], y = etalonnage[,2]) +
    #aes(x = Concentration, y = DO) +
    geom_point(colour = "red", alpha = 1) +
    labs(x = nomX, y = nomY) +
    geom_smooth(method = "lm") +
    #  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = T, color = "green") +
    theme_light()
}

liste_fichiers <- list.files(".", pattern="csv")

# Lancement du modele lineaire sur tous les fichiers csv
Map(fModele, liste_fichiers)

#les limites de blancs sont un peu bizzares.

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
