##########################
# Code to use the Leaflet library from
# Rstudio to make an interactive map of
# where the Vellend et al. 2013 sites are
# And visualize them on an ESRI satellite map
#
# by Jarrett Byrnes
##########################

library(leaflet) #See http://rstudio.github.io/leaflet/
library(RColorBrewer)
library(classInt)
source("./velLoad.R")

#colors
palB <- brewer.pal(11, "Spectral")
pal <- colorRampPalette(palB)
ncol <- 100
vel$colors <- findColours(classIntervals(vel$effect, ncol, style="quantile"), pal(ncol))

#make a base leaflet map
#mapquest satellite imagery
#ESRI - http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}
#OpenMaps - http://otile1.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg
velLeaf <- leaflet() %>% addTiles(urlTemplate="http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}")

#Make some info for popups
vel$popup <- with(vel, paste0("Log(SR2/SR1)/Duration: ", round(effect,3), "<br>Duration: ", Duration, 
                             " years<br>Start: ", Year1_min, "<br>End: ", 
                             Year2_max, "<br>Driver: ", Driver))

#Make a leaflet map
velLeaf %>% addCircleMarkers(data=vel,
                       lat = ~ Latitude, lng = ~ Longitude, popup = ~popup,
                        radius=~Duration/7, color=~colors, fill=~colors)