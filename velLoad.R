################################################################
##
## Code that loads, cleans, and calculates effect sizes for re-analysis of 
## Vellend et al. 2013 data
##
## by Jarrett Byrnes
##
## Last Changed: Dec 28, 2013
##
## Changelog
##
################################################################

##@knitr loadThings
library(gdata)
library(ggplot2)
library(lme4)
library(lmerTest)
library(plyr)

##@knitr ProcessData
vel <- read.xls("~/Dropbox/Papers2/Articles/Unknown/Vellend/Supplemental/Vellend.xls")

#get rid of 1700s data point, as I think its a typo and isn't useful
#or valid for these analyses anyway. Tests with versus without show
#that this one data point does not qualitatively alter outcomes
#although it increases p values. So, it is an outlier to the set. 
#worth noting.
vel <- subset(vel, vel$Year1_min>1900)

#calculate the effect size using eqn in text and some other metrics
vel <- within(vel,{
  effect <- (log(SR_Year2_CT) - log(SR_Year1_CT))/(Duration/10)
  effect_no_duration <- (log(SR_Year2_CT) - log(SR_Year1_CT))
  duration_decadal <- ceiling(Duration/10)*10-5
  porp_change <- (SR_Year2_CT-SR_Year1_CT)/SR_Year1_CT
})    											 

#Some analyses need effect to not be NA
velClean <- subset(vel, !is.na(vel$effect_no_duration))
velClean$Study <- factor(velClean$Study)
