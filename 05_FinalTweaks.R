library(dplyr)
library(tidyr)
library(lubridate)

if(!dir.exists("finaldata")){dir.create("finaldata")}

allDeps <- list.files(path="metadataed", pattern="Deprivation")
allEth <- list.files(path="metadataed", pattern="Ethnicity")
process_sheet <- function(x){
  expath <- paste0("metadataed/",x)
  thesheet <- read.csv(expath, colClasses = "character")
  return(thesheet)
}     

DepList <- lapply(allDeps, process_sheet)
DepDf <- bind_rows(DepList)
# this is where we need to deal with changed in headings etc
# get the counts of NAs in each column
# to give me some guidance
blankcols <- apply(DepDf, MARGIN = 2, 
                   function(x){sum(is.na(x))})
blankcols[blankcols > 0]
DepDf[is.na(DepDf)] <- ""
DFDep <- DepDf |> 
  mutate(
    Canoncial_DHB = paste0(dhb_areaxxx, 
                           dhb_area_xxx,
                           decile_group_with_totalxxx_dhb_of_residence,
                           deprivation_decilexxx_dhb_of_residence, 
                           xxx_dhb_of_residence, 
                           deprivation_decilexxx_district_of_residence,
                           xxx_district_of_residence,
                           xxx_district)) |> 
  select(-dhb_areaxxx, 
         -dhb_area_xxx,
         -decile_group_with_totalxxx_dhb_of_residence,
         -deprivation_decilexxx_dhb_of_residence, 
         -xxx_dhb_of_residence, 
         -deprivation_decilexxx_district_of_residence,
         -xxx_district_of_residence,
         -xxx_district) |> 
  mutate(Canonical_milestone_ages = 
           paste0(xxx_milestone_age_for_ci,
                  xxx_milestone_age,
                  decile_group_with_totalxxx_milestone_age_for_ci),
         age = ifelse(age=="All",Canonical_milestone_ages,age),
         age = gsub("5 year", "60 month",tolower(age)),
         monthsOld = as.numeric(gsub(" mont.*","",age))) |> 
  select(-Canonical_milestone_ages,
         -xxx_milestone_age_for_ci,
         -xxx_milestone_age,
         -decile_group_with_totalxxx_milestone_age_for_ci) |> 
  mutate(Canonical_region = 
           paste0(deprivation_decilexxx_region,
                                   xxx_region)) |> 
  select(-deprivation_decilexxx_region, 
         -xxx_region) |> 
  mutate(amount = gsub(",","",amount)) |> 
  separate(measure,
           into=c("demographic_group","measure"), sep="xxx")
write.csv(DFDep[1:133999,], file = "finaldata/Deprivation01.csv", row.names = FALSE)  
write.csv(DFDep[134000:nrow(DFDep),], file = "finaldata/Deprivation02.csv", row.names = FALSE)  

### and Ethnicity
EthList <- lapply(allEth, process_sheet)
EthDf <- bind_rows(EthList)
# this is where we need to deal with changed in headings etc
# get the counts of NAs in each column
# to give me some guidance
blankcols <- apply(EthDf, MARGIN = 2, 
                   function(x){sum(is.na(x))})
blankcols[blankcols > 0]
EthDf[is.na(EthDf)] <- ""
DFEth <- EthDf |> 
  mutate(
    Canoncial_DHB = paste0(dhb_areaxxx,
                           dhb_area_xxx,
                           reporting_period_3_month_period_ending_march_2011xxx,
                           x1xxx_immunisation_coverage_at_milestone_age_6_months_of_age,
                           ethnicityxxx_dhb_of_residence,
                           xxx_dhb_of_residence,
                           xxx_dhb,
                           ethnicityxxx_district_of_residence,
                           xxx_district_of_residence
                          )) |> 
  select(-dhb_areaxxx,
         -dhb_area_xxx,
         -reporting_period_3_month_period_ending_march_2011xxx,
         -x1xxx_immunisation_coverage_at_milestone_age_6_months_of_age,
         -ethnicityxxx_dhb_of_residence,
         -xxx_dhb_of_residence,
         -xxx_dhb,
         -ethnicityxxx_district_of_residence,
         -xxx_district_of_residence) |> 
  mutate(Canonical_milestone_ages = paste0(xxx_milestone_age_for_ci,
                                           xxx_milestone_age,
                                           ethnicityxxx_milestone_age_for_ci),
         age = ifelse(age=="All",Canonical_milestone_ages,age),
         age = gsub("5 year", "60 month",tolower(age)),
         monthsOld = as.numeric(gsub(" mont.*","",age))) |> 
  select(-xxx_milestone_age_for_ci,
         -xxx_milestone_age,
         -ethnicityxxx_milestone_age_for_ci,
         -Canonical_milestone_ages) |> 
  mutate(Canonical_region = paste0(ethnicityxxx_region,
                                   xxx_region,
                                   xxx_district)) |> 
  select(-ethnicityxxx_region,
         -xxx_region,
         -xxx_district) |> 
  mutate(amount = gsub(",","",amount)) |> 
  separate(measure,
           into=c("demographic_group","measure"), sep="xxx")
write.csv(DFEth[1:133999,], file = "finaldata/Ethnicity01.csv", row.names = FALSE)  
write.csv(DFEth[134000:nrow(DFEth),], file = "finaldata/Ethnicity02.csv", row.names = FALSE)  



