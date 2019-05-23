#-------------------------------------------------------------------------------
# Name:        0_PathsAndSettings.r
# Purpose:     settings and paths for the NHA report creation tool.
# Author:      Christopher Tracey
# Created:     2019-03-21
# Updated:     2019-05-22
#
# Updates:
# 
# To Do List/Future ideas:
#
#-------------------------------------------------------------------------------


# options
options(useFancyQuotes = FALSE)

# load the arcgis license
arc.check_product() 

## Biotics Geodatabase
biotics_gdb <- "W:/Heritage/Heritage_Data/Biotics_datasets.gdb"

# NHA Databases and such
NHA_path <- "P:/Conservation Programs/Natural Heritage Program/ConservationPlanning/NHA_ToolsV3"

# threat recc database name
databasename <- here::here("_data","databases","nha_recs.sqlite")

# custom albers projection
customalbers <- "+proj=aea +lat_1=40 +lat_2=42 +lat_0=39 +lon_0=-78 +x_0=0 +y_0=0 +ellps=GRS80 +units=m +no_defs "

# NHA folders on the p-drive
NHAdest <- "P:/Conservation Programs/Natural Heritage Program/ConservationPlanning/NaturalHeritageAreas/_NHA"

# Packages required for full NHA writing procedure
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
require(here)
if (!requireNamespace("arcgisbinding", quietly = TRUE)) install.packages("arcgisbinding")
require(arcgisbinding)
if (!requireNamespace("RSQLite", quietly = TRUE)) install.packages("RSQLite")
require(RSQLite)
if (!requireNamespace("knitr", quietly = TRUE)) install.packages("knitr")
require(knitr)
if (!requireNamespace("xtable", quietly = TRUE)) install.packages("xtable")
require(xtable)
if (!requireNamespace("flextable", quietly = TRUE)) install.packages("flextable")
require(flextable)
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
require(dplyr)
if (!requireNamespace("dbplyr", quietly = TRUE)) install.packages("dbplyr")
require(dbplyr)
if (!requireNamespace("rmarkdown", quietly = TRUE)) install.packages("rmarkdown")
require(rmarkdown)
if (!requireNamespace("tmap", quietly = TRUE)) install.packages("tmap")
require(tmap)
if (!requireNamespace("OpenStreetMap", quietly = TRUE)) install.packages("OpenStreetMap")
require(OpenStreetMap)
if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
require(here)
if (!requireNamespace("readtext", quietly = TRUE)) install.packages("readtext")
require(readtext)
if (!requireNamespace("qdapRegex", quietly = TRUE)) install.packages("qdapRegex")
require(qdapRegex)
if (!requireNamespace("textreadr", quietly = TRUE)) install.packages("textreadr")
require(textreadr)

