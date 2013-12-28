################################################################
##
## Code that re-analyzes data from Vellend et al. 2013 PNAS
## and shows the problems with their fit model in terms of residuals
## and influence of short duration points
##
## by Jarrett Byrnes
##
## Last Changed: Dec 28, 2013
##
## Changelog
##
################################################################

##@knitr loadVelModels
source("./velModel.R", echo=FALSE)


##@knitr velProblems
#show how shorter duration studies have larger residuals
#and larger leverage
library(influence.ME)

par(mfrow=c(1,2))
plot(velClean$Duration, residuals(velMod, type="response"))
plot(log(velClean$Duration), residuals(velMod, type="response"))
par(mfrow=c(1,1))

inf <- influence(velMod, obs=T)
w <- cooks.distance(inf)
par(mfrow=c(1,2))
plot(velClean$Duration, w, ylab="Cook's Distance")
plot(log(velClean$Duration), w, ylab="Cook's Distance")
par(mfrow=c(1,1))
