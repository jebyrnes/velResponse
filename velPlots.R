################################################################
##
## Code that plots reanalyses data from Vellend et al. 2013 PNAS
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

##@knitr loadVelModels
source("./velModel.R", echo=FALSE)

##@knitr plotMods
#Plot the raw data from Veland with effect ~ duration
#then add fit lines to it from the modeled data
negIDX <- which(velClean$effect_no_duration<0)
posIDX <- which(velClean$effect_no_duration>0)

velTypes <- with(velClean, data.frame(Duration = c(Duration, Duration[negIDX], Duration[posIDX]),
                                      effect_no_duration = c(effect_no_duration, effect_no_duration[negIDX], effect_no_duration[posIDX]),
                                      type=c(rep("Net", nrow(velClean)), 
                                             rep("Loss Only", length(negIDX)),
                                             rep("Gain Only", length(posIDX)) )
))

#create a new data frame (ndf) that has predicted values
up <- 100
ndf <- data.frame(type=c(rep("Net", up), rep("Loss Only", up)),
                  duration_decadal=rep(1:up,2),
                  effect_no_duration=c(log(1:up)*fixef(andyMod)[2]+fixef(andyMod)[1],
                                       log(1:up)*fixef(andyModLoss)[2]+fixef(andyModLoss)[1]),
                  ci.lower=0, ci.upper=0, n=0)

fitPlots <- ggplot(velTypes, aes(y=effect_no_duration, x=Duration)) +
  geom_point() +
  geom_point(size=2.2) +
  facet_wrap(~type) +
  xlab("Duration")+ ylab("Effect\nln(S2/S1)") +
  theme_bw(base_size=18) +
  geom_hline(yintercept=0, lwd=1.5, lty=2, color="grey") +
  geom_line(data=ndf, aes(y=effect_no_duration, x=duration_decadal), color="black", lwd=2)

fitPlots 

##@knitr plotModsLog
# Do the same thing, but on a log(Duration) Scale

fitPlotsLog <- ggplot(velTypes, aes(y=effect_no_duration, x=log(Duration))) +
  geom_point() +
  geom_point(size=2.2) +
  facet_wrap(~type) +
  xlab("Log(Duration)")+ ylab("Effect\nln(S2/S1)") +
  theme_bw(base_size=18) +
  geom_hline(yintercept=0, lwd=1.5, lty=2, color="grey") +
  geom_line(data=ndf, aes(y=effect_no_duration, x=log(duration_decadal)), color="black", lwd=2)

fitPlotsLog

##@knitr spacerPlot
###########
## Below here are methods to summarize data into durational bins
## and then plot using those bins, rather than look at the raw data
###########

##@knitr durationDecadalSummary
#A few functions to derive summaries for different metrics
#grouped by duration of study

#Get the mean and bootstrapped CI of a value of choice
getSummary <- function(adf, value="effect_no_duration", B=200){
  metrics <- Hmisc::smean.cl.boot(adf[[value]], B=B)
  ret <- c(
    mean.value = mean(adf[[value]], na.rm=T),
    ci.lower = metrics[2],
    ci.upper = metrics[3],
    n=length(na.omit(adf[[value]]))
  )
  names(ret) <- c(value, "ci.lower", "ci.upper", "n")
  ret
  
}


#Get the summary mean and CI of a value grouped by durational bin
#where each bin is a decade - i.e., 0-10, 10-20, etc. Uses the upper
#limit of each bin as the grouping value.
getSummaryOfValue <- function(value="effect_no_duration"){
  num <<-0
  velDurSummary <- lapply(list(which(vel[[value]]<0),
                               which(vel[[value]]>0),
                               which(!is.na(vel[[value]]))), function(idx){
                                 ret <- ddply(vel[idx,], "duration_decadal", function(adf){
                                   getSummary(adf, value)
                                   
                                 })
                                 ret$type <- num
                                 num <<- num+1
                                 ret
                               }
                          
  )
  
  velDurSummary <- ldply(velDurSummary)
  
  velDurSummary$type<- factor(velDurSummary$type)
  levels(velDurSummary$type) <- c("Loss Only", "Gain Only", "Net")
  
  velDurSummary
}

##@knitr plotDurationEffectDecadalSummary
#Show the mean and CI of effect sizes grouping studies into decadal bins
velDurSummary <- getSummaryOfValue()
velDurSummaryPlot <- ggplot(velDurSummary, aes(x=duration_decadal, y=effect_no_duration, 
                                               ymin=ci.lower, ymax=ci.upper, color=n)) +
  geom_point(size=3.2) +
  geom_linerange(size=1.2) +
  facet_wrap(~type) +
  ylim(c(-1,1)) +
  xlab("Duration") + ylab("Effect\nln(S2/S1)") +
  theme_bw(base_size=18) +
  geom_hline(yintercept=0, lwd=1.5, lty=2) +
  scale_color_gradient(low="blue", high="red", name="Sample Size")

velDurSummaryPlot

##@knitr plotDurationEffectDecadalSummaryLines
#Show the mean and CI of effect sizes grouping studies into decadal bins
#adding curves for those relationships that were different from 0 for log(Duration)
#using Fixed effects only
velDurSummaryPlot +
  geom_line(data=ndf, aes(y=effect_no_duration, x=duration_decadal), color="black", lwd=2)


##@knitr plotDurationEffectDecadalSummaryLinesLog
velDurSummaryPlotLog <- ggplot(velDurSummary, aes(x=log(duration_decadal), y=effect_no_duration, 
                                                  ymin=ci.lower, ymax=ci.upper, color=n)) +
  geom_point(size=3.2) +
  geom_linerange(size=1.2) +
  facet_wrap(~type) +
  ylim(c(-1,1)) +
  xlab("Log(Duration)") + ylab("Effect\nln(S2/S1)") +
  theme_bw(base_size=18) +
  geom_hline(yintercept=0, lwd=1.5, lty=2) +
  scale_color_gradient(low="blue", high="red", name="Sample Size")


velDurSummaryPlotLog + 
  geom_line(data=ndf, aes(y=effect_no_duration, x=log(duration_decadal)), color="black", lwd=2)

##@knitr plotDurationPorpDecadalSummary
#Plot the porportion change rather than effect size
#for ease of understanding
velDurPorpSummary <- getSummaryOfValue("porp_change")
decadalPlot <- ggplot(velDurPorpSummary, aes(x=duration_decadal, y=porp_change, 
                                             ymin=ci.lower, ymax=ci.upper, color=n)) +
  geom_point(size=3.2) +
  geom_linerange(size=1.2) +
  facet_wrap(~type) +
  ylim(c(-0.7,1.5)) +
  xlab("Duration") + ylab("Porportion Change") +
  theme_bw(base_size=18) +
  geom_abline(slope=0, yintercept=0, lwd=1.5, lty=2) +
  scale_color_gradient(low="blue", high="red", name="Sample Size")

decadalPlot
