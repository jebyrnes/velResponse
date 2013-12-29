################################################################
##
## Code that re-analyzes data from Vellend et al. 2013 PNAS
## demonstrating that a regression of duration versus an analysis of 
## effect/duration produces different results as per Andy's ideas
##
## by Jarrett Byrnes
##
## Last Changed: Dec 28, 2013
##
## Changelog
##
################################################################

##@knitr velDataLoad
source("./velLoad.R", echo=FALSE)

##@knitr velAnalysis
velMod <- lmer(effect ~ 1 + (1|Study), data=vel)
summary(velMod)

#check the p value fitting using ML as per Zuur
velModML <- lmer(effect ~ 1 + (1|Study), data=vel, REML=F)
summary(velModML)


##@knitr andyAnalysis
andyMod <- lmer(effect_no_duration ~ I(log(Duration)) + (1|Study), data=vel)
summary(andyMod)

#check the p value fitting using ML as per Zuur
andyModML <- lmer(effect_no_duration ~ I(log(Duration)) + (1|Study), data=vel, REML=F)
summary(andyModML)

##@knitr andyAnalysisLinear
andyModLinear <- lmer(effect_no_duration ~ Duration + (1|Study), data=vel)
summary(andyModLinear)

##@knitr andyAnalysisLossGain
andyModGain <- lmer(effect_no_duration ~ I(log(Duration)) + (1|Study), 
                    data=subset(vel, vel$effect_no_duration>0))
summary(andyModGain)

andyModLoss <- lmer(effect_no_duration ~ I(log(Duration)) + (1|Study),								
                    data=subset(vel, vel$effect_no_duration<0))

summary(andyModLoss)