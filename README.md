# BAJI_2022
Data analysis requests from BAJI &amp; IRC, NYU Law School

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
* Bond table (`d_tblAssociatedBond`): a data table on 

