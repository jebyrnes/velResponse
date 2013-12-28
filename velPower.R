################################################################
##
## Code that shows how power changes when one moves from a model 
## analyzing a regression relationship to one analyzing a ratio
## including an example with the coefficients from our fit model
## of effect_no_duration ~ Duration and a resampling test using our
## model versus that of Vellend et al.
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


##@knitr ratebias-power

#show the general loss of power when you
#divide a response variable by its predictor
#then analyze the mean versus the slope
#and look at the effects of skewing the predictor

simBiasPower <- function(b=-1, a=0, ySD = 2, n=100, nsim=100, xmin=0, xmax=10, rate=0.5){
  sapply(1:nsim, function(i) {
    x_unbiased <- runif(n, xmin,xmax)
    x_biased <- rexp(n,rate)
    
    #scale x_biased to be similar to x_unbiased
    # x_biased <- x_biased*xmax/max(x_biased)
    
    unbiasedY <- rnorm(n, a+b*x_unbiased, ySD)
    biasedY <- rnorm(n, a+b*x_biased, ySD)
    
    return(c(unbiasedSlopeP= coef(summary(lm(unbiasedY ~ x_unbiased)))[2,4],
             unbiasedRatioP = coef(summary(lm(unbiasedY/x_unbiased ~ 1)))[1,4],
             biasedSlopeP = coef(summary(lm(biasedY ~ x_biased)))[2,4],
             biasedRatioP = coef(summary(lm(biasedY/x_biased ~ 1)))[1,4]
    ))  
  })
}

pMat <- as.data.frame(t(simBiasPower()))
powerBySim <- colwise(function(acol) sum(acol<=0.05)/1000)(pMat)

powerBySim

##@knitr andy-ratebias-power
#This shows that if the data exhibits similar properties as from our
#fit model above, that the ratio approach has lower power than trying
#to fit for a slope. Note, the biased data does not always produce as
#large of a dropoff in power. However, looking at the log transform
#of vel$Duration shows that the log distribution is not as skewed
#hist(log(vel$Duration), 100)

aMat <- as.data.frame(t(simBiasPower(b=fixef(andyMod)[2], 
                                     a=fixef(andyMod)[1],
                                     ySD=summary(andyMod)$sigma,
                                     nsim=1000,
                                     n=length(na.omit(vel$effect_no_duration)),
                                     xmin=min(log(vel$Duration), na.rm=T),
                                     xmax=max(log(vel$Duration), na.rm=T),
                                     rate=fitdistr(log(vel$Duration), "exponential")$estimate)))

aPowerBySim <- colwise(function(acol) sum(acol<=0.05)/1000)(aMat)

aPowerBySim

##@knitr vel-power-loss
#we can test for this power loss empirically
#by resampling from the Vellend et al. data
#and fitting the two different relationships, then calculating
#power by simulation assuming the null should be rejected
nsims <- 1000
n <- nrow(velClean)


#Resample the effects data with replacement
#then fit a model looking at the mean of the ratio
#or the slop of duration
require(nlme)
pMat <- sapply(1:nsims, function(i) {
  velNew <- velClean[resample(1:n, n, replace=T),]
  
  rfit <- lme(effect ~ 1, random =~1|Study, data=velNew)
  dfit <- lme(effect_no_duration ~ Duration, random =~1|Study, data=velNew)
  
  return(c(ratio = summary(rfit)$tTable[1,5],
           duration = summary(dfit)$tTable[2,5]))
})


#What fraction of the simulations was there
#a p values <=0.05?
rowSums(pMat<=0.05)/ncol(pMat)