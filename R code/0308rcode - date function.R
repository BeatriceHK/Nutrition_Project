total13 <- rbind(ARC13_Baseline_Post_TNMYPHEI, ARC13_3.month_TNMYPHEI)
total2013 <- write.csv("total2013.csv", total13)
write.csv(total13, "total2013.csv")

?date
library(date)
Sys.time()
ttt <- "05092013"
func <- function(t){
  t <- strsplit(t)
}


?strspli
?substr
ttt <- as.character(ttt)
class(ttt)
head(ttt)




timefunc <- function(ttt){
  ttt <- as.character(ttt)
  newt <- NULL
  print(length(ttt))
  for(i in c(1:length(ttt))){
    temp1 <- substr(ttt[i],1,1)
    temp2 <- substr(ttt[i],2,3)
    temp3 <- substr(ttt[i],4,7)
    newt[i] <- paste(temp1,temp2,temp3,sep="/")
  }
    return(newt)
  }
length(ttt)
total13$IntakeDate <- timefunc(total13$IntakeDate)
head(total13$IntakeDate)


#-------------------------------------------------------
attach(total__chart)
reg1 <- lm(HEI2010_TOTAL_SCORE ~ NumFoods+RecallNo+KCAL)
summary(reg1)

