# per person
perperson <- read.csv("total_perperson.csv", header = T, stringsAsFactors = F)
attach(perperson)
reg1 <- lm(HEI_score~.-UserName, data=perperson)
summary(reg1)

# per day

# multiple regression
reg2 <- lm(HEI2010_TOTAL_SCORE~Tot_Veg+GreenAndBean+Tot_Fruit+WholeFruit+
             WholeGrain+Tot_Dairy+Tot_Protein+SeafoodAndPlantProtein+
             FattyAcid+Sodium+RefinedGrain+Empty_Calories+year)
summary(reg2)

# produce a correlation matrix
cor(perday[,-c(1:4)])

# histgrams of each sub-categories
hist(perday$Tot_Veg)
hist(perday$GreenAndBean)
hist(perday$Tot_Fruit)
hist(perday$WholeFruit)
hist(perday$WholeGrain)
hist(perday$Tot_Dairy)
hist(perday$Tot_Protein)
hist(perday$SeafoodAndPlantProtein)
hist(perday$FattyAcid)
hist(perday$Sodium)
hist(perday$RefinedGrain)
hist(perday$Empty_Calories)

----------------------------------------------------
## the following code is from this tutorial:
## http://rpsychologist.com/r-guide-longitudinal-lme-lmer
  
# lme4
library(lme4)
lme.n <- lmer(HEI2010_TOTAL_SCORE ~ 1 + (1 | UserName), data=perday, 
              REML = T, verbose = F)
summary(lme.n)

# nlme
library(nlme)
lme(HEI2010_TOTAL_SCORE ~ 1, random = ~ 1 | UserName, data=perday)

# unconditional growth model
# lme4
lme.mod1 <- lmer(HEI2010_TOTAL_SCORE ~ RecallNo + (RecallNo | UserName), data=perday)


# nlme
lme(HEI2010_TOTAL_SCORE ~ RecallNo, random = ~ RecallNo | UserName, data=perday)

# best subset selection
library(leaps)
reg.full <- regsubsets(HEI2010_TOTAL_SCORE~Tot_Veg+GreenAndBean+Tot_Fruit+WholeFruit+
                         WholeGrain+Tot_Dairy+Tot_Protein+SeafoodAndPlantProtein+
                         FattyAcid+Sodium+RefinedGrain+Empty_Calories+year, perday)
summary(reg.full)


# correlation matrix
