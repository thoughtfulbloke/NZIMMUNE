library(dplyr)
library(tidyr)
library(lubridate)

if(!dir.exists("metadataed")){dir.create("metadataed")}

allthem <- list.files(path="singlesheets", pattern="csv")
process_sheet <- function(x){
  expath <- paste0("singlesheets/",x)
  thesheet <- read.csv(expath, colClasses = "character")
  ### names splits
  nameparts <- unlist(strsplit(x,split="_"))
  demog <- nameparts[2]
  age <- nameparts[3]
  linkdate <- nameparts[4]
  datebits <- trimws(unlist(strsplit(linkdate, " to ")))
  beginbit <- dmy(datebits[1])
  endbit <- dmy(datebits[2])
  datadays <- as.numeric(difftime(endbit, beginbit,"days"))
  QuaterOrAnnual = "Unknown"
  if (datadays %in% 85:95){
    QuaterOrAnnual = "Quarter"
  }
  if (datadays %in% 360:370){
    QuaterOrAnnual = "Annual"
  }
  StartYear = year(beginbit)
  StartQuarter = ceiling(month(beginbit)/3)
  ageworking = gsub("5 year", "60 month",tolower(age))
  monthsold = gsub(" mont.*","",ageworking)
  thesheet$demog <- demog
  thesheet$age <- age
  thesheet$linkdate <- linkdate
  thesheet$beginbit <- beginbit
  thesheet$endbit <- endbit
  thesheet$QuaterOrAnnual <- QuaterOrAnnual
  thesheet$StartYear <- StartYear
  thesheet$StartQuarter <- StartQuarter
  thesheet$monthsOld <- monthsold
  exportpath <- paste("metadataed/F",demog,age,linkdate,".csv", sep="_")
  write.csv(thesheet, file = exportpath, row.names=FALSE)
  return(NULL)
}     

manymany <- lapply(allthem, process_sheet)