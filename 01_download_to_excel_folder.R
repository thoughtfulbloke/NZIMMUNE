library(rvest)
library(dplyr)

if(!dir.exists("excels")){dir.create("excels")}

targeturl <-  "https://www.tewhatuora.govt.nz/for-the-health-sector/vaccine-information/immunisation-coverage/"
page <- read_html(targeturl)
links <- page  |>  html_nodes("a") |> 
  html_attr("href")
linktxt <- page |> 
  rvest::html_nodes("a") |> 
  rvest::html_text()
linknos <- grep("xlsx", links)
excels <- links[linknos]
humantxt <- linktxt[linknos]
baseurl <- "https://www.tewhatuora.govt.nz"
targetfiles <- paste0(baseurl,excels)

locals <- paste0("excels/",humantxt, ".xlsx$")
for (i in 1:length(targetfiles)){
  download.file(url=targetfiles[i],
                destfile=locals[i],
                mode="wb")
}
####
linknos <- grep("xls$", links)
excels <- links[linknos]
humantxt <- linktxt[linknos]
baseurl <- "https://www.tewhatuora.govt.nz"
targetfiles <- paste0(baseurl,excels)

locals <- paste0("excels/",humantxt, ".xls")
for (i in 1:length(targetfiles)){
  download.file(url=targetfiles[i],
                destfile=locals[i],
                mode="wb")
}
