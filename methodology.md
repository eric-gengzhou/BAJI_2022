# Methodology for the EOIR data analysis

### About

This is a brief summary of the how the analysis is conducted by steps using the EOIR data and is based on the previous [methodology file](https://github.com/fordb/2015-08-immigrant-detention/blob/master/methodology.md).

### Steps

1. **Load all `schedule` entries corresponding to an immigrant’s first court proceeding.** This dataset contains the `adj_date` variable that we will use later to determine the timeframe. Then keep a list of `case-id` whose first appearence fall between year 2015-2021, and merge other datasets to this list based on `case-id`.

2. **Load all `case` entries.** In the database, these rows contain basic information about a case, including: a unique identification number, the nationality of the immigrant, whether the immigrant was detained, when an attorney first appeared before the court, and the type of proceeding.

3. **Load all `charges` entries.** A given immigration case can have multiple proceedings (stemming from different grounds for removal), and a given proceeding can be associated with multiple charges. We group all the charges for an individual proceeding together into a single list.

4. **Combine all loaded data into one table, with one row per case.** Each row contains demographic details of the defendant and a full record of the first proceeding, including all the charges.

5. **Basic data cleaning**, inlcuding remove duplicated rows and rows with all blank, missing values. See the [R code](https://github.com/eric-gengzhou/BAJI_2022/blob/main/EOIR_request.R) for details.

6. **Output some stats**, for requests 1 - 14, the analysis will be straightforward and are essentially conditional means. The only note here is pay attention to do not confuse conditions with the target outputs.

7. **Adding in bond information**, requests 15 - 23 surround the bond information for these proceedings. One key aspect of this is how we calculated the bond amount for immigrant cases with multiple proceedings and hearings, please refer to the [R code](https://github.com/eric-gengzhou/BAJI_2022/blob/main/EOIR_request.R) line 156 - 195 for more information.

8. **Time in detention**, for the last request, we will calculate the time under detention for all the immigrant cases, which will require aggregating the detention period (calculated between the `detention date` and `release date`) for each proceedings that resulted in detention. Please refer to the [R code](https://github.com/eric-gengzhou/BAJI_2022/blob/main/EOIR_request.R) line 130 - 153 for more information.

9. **Check output**, at last the [R code](https://github.com/eric-gengzhou/BAJI_2022/blob/main/EOIR_request.R) will produce a csv output containing all the requests by each year between 2015 and 2021. Most of the numbers should vary by year -- please check to make sure the numbers make sense. Note that the years that indicate the timeframe simply identify the time an immigrant had their first scheduled hearing, which often marks the begining of the interaction between the immigrants and DOJ court system.

