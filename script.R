rm(list=ls())

#setwd("~/Documents/projet_stat/data") Camille
#setwd("~/Cours2A/projetStat2/projetStat2A/data") Raymond
library(dplyr)
library(ggplot2)
library(lmtest)


etalonnage = read.csv2("etalonnage_9_02_23.csv", sep = ",")

summary(etalonnage)

ggplot(etalonnage) +
  aes(x = Concentration, y = Temps) +
  geom_point(colour = "red", alpha = 1) +
  labs(x = "Concentration", y = "Temps") +
  geom_smooth(method = "lm") +
#  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = T, color = "green") +
  theme_light()

modele <- lm(Concentration~., data = etalonnage)
summary(modele)
par(mfrow=c(2,2))
plot(modele)
par(mfrow=c(1,1))
# Effectuez le test de Breusch-Pagan
bp_test <- bptest(modele)
print(bp_test)


alpha = 0.95
df = as.numeric(nobs(modele))
sigma_y <- summary(modele)$sigma
b0 <- coef(modele)[1]
b1 <- coef(modele)[2]
LOB =  (qt(1 - alpha/2, df = df)*sigma_y-b0)/b1

#II
etalonnage2 = read.csv2("etalonnage_dagi.csv", sep = ",")

summary(etalonnage2)

ggplot(etalonnage2) +
  aes(x = Concentration, y = Temps) +
  geom_point(colour = "red", alpha = 1) +
  labs(x = "Concentration", y = "Temps") +
  geom_smooth(method = "lm") +
  #  geom_smooth(method = "lm", formula = y ~ poly(x, 2), se = T, color = "green") +
  theme_light()

modele2 <- lm(Concentration~., data = etalonnage)
summary(modele2)

#III

etalonnage3 = read.csv2("etalonnage_9_02_23.csv", sep = ",")
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
