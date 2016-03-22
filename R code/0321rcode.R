library(ggplot2)

# by year
qplot(factor(year), HEI2010_TOTAL_SCORE, data = perday, geom = "boxplot")

p <- ggplot(perday, aes(factor(year), HEI2010_TOTAL_SCORE))
p+geom_boxplot(aes(fill=factor(year)))

# by person
p <- ggplot(perday, aes(factor(UserName), HEI2010_TOTAL_SCORE))
p+geom_boxplot(aes(fill=factor(UserName)))

# first step: one-way anova
reg1 <- lm(HEI2010_TOTAL_SCORE~year, data = perday)
anova(reg1)

# second step: independent two sample t-tests 

# 2.1, 2013 and 2014
t.test(HEI2010_TOTAL_SCORE[year=="2013"], HEI2010_TOTAL_SCORE[year=="2014"])

# 2.2, 2013 and 2015
t.test(HEI2010_TOTAL_SCORE[year=="2013"], HEI2010_TOTAL_SCORE[year=="2015"])

# 2.3, 2014 and 2015
t.test(HEI2010_TOTAL_SCORE[year=="2014"], HEI2010_TOTAL_SCORE[year=="2015"])


# third step: two-way anova
reg2 <- lm(HEI2010_TOTAL_SCORE~UserName+year)
anova(reg2)



