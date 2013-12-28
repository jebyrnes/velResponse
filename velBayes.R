################################################################
##
## Code that re-analyzes data from Vellend et al. 2013 PNAS
## demonstrating that a regression of duration versus an analysis of 
## effect/duration produces different results as per Andy's ideas
## using MCMCglmm for a Bayesian flavor, although MCMCglmm does not allow
## uniform priors. Still, the defaults should be weak enough (mean=0, variance=1e10)
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

#Bayesian libraries
library(MCMCglmm)
library(arm)

##@knitr velModBayes
#a function for running 1 chain of a Bayesian model of the Vellend analysis
runVelMod <- function() MCMCglmm(effect ~ 1, random=~Study, data=velClean, 
                                 burnin=5000, thin=100, nitt=100000) #from text

#three chains, as specified in the text
velChains <- list(runVelMod(), runVelMod(), runVelMod())


velChainList <- mcmc.list(lapply(velChains, function(x) x$Sol))

plot(velChainList)

#check diagnostics
acfplot(velChainList)
gelman.diag(chainList)

#look at results
summary(velChainList)

##@knitr AndyModBayes
#function for 1 chain
runAndyMod <- function() MCMCglmm(effect_no_duration ~ log(Duration), random=~Study, data=velClean, 
                       burnin=5000, thin=100, nitt=100000) #from text

#3 chains, as specified in the Vellend et al paper.
andyChains <- list(runAndyMod(), runAndyMod(), runAndyMod())
andyChainList <- mcmc.list(lapply(andyChains, function(x) x$Sol))

#Now plots, diagnostics, and a summary
plot(andyChainList)

#diagnostics
acfplot(andyChainList)
gelman.diag(andyChainList)

summary(andyChainList)
