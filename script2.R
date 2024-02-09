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

fModele <- function(cheminCsv, nomX = names(etalonnage)[1], nomY= names(etalonnage)[2]){
  etalonnage <- read.csv2(paste0(cheminCsv, ".csv"), sep = ",")
  print("Summary :")
  print( summary(etalonnage) )
  modele <- lm(etalonnage[,2]~etalonnage[,1])
  print(paste0("Regression linéaire de la ",nomY,"en fonction de ",nomY))
  print(summary(modele))
  
  # par(mfrow=c(2,2))
  # plot(modele)
  # par(mfrow=c(1,1))
  print("Test de Breusch-Pagan")
  bp_test <- bptest(modele)
  print(bp_test)
  
  alpha = 0.95
    #df = as.numeric(nobs(modele))
    #sigma_y <- summary(modele)$sigma
  b0 <- coef(modele)[1]
  b1 <- coef(modele)[2]

  #LOB <-  (qt(1 - alpha/2, df = df)*sigma_y-b0)/b1
  #rrrrrrrrrrrrrr
    n <- nrow(etalonnage)
    dll <- n - 1
    quantileStudent <- qt(1 - alpha/2, df = dll)
    mY <- mean(etalonnage[,2])
    sigma_y <- sd(etalonnage[,2])
    LOB <- (mY + quantileStudent * sigma_y * ((n+1)/n)^0.5 - b0 ) / b1
  #rrrrrrrrrrrrrrrrrrrrrr
  print(paste0("Limite de blanc gaussien: ", LOB))
  
  
  
  
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

fModele("etalonnage_color")

fModele("etalonnage_dagi")

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
