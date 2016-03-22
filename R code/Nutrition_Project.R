# read the total chart of perday output into r
perday <- read.csv("total_perday.csv", header = T, stringsAsFactors = F)
attach(perday)

# run multiple linear regression on perday results
# to see what might be significant variables that can influence the final score
reg1 <- lm(HEI2010_TOTAL_SCORE~NumFoods+KCAL+factor(year)+RecallNo, data = perday)
summary(reg1)

# look at the regression diagnostics. 
par(mfrow=c(2,2))
plot(reg1)
par(mfrow=c(1,1))

# level 1: compare output differences through out all 3 years

# basic visualizations

# HEI score, by year
boxplot(HEI2010_TOTAL_SCORE~year, perday)

# HEI score, by person
boxplot(HEI2010_TOTAL_SCORE~UserName, perday)


# Conduct an ANOVA analysis using the regression results produced above.
anova(reg1)
 
# level 2: regardless of individual difference, see if there is 
# significant improvement in scores between the first day and last day

# level 3: Are there any difference in certain people's eating habaits, 
# that might cause the individual difference among different people

#--------------------------------------------------------
# 3.15
# mixed effect model
library(lme4)

# create a model that used three fixed effects, controlling for by-person variability.
mem <- lmer(HEI2010_TOTAL_SCORE~NumFoods+KCAL+factor(year)+(1|UserName), 
            data = perday, REML = FALSE)
mem
summary(mem)

# In order to talk about model significance, we use the likelihood ratio test as 
# a means to get p-values 

# the null model
mem1 <- lmer(HEI2010_TOTAL_SCORE~1+(1|UserName), 
             data = perday, REML=FALSE)

# conduct an anova to perform the likelihood ratio test
anova(mem1, mem)

# look at the coefficients
coef(mem)




