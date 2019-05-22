#-------------------------------------------------------------------------------
# Name:        NHA_TemplateGenerator.r
# Purpose:     Create a Word template for NHA content
# Author:      Anna Johnson
# Created:     2019-03-21
# Updated:     
#
# Updates:
# 
# To Do List/Future ideas:
#
#-------------------------------------------------------------------------------

# check and load required libraries  
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

# load in the paths and settings file
source(here("scripts", "0_PathsAndSettings.r"))

# open the NHA feature class and select and NHA
nha <- arc.open(here::here("_data", "NHA_newTemplate.gdb","NHA_Core"))
selected_nha <- arc.select(nha, where_clause="SITE_NAME='Town Hill Barren'")
nha_siteName <- selected_nha$SITE_NAME
nha_filename <- gsub(" ", "", nha_siteName, fixed=TRUE)

## Build the Species Table #########################

# open the related species table and get the rows that match the NHA join id from above
nha_relatedSpecies <- arc.open(here("_data", "NHA_newTemplate.gdb","NHA_SpeciesTable"))
selected_nha_relatedSpecies <- arc.select(nha_relatedSpecies) # , where_clause=paste("\"NHD_JOIN_ID\"","=",sQuote(selected_nha$NHA_JOIN_ID),sep=" ")  
selected_nha_relatedSpecies <- selected_nha_relatedSpecies[which(selected_nha_relatedSpecies$NHA_JOIN_ID==selected_nha$NHA_JOIN_ID),] #! consider integrating with the previous line the select statement

SD_speciesTable <- selected_nha_relatedSpecies[c("EO_ID","ELCODE","SNAME","SCOMNAME","ELEMENT_TYPE","G_RANK","S_RANK","S_PROTECTI","PBSSTATUS","LAST_OBS_D","BASIC_EO_R")] # subset to columns that are needed.

eoid_list <- paste(toString(SD_speciesTable$EO_ID), collapse = ",")  # make a list of EOIDs to get data from
ELCODE_list <- paste(toString(sQuote(unique(SD_speciesTable$ELCODE))), collapse = ",")  # make a list of EOIDs to get data from

ptreps <- arc.open(paste(biotics_gdb,"eo_ptreps",sep="/"))
ptreps_selected <- arc.select(ptreps, fields=c("EO_ID", "SNAME", "EO_DATA", "GEN_DESC","MGMT_COM","GENERL_COM"), where_clause=paste("EO_ID IN (", eoid_list, ")",sep="") )

#generate URLs for each EO at site
URL_EOs <- sapply(seq_along(ptreps_selected$EO_ID), function(x)  paste("https://bioticspa.natureserve.org/biotics/services/page/Eo/",ptreps_selected$EO_ID[x],".html", sep=""))

URL_EOs <- sapply(seq_along(URL_EOs), function(x) paste("(",URL_EOs[x],")", sep=""))
Sname_link <- sapply(seq_along(ptreps_selected$SNAME), function(x) paste("[",ptreps_selected$SNAME[x],"]", sep=""))
Links <- paste(Sname_link, URL_EOs, sep="") 

#Connect to threats and recommendations SQLite database, pull in data
databasename <- "nha_recs.sqlite" 
databasename <- here("_data","databases",databasename)

TRdb <- dbConnect(SQLite(), dbname=databasename) #connect to SQLite DB
#src_dbi(TRdb) #check structure of database

# trying this Chris' way because its awesomer....
ElementTR <- dbGetQuery(TRdb, paste0("SELECT * FROM ElementThreatRecs"," WHERE ELCODE IN (", paste(toString(sQuote(SD_speciesTable$ELCODE)), collapse = ", "), ");"))

ThreatRecTable  <- dbGetQuery(TRdb, paste0("SELECT * FROM ThreatRecTable"," WHERE ID IN (", paste(toString(sQuote(ElementTR$ID)), collapse = ", "), ");"))
#ElementTR <- tbl(TRdb, "ElementThreatRecs")
#ThreatRecTable <- tbl(TRdb, "ThreatRecTable")

#join general threats/recs table with the element table 
ELCODE_TR <- ElementTR %>%
  inner_join(ThreatRecTable)


NHAdest1 <- paste(NHAdest,"DraftSiteAccounts",nha_filename,sep="/")
dir.create(NHAdest1, showWarnings = F) # make a folder for each site
dir.create(paste(NHAdest1,"photos", sep="/"), showWarnings = F) # make a folder for each site

######### Write the output document for the site ###############
rmarkdown::render(input=here("scripts","template_NHAREport_part1v2.Rmd"), output_format="word_document", 
                  output_file=paste(nha_filename,"_",gsub("[^0-9]", "", Sys.Date() ),".docx",sep=""),
                  output_dir=NHAdest1)

