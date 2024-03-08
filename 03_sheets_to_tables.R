library(dplyr)
library(tidyr)
library(zoo)
library(janitor)

if(!dir.exists("singlesheets")){dir.create("singlesheets")}

allthem <- list.files(path="csvsheets", pattern="csv")
process_sheet <- function(x){
  expath <- paste0("csvsheets/",x)
  thesheet <- read.csv(expath, colClasses = "character", 
                       header = FALSE)
  # because there are some, but not all, that have a
  # blank row between the top table and headings
  #
  blankrows <- apply(thesheet[1:20,], MARGIN = 1, 
                     function(x){sum(is.na(x))==length(x)})
  zap <- unname(which(blankrows))
  if(length(zap) > 0){
  thesheet <- thesheet |> 
    slice(-1*zap)
  }
  ## find the fully blank rows after the tables
  ## and pick the ranges with at least 18 non blank rows above
  blankrows <- apply(thesheet, MARGIN = 1, 
                     function(x){sum(is.na(x))==length(x)})
  rleblanks <- rle(blankrows)
  rleb <- data.frame(lengths = rleblanks$lengths,
                     values = rleblanks$values)
  rleb$endpoint <- cumsum(rleb$lengths)
  rleb$startpoint <- rleb$endpoint - rleb$lengths + 1
  rleb <- rleb[rleb$values == FALSE & rleb$lengths > 18,]
  ###
  # process each table
  for (i in 1:nrow(rleb)){
    datachunk <- thesheet[rleb$startpoint[i]:rleb$endpoint[i],]
    nameparts <- strsplit(x,split="_")
    # a two table sheet the age is in the name
    # and the top sheet is ethnicity
    if(i == 1 & nrow(rleb) == 2){
      demog = "Ethnicity"
      age = nameparts[[1]][1]
      date = nameparts[[1]][2]
      date = gsub("\\.csv","", date)
    }
    # a two table sheet the age is in the name
    # and the bottom sheet is Deprivation
    if(i == 2 & nrow(rleb) == 2){
      demog = "Deprivation"
      age = nameparts[[1]][1]
      date = nameparts[[1]][2]
      date = gsub("\\.csv","", date)
    }
    # one big sheet the demographic is in the sheet name
    if(i == 1 & nrow(rleb) == 1){
      demog = nameparts[[1]][1]
      age = "All"
      date = nameparts[[1]][2]
      date = gsub("\\.csv","", date)
    }
    # some sheets have extra blank columns to the right,
    # so finding any and only keeping to the left
    # assume fewer than 4 rows of content is unwanted
    blankcols <- unname(apply(datachunk, MARGIN = 2, 
                              function(x){sum(!is.na(x)) < 4}))
    cutpoint <- which(blankcols)
    # at least 6 columns in
    cutpoint <- cutpoint[cutpoint > 6]
    if (length(cutpoint) > 0){
      topoint = min(cutpoint)-1
      datachunk <- datachunk[,1:topoint]
    }
    # though preserving data as text, find the (1st) column
    # with the most potential numbers in it
    # to use the two rows above as headings.
    #also adjust commas in numerics
    numpercol <- apply(datachunk, MARGIN = 2,
                       function(x){sum(!is.na(as.numeric(gsub(",","",x))))})
    numbcol <- names((numpercol[numpercol == max(numpercol)])[1])
    madenum <- as.numeric(gsub(",","",unlist(datachunk[numbcol])))
    datatop <- min(which(!is.na(madenum)))
    # repeat headings to right and combine both heading rows
    h1 <- unname(unlist(datachunk[datatop-2,]))
    if(is.na(h1[1])){h1[1] <- ""}
    h1 <- na.locf(h1)
    h2 <- unname(unlist(datachunk[datatop-1,]))
    if(is.na(h2[1])){h2[1] <- ""}
    h2 <- na.locf(h2)
    newheadings <- make_clean_names(paste(h1,h2,sep="xxx"))
    names(datachunk) <- newheadings
    # now chop data to just start of numbers to end
    datachunk <- datachunk[datatop:nrow(datachunk),]
    #where do numbers start 
    tabularstart <- min(unname(which(numpercol > 0)))
    tabularend <- ncol(datachunk)
    for(j in 1:(tabularstart-1)){
      datachunk <- datachunk |> fill(j)
    }
    longform <- gather(datachunk,key="measure", value="amount", all_of(tabularstart:tabularend))
    exportpath <- paste("singlesheets/F",demog,age,date,".csv", sep="_")
    write.csv(longform, file = exportpath, row.names=FALSE)
  }
  return(data.frame(filename=x, tables=nrow(rleb)))
}

things <- lapply(allthem, process_sheet)

