# NZIMMUNE

Reprocessing Childhood immunisation data to machine readable

Output files columns:

"demographic_group" - The top heading from the original file

"measure" - eligible, fully vaccinated, percentage (proportion after converting from Excel)

"amount" - the value in the box n/s is a supress less than 10 value

"demog" - used when processing, was it Deprivation and Ethnicity

"age" - Age (converted 5 years to 60 months to make it easier to match same cohort to future quarters

"linkdate" - the text date on the link to original file on the webpage for debugging purposes

"beginbit" - start of sheet data period in ymd format

"endbit" - end of sheet data period in ymd format

"QuaterOrAnnual" - Quarter or Annual indicator for selecting data for partiular purposes

"StartYear" - Year at begining of data period

"StartQuarter" - Quarter at begining of data period

"monthsOld" - The numeric value (months) from the age column

"Canoncial_DHB" - DHB from combination of different columns

"Canonical_region" - recent values also include region as a supercollection of DHBs
