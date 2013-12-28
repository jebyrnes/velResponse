Code for Re-Analysis of Vellend et al. 2013 PNAS
============================================

Code that accompanies Gonzalez et al.'s re-analysis of Vellend et al. 2013.  All files are setup using knitr tags so that they can easily be incorporated into markdown documents. At the head of each file, it loads other files it depends upon so that one can only concentrate working on the piece of the re-analysis they are interested in.

*Files*

velLoad.R: loads data, assuming that one has downloaded the supplementary excel file from [the original paper](http://dx.doi.org/10.1073/pnas.1312779110)

velModel.R: fits mixed models from the Vellend et al. 2013 paper using lme4 and our re-analysis using effect without duration as a response and log(Duration) as a predictor

velPlots.R: runs the fit models, then plots the resulting data and fit fixed effect relationships in different ways that are useful to the reader.

velProblems.R: Looks at the residuals and leverage of points from the Vellend et al. model to show the de-leveraging of long-term studies (or conversely, increased leveraging of short-term studies) and the pathological behavior of the Vellend et al. model with respect to Duration.

velPower.R: Power analyses of simulation showing the effects of looking at a regression relationship versus an effect divided by a predictor and how the distribution of said predictor can affect power. Also looks at power by resampling from the Vellend et al. data and comparing the power of both models to detect a non-zero rate of change. 

*Last Updated:* Dec 28, 2013