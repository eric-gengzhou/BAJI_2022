# BAJI & IRC report update project 2022

## Intro:
This page hosts all the analytical documents of the data analysis pertaining to requests from the Immigrant Rights Clinic(IRC), NYU in 2022. The requests are based on two separate datasets and therefore the analytical documents (description and codes) are listed separately. The file `EOIR_request` and `Census_request` include detailed descriptions and the **R & Stata** codes that produced the results. The purposes of these documents is to offer descriptions of how each request was fullfilled analytically and allow for replicability with the original and identical data. 

## Data sources:
**Census data**: ACS-5 year estimate files and Microsample Public Use files of 2015 and 2019: https://data.census.gov/mdat/#/

**EOIR data**: Department of Justice publishes data on immigration court & cases: https://www.justice.gov/eoir/foia-library-0

## A brief and non-technical note on data-processing and methdology

**Census data**

This part of data requires minimum processing. However, to ensure granularity and the most accuracy estimates, we utilized both the original ACS Census data and the Public Use Microsample data. One key aspect is to apply the weight unit correctly when using the Microsample data (IPMUS). 

**EOIR data**

The EOIR database contains several separate datasets, which we need to combine to fullfill all the requests. Specifically, they are: 
* Case table (`A_tblCase`): a data table on the case_id (uniquely identify an immigrant to the US) level and also provides some demographic among other things of each immigrant in their entire database.
* Proceeding table (`A_tblProceeding`): a data table on the proceeding_id (uniquely identify each proceeding for the same or different cases/immigrants) level and also provides information on each proceeding such as violent crime indicator, detention duration, etc. 
* Bond table (`d_tblAssociatedBond`): a data table on the bond_id (uniquely identify each legal bond requested by the immigrant or their representative) and also provides information on the bond amount, number of bond requested, granted and updated amount. 
* Time table (`tbl_schedule`): a data table on the case_id-proceeding_id level that shows the time stamp of each proceeding, along with the time that these proceedings and charges filed and/or delivered (to these immigrants).

A complete inventory (subject to changes over time) of all variables and their residing data table can be found here: https://www.justice.gov/eoir/page/file/eoir-case-data-code-key/download

**The logic/steps of processing these datasets are simple:**

* data cleaning: for each data table mainly remove duplicated, blank, all mising data points
* deciding the timeframe: our analysis limits the data to 2015 - 2021 (based on the variable `adj_date` from the time table)
  * sort the time table by `IDNCASE`, `IDNPROCEEDING` and `ADJ_DATE` so that we capture the earliest `adj_date` for each immigrant. 
  * By this rule, if they fall into 2015-2015, we then merge these immigrants with other data tables
* selecting variables: variables can be put into two buckets, time-variant and time-invariant
  * time-invariant variables are demographic information such as nationality, race, ever detained, ever had criminal violations, etc.
  * time-variant variables are those that for each immigrant may vary across each year between 2015 - 2021, e.g., duration of detention, bond amount, etc.
  * there are several ways of dealing with time-variant variables, a common way is to look at the sum or average for each immigrant over time
* for the details of the each step described above, please refer to the **R & Stata** codes in this folder

