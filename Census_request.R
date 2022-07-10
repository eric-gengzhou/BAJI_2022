library(tidycensus)
library(tidyverse)
library(censusapi)
library(acs)

api.key.install("enter.your.key.here")


#2015 stats

vars <- load_variables(2015, "acs5", cache = T)

#i.	Percent of Black immigrants within the national Black population 
total_blk_2015 <- get_acs(geography = "us", variables = "B02009_001", year = 2015) #total black population
total_foreign_blk_2015 <- get_acs(geography = "us", variables = "B06004B_005", year = 2015) #total foreign born black & african alone

moe_adjust <- (1.96/1.645)

total_blk_2015_lowci <- total_blk_2015$estimate - moe_adjust*total_blk_2015$moe
total_blk_2015_highci <- total_blk_2015$estimate + moe_adjust*total_blk_2015$moe

total_foreign_blk_2015_lowci <- total_foreign_blk_2015$estimate - moe_adjust*total_foreign_blk_2015$moe
total_foreign_blk_2015_highci <- total_foreign_blk_2015$estimate + moe_adjust*total_foreign_blk_2015$moe

paste0("Percent of Black immigrants within the national Black population is ", round(100*total_foreign_blk_2015$estimate/total_blk_2015$estimate,3), "%.")
paste0("The 95% confidence interval of this value is (", round(100*total_foreign_blk_2015_lowci/total_blk_2015_highci,3), "% - ",
       round(100*total_foreign_blk_2015_highci/total_blk_2015_lowci,3), "%)")

#ii. Total foreign-born population
total_foreign_2015 <- get_acs(geography = "us", variables = "B05002_013", year = 2015) #total foreign born population
paste0("Total foreign-born population is ", round(total_foreign_2015$estimate/1000000,3), " million.") 

#ii.1. Percent of this population that is Black 
paste0("Percent of this population that is Black is ", round(100*total_foreign_blk_2015$estimate/total_foreign_2015$estimate,3), "%.")
paste0("The 95% confidence interval of this value is (", round(100*total_foreign_blk_2015_lowci/(total_foreign_2015$estimate + moe_adjust*total_foreign_2015$moe),3), "% - ",
       round(100*total_foreign_blk_2015_highci/(total_foreign_2015$estimate - moe_adjust*total_foreign_2015$moe),3), "%)")


#ii.2. Number and percent of this population that are non-citizens 
non_citi_foreign <- get_acs(geography = "us", variables = "B05002_021", year = 2015)
print(non_citi_foreign$estimate/1000000)
per_non_citi <- round(100*non_citi_foreign$estimate/total_foreign_2015$estimate,2)
print(per_non_citi)

#ii.2.a. Number and percent of the non-citizen population that is Black
immi_blk_sex_citizen <- get_acs(geography = "us", variables = c("B05003B_007","B05003B_012","B05003B_018","B05003B_023"), year = 2015)

paste0("Number of the non-citizen population that is Black ", round(colSums(immi_blk_sex_citizen[,4])/1000000,3), " million.")

total_noncitizen <- get_acs(geography = "us", variables = c("B05001_006"), year = 2015)

paste0("Percent of the non-citizen population that is Black  ", round(100*colSums(immi_blk_sex_citizen[,4])/total_noncitizen$estimate,3), "%.")


#iii.	Totals and percents of Black immigrants residing in the following states/regions 

states <- c("New York", "Florida", "Maryland", "Texas", "District of Columbia", "Virginia",
            "Minnesota", "Georgia","California","New Jersey","North Dakota","South Dakota",
            "Massachusetts","Pennsylvania","Ohio","Connecticut","Wisconsin")

total_foreign_blk_2015 <- get_acs(geography = "state", variables = "B06004B_005", year = 2015) #total foreign born black & African alone by state
total_foreign_2015 <- get_acs(geography = "state", variables = "B05002_013", year = 2015) #total foreign born population
total_pop_2015 <- get_acs(geography = "state", variables = "B01003_001", year = 2015)


foreign_blk_2015_st <- total_foreign_blk_2015[total_foreign_blk_2015$NAME %in% states,] #total foreign born black & African alone in these states
foreign_blk_2015_st$blk_per_st <- round(100*foreign_blk_2015_st$estimate/colSums(foreign_blk_2015_st[,4]),3) #% of foreign born black & African alone in these states

write_csv(foreign_blk_2015_st, file = "/foreign_blk_2015_st.csv")

#iv.	Total of Black immigrants by country of origin 

     #iv.1.	Combined total of immigrants from African and Caribbean countries
total_immi_africa <- get_acs(geography = "us", variables = "B05006_091", year = 2015) #African total

print(total_immi_africa$estimate/1000000)

total_immi_carib <- get_acs(geography = "us", variables = "B05006_125", year = 2015) # Caribbean total

print(total_immi_carib$estimate/1000000)

paste0("Combined total of immigrants from African and Caribbean countries is ", 
       round((total_immi_africa$estimate + total_immi_carib$estimate)/1000000, 2), " million.")

    #iv.2.	Total and percent immigrants from all African countries
#note: all the African countries are from table B05006_92 to B05006_116 consecutively, will run a loop to extract them all

total_pop_african_ct <- matrix(0, 25, 4)
colnames(total_pop_african_ct) <- c("country name", "total_pop", "pop_moe", "pop_per")

for (i in 92:99) {
total_pop_african_ct[i-91, 1] <- substr(vars$label[vars$name == paste0("B05006_0",i)], 26, nchar(vars$label[vars$name == paste0("B05006_0",i)]))
data_temp <- get_acs(geography = "us", variables = paste0("B05006_0",i), year = 2015)
total_pop_african_ct[i-91, 2] <- data_temp$estimate
total_pop_african_ct[i-91, 3] <- data_temp$moe
}

for (i in 100:116) {
  total_pop_african_ct[i-91, 1] <- substr(vars$label[vars$name == paste0("B05006_",i)], 26, nchar(vars$label[vars$name == paste0("B05006_",i)]))
  data_temp <- get_acs(geography = "us", variables = paste0("B05006_",i), year = 2015)
  total_pop_african_ct[i-91, 2] <- data_temp$estimate
  total_pop_african_ct[i-91, 3] <- data_temp$moe
}

select <- c(1,7,10,18,15) #remove aggregated stats
total_pop_african_ct_only <- total_pop_african_ct[-select,]
total_pop_african_ct_only  <- as.data.frame(total_pop_african_ct_only)
total_pop_african_ct_only[,2] <- as.numeric(total_pop_african_ct_only[,2])
total_pop_african_ct_only$pop_per <- round(100*total_pop_african_ct_only[,2]/sum(total_pop_african_ct_only$total_pop),2)
total_pop_african_ct_only$`country name` <- sub(".*Africa!!","",total_pop_african_ct_only$`country name`)
total_pop_african_ct_only <- total_pop_african_ct_only[order(total_pop_african_ct_only$pop_per, decreasing = T),]

write_csv(total_pop_african_ct_only , file = "/total_pop_african_ct_only.csv")

    #iv.3. Total and percent immigrants from all Caribbean countries
#note: all the Caribbean countries are from table B05006_126 to B05006_137 consecutively, will run a loop to extract them all

total_pop_carib_ct <- matrix(0, 12, 4)
colnames(total_pop_carib_ct ) <- c("country name", "total_pop", "pop_moe", "pop_per")

for (i in 126:137) {
  total_pop_carib_ct [i-125, 1] <- substr(vars$label[vars$name == paste0("B05006_",i)], 26, nchar(vars$label[vars$name == paste0("B05006_",i)]))
  data_temp <- get_acs(geography = "us", variables = paste0("B05006_",i), year = 2015)
  total_pop_carib_ct [i-125, 2] <- data_temp$estimate
  total_pop_carib_ct [i-125, 3] <- data_temp$moe
}
total_pop_carib_ct <- as.data.frame(total_pop_carib_ct)
total_pop_carib_ct[,2] <- as.numeric(total_pop_carib_ct[,2])
total_pop_carib_ct$pop_per <- round(100*total_pop_carib_ct[,2]/sum(total_pop_carib_ct$total_pop),2)
total_pop_carib_ct$`country name` <- sub(".*Caribbean!!","",total_pop_carib_ct$`country name`)
total_pop_carib_ct <- total_pop_carib_ct[order(total_pop_carib_ct$pop_per, decreasing = T),]

write_csv(total_pop_carib_ct, file = "/Users/Captaincena/Downloads/total_pop_carib_ct.csv")

   #iv.4.	Percent of total immigrants from these countries

region_name <- cbind(c("B05006_091", "B05006_125", "B05006_148", "B05006_138", "B05006_002", "B05006_047"),
                     c("Africa","Caribbean","South America","Central America","Europe","Asia"))

total_per_these_ct <- get_acs(geography = "us", variables = c("B05006_091", "B05006_125", "B05006_148", "B05006_138","B05006_002", "B05006_047"), year = 2015)
total_per_these_ct <- merge(total_per_these_ct, region_name, by.x = "variable", by.y = "V1", all.x = T)

total_per_these_ct <- total_per_these_ct[,4:6]
colnames(total_per_these_ct) <- c("total_pop","moe","region")
total_per_these_ct$pop_per <- round(100*total_per_these_ct$total_pop/sum(total_per_these_ct$total_pop),2)

total_per_these_ct <- total_per_these_ct[order(total_per_these_ct$pop_per, decreasing = T),]

write_csv(total_per_these_ct, file = "/Users/Captaincena/Downloads/total_per_these_ct.csv")

#V. Citizenship
    #V. 1 & 2.	Total and percent of foreign-born Black immigrants that are naturalized citizens

carb_natural <- get_acs(geography = "us", variables = c("B05007_043", "B05007_046",
                                                        "B05007_049","B05007_052"), year = 2015)  #Caribbean naturalized

south_natural <- get_acs(geography = "us", variables = c("B05007_083", "B05007_086", 
                                                        "B05007_089", "B05007_092"), year = 2015) #South american naturalized

#note: unable to discern the number of black/african immigrant from south america due to data availability


africa_natural <- get_acs(geography = "us", variables = "B05002_017", year = 2015) #Naturalized citizen africa

csa_total <- c(sum(carb_natural$estimate), sum(south_natural$estimate), africa_natural$estimate)
csa_total <- cbind(csa_total, c("Caribbean","South american", "Africa"))
csa_total <- as.data.frame(csa_total)
csa_total$csa_total <- as.numeric(csa_total$csa_total)
colnames(csa_total) <- c("total_pop","region")
csa_total$pop_per <- round(100*csa_total$total_pop/sum(csa_total$total_pop),2)

write_csv(csa_total, file = "/Users/Captaincena/Downloads/csa_total.csv")

     #V. 3-4 unable to get information due to data availability

# vi.	Education


educ_25up <- get_acs(geography = "us", variables = c("B06009_025", "B06009_029", "B06009_030"), year = 2015)
educ_25up$estimate <- as.numeric(educ_25up$estimate)
educ_25up$per <- round(100*educ_25up[,4]/35988678, 2)



#2019 results for the same stats above

vars <- load_variables(2019, "acs5", cache = T)

#i.	Percent of Black immigrants within the national Black population 
total_blk_2019 <- get_acs(geography = "us", variables = "B02001_003", year = 2019) #total black population
total_foreign_blk_2019 <- get_acs(geography = "us", variables = "B06004B_005", year = 2019) #total foreign born black & african alone

moe_adjust <- (1.96/1.645)

total_blk_2019_lowci <- total_blk_2019$estimate - moe_adjust*total_blk_2019$moe
total_blk_2019_highci <- total_blk_2019$estimate + moe_adjust*total_blk_2019$moe

total_foreign_blk_2019_lowci <- total_foreign_blk_2019$estimate - moe_adjust*total_foreign_blk_2019$moe
total_foreign_blk_2019_highci <- total_foreign_blk_2019$estimate + moe_adjust*total_foreign_blk_2019$moe

paste0("Percent of Black immigrants within the national Black population is ", round(100*total_foreign_blk_2019$estimate/total_blk_2019$estimate,3), "%.")
paste0("The 95% confidence interval of this value is (", round(100*total_foreign_blk_2019_lowci/total_blk_2019_highci,3), "% - ",
       round(100*total_foreign_blk_2019_highci/total_blk_2019_lowci,3), "%)")


#ii. Total foreign-born population
total_foreign_2019 <- get_acs(geography = "us", variables = "B05002_013", year = 2019) #total foreign born population
paste0("Total foreign-born population is ", round(total_foreign_2019$estimate/1000000,3), " million.") 

#ii.1. Percent of this population that is Black 
paste0("Percent of this population that is Black is ", round(100*total_foreign_blk_2019$estimate/total_foreign_2019$estimate,3), "%.")
paste0("The 95% confidence interval of this value is (", round(100*total_foreign_blk_2019_lowci/(total_foreign_2019$estimate + moe_adjust*total_foreign_2019$moe),3), "% - ",
       round(100*total_foreign_blk_2019_highci/(total_foreign_2019$estimate - moe_adjust*total_foreign_2019$moe),3), "%)")


#ii.2. Number and percent of this population that are non-citizens 
total_noncitizen <- get_acs(geography = "us", variables = c("B05001_006"), year = 2019)
print(round(total_noncitizen$estimate/1000000,2))
print(round(100*total_noncitizen$estimate/total_foreign_2019$estimate,2))

#ii.2.a. Number and percent of the non-citizen population that is Black
immi_blk_sex_citizen <- get_acs(geography = "us", variables = c("B05003B_007","B05003B_012","B05003B_018","B05003B_023"), year = 2019)

paste0("Number of the non-citizen population that is Black ", round(colSums(immi_blk_sex_citizen[,4])/1000000,2), " million.")


paste0("Percent of the non-citizen population that is Black  ", round(100*colSums(immi_blk_sex_citizen[,4])/total_noncitizen$estimate,2), "%.")


#iii.	Totals and percents of Black immigrants residing in the following states/regions 

states <- c("New York", "Florida", "Maryland", "Texas", "District of Columbia", "Virginia",
            "Minnesota", "Georgia","California","New Jersey","North Dakota","South Dakota",
            "Massachusetts","Pennsylvania","Ohio","Connecticut","Wisconsin")

total_foreign_blk_2019 <- get_acs(geography = "state", variables = "B06004B_005", year = 2019) #total foreign born black & African alone by state
total_foreign_2019 <- get_acs(geography = "state", variables = "B05002_013", year = 2019) #total foreign born population
total_pop_2019 <- get_acs(geography = "state", variables = "B01003_001", year = 2019)


foreign_blk_2019_st <- total_foreign_blk_2019[total_foreign_blk_2019$NAME %in% states,] #total foreign born black & African alone in these states
foreign_blk_2019_st$blk_per_st <- round(100*foreign_blk_2019_st$estimate/colSums(foreign_blk_2019_st[,4]),3) #% of foreign born black & African alone in these states

write_csv(foreign_blk_2019_st, file = "/foreign_blk_2019_st.csv")

#iv.	Total of Black immigrants by country of origin 

#iv.1.	Combined total of immigrants from African and Caribbean countries
total_immi_africa <- get_acs(geography = "us", variables = "B05006_091", year = 2019) #African total

print(round(total_immi_africa$estimate/1000000,2))

total_immi_carib <- get_acs(geography = "us", variables = "B05006_131", year = 2019) # Caribbean total

print(round(total_immi_carib$estimate/1000000,2))

paste0("Combined total of immigrants from African and Caribbean countries is ", 
       round((total_immi_africa$estimate + total_immi_carib$estimate)/1000000, 2), " million.")

#iv.2.	Total and percent immigrants from all African countries
#note: all the African countries are from table B05006_92 to B05006_121 consecutively, will run a loop to extract them all

total_pop_african_ct <- matrix(0, 30, 4)
colnames(total_pop_african_ct) <- c("country name", "total_pop", "pop_moe", "pop_per")

for (i in 92:99) {
  total_pop_african_ct[i-91, 1] <- substr(vars$label[vars$name == paste0("B05006_0",i)], 26, nchar(vars$label[vars$name == paste0("B05006_0",i)]))
  data_temp <- get_acs(geography = "us", variables = paste0("B05006_0",i), year = 2019)
  total_pop_african_ct[i-91, 2] <- data_temp$estimate
  total_pop_african_ct[i-91, 3] <- data_temp$moe
}

for (i in 100:121) {
  total_pop_african_ct[i-91, 1] <- substr(vars$label[vars$name == paste0("B05006_",i)], 26, nchar(vars$label[vars$name == paste0("B05006_",i)]))
  data_temp <- get_acs(geography = "us", variables = paste0("B05006_",i), year = 2019)
  total_pop_african_ct[i-91, 2] <- data_temp$estimate
  total_pop_african_ct[i-91, 3] <- data_temp$moe
}

select <- c(1,9,14,19,22) #remove aggregated stats
total_pop_african_ct_only <- total_pop_african_ct[-select,]
total_pop_african_ct_only  <- as.data.frame(total_pop_african_ct_only)
total_pop_african_ct_only[,2] <- as.numeric(total_pop_african_ct_only[,2])
total_pop_african_ct_only$pop_per <- round(100*total_pop_african_ct_only[,2]/sum(total_pop_african_ct_only$total_pop),2)
total_pop_african_ct_only$`country name` <- sub(".*Africa:!!","",total_pop_african_ct_only$`country name`)
total_pop_african_ct_only <- total_pop_african_ct_only[order(total_pop_african_ct_only$pop_per, decreasing = T),]

write_csv(total_pop_african_ct_only, file = "/total_pop_african_ct_only.csv")

#iv.3. Total and percent immigrants from all Caribbean countries
#note: all the Caribbean countries are from table B05006_132 to B05006_143 consecutively, will run a loop to extract them all

total_pop_carib_ct <- matrix(0, 12, 4)
colnames(total_pop_carib_ct ) <- c("country name", "total_pop", "pop_moe", "pop_per")

for (i in 132:143) {
  total_pop_carib_ct [i-131, 1] <- substr(vars$label[vars$name == paste0("B05006_",i)], 26, nchar(vars$label[vars$name == paste0("B05006_",i)]))
  data_temp <- get_acs(geography = "us", variables = paste0("B05006_",i), year = 2019)
  total_pop_carib_ct [i-131, 2] <- data_temp$estimate
  total_pop_carib_ct [i-131, 3] <- data_temp$moe
}
total_pop_carib_ct <- as.data.frame(total_pop_carib_ct)
total_pop_carib_ct[,2] <- as.numeric(total_pop_carib_ct[,2])
total_pop_carib_ct$pop_per <- round(100*total_pop_carib_ct[,2]/sum(total_pop_carib_ct$total_pop),2)
total_pop_carib_ct$`country name` <- sub(".*Caribbean:!!","",total_pop_carib_ct$`country name`)
total_pop_carib_ct <- total_pop_carib_ct[order(total_pop_carib_ct$pop_per, decreasing = T),]

write_csv(total_pop_carib_ct, file = "/total_pop_carib_ct.csv")

#iv.4.	Percent of total immigrants from these countries

region_name <- cbind(c("B05006_091", "B05006_131", "B05006_154", "B05006_144","B05006_002", "B05006_047"),
                     c("Africa","Caribbean","South America","Central America","Europe","Asia"))

total_per_these_ct <- get_acs(geography = "us", variables = c("B05006_091", "B05006_131", "B05006_154", "B05006_144","B05006_002", "B05006_047")
                              , year = 2019)
total_per_these_ct <- merge(total_per_these_ct, region_name, by.x = "variable", by.y = "V1", all.x = T)

total_per_these_ct <- total_per_these_ct[,4:6]
colnames(total_per_these_ct) <- c("total_pop","moe","region")
total_per_these_ct$pop_per <- round(100*total_per_these_ct$total_pop/sum(total_per_these_ct$total_pop),2)

total_per_these_ct <- total_per_these_ct[order(total_per_these_ct$pop_per, decreasing = T),]

write_csv(total_per_these_ct, file = "/total_per_these_ct.csv")


#V. Citizenship
#V. 1 & 2.	Total and percent of foreign-born Black immigrants that are naturalized citizens

carb_natural <- get_acs(geography = "us", variables = c("B05007_043", "B05007_046",
                                                        "B05007_049","B05007_052"), year = 2019)  #Caribbean naturalized

south_natural <- get_acs(geography = "us", variables = c("B05007_083", "B05007_086", 
                                                         "B05007_089", "B05007_092"), year = 2019) #South american naturalized

#note: unable to discern the number of black/african immigrant from south america due to data availability


africa_natural <- get_acs(geography = "us", variables = "B05002_017", year = 2019) #Naturalized citizen africa

csa_total <- c(sum(carb_natural$estimate), sum(south_natural$estimate), africa_natural$estimate)
csa_total <- cbind(csa_total, c("Caribbean","South american", "Africa"))
csa_total <- as.data.frame(csa_total)
csa_total$csa_total <- as.numeric(csa_total$csa_total)
colnames(csa_total) <- c("total_pop","region")
csa_total$pop_per <- round(100*csa_total$total_pop/sum(csa_total$total_pop),2)
csa_total

#V. 3-4 unable to get information due to data availability

# vi.	Education


educ_25up <- get_acs(geography = "us", variables = c("B06009_025", "B06009_029", "B06009_030"), year = 2019)
educ_25up$estimate <- as.numeric(educ_25up$estimate)
educ_25up$per <- round(100*educ_25up[,4]/35988678, 2)
educ_25up
