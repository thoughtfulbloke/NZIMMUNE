library(readxl)
library(dplyr)
library(tidyr)

if(!dir.exists("csvsheets")){dir.create("csvsheets")}
  
wrongfileonserver <- "excels/1 January 2013 and 31 December 2013 (Excel, 2.2 MB).xlsx"
if(file.exists(wrongfileonserver)){
  file.remove(wrongfileonserver)
}

allthem <- list.files(path="excels", pattern="xls")
processexcel <- function(x){
  expath <- paste0("excels/",x)
  sheets <- excel_sheets(expath)
  output <- data.frame(sheets)
  output$filenames <- x
  return(output)
}
listEx <- lapply(allthem, processexcel)
dfEx <- bind_rows(listEx)
TotalSheets <- nrow(dfEx)
tablewidth <- function(x, sheetlist = dfEx){
  fileis=sheetlist$filenames[x]
  sheetis=sheetlist$sheets[x]
  sheetcontent=read_excel(path=paste0("excels/",fileis), col_names = FALSE,
                  sheet=sheetis)
  shortenedname <- gsub(" \\(.*","",fileis)
  shortenedname <- trimws(gsub("\\(.*","",fileis))
  shortenedname <- gsub(" \\.xls.*","",shortenedname)
  outputname=paste(sheetis,shortenedname,sep = "_")
  ouputpath = paste0("csvsheets/",outputname,".csv")
  write.csv(sheetcontent, file = ouputpath, col.names = FALSE, row.names = FALSE)
  return(NULL)
}
runthrough <- lapply(1:TotalSheets, tablewidth)



