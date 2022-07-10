
library(stringr)
library(doBy)

proc <- read.csv(" FOIA TRAC Report 20211201/B_TblProceeding.csv", sep = "\t", header = T, skipNul = T)

cases <- read.csv(" FOIA TRAC Report 20211201/A_TblCase.csv", sep = "\t", header = T, skipNul = T)

countries <- read.csv(" FOIA TRAC Report 20211201/Lookup/tblLookupCountry.csv", sep = "\t", header = T, skipNul = T)

time_tbl <- read.csv(" FOIA TRAC Report 20211201/tbl_schedule.csv", sep = "\t", header = T, skipNul = T)

time_tblshort <- time_tbl[,c("IDNPROCEEDING","IDNCASE","OSC_DATE","ADJ_DATE")]
time_tbl <- NULL

colnames(time_tblshort) <- tolower(colnames(time_tblshort))

time_tblshort$adj_date  <- substr(time_tblshort$adj_date, 1, 10)
time_tblshort$adj_date <- as.Date(time_tblshort$adj_date, format = "%Y-%m-%d")
time_tblshort$adj_year <- as.numeric(format(time_tblshort$adj_date, "%Y"))
table(is.na(time_tblshort$adj_year))
table(time_tblshort$adj_year)
nrow(time_tblshort[time_tblshort$adj_year>=2015 & time_tblshort$adj_year<=2021,])

time_tblshort$osc_date  <- substr(time_tblshort$osc_date , 1, 10)
time_tblshort$osc_date <- as.Date(time_tblshort$osc_date , format = "%Y-%m-%d")
time_tblshort$osc_year <- as.numeric(format(time_tblshort$osc_date, "%Y"))
table(time_tblshort$osc_year ==  time_tblshort$adj_year)


## keep only the years of data between 2015 and 2021
time_tbl_eoir <- subset(time_tblshort, adj_year >= 2015 & adj_year <= 2021)
time_tblshort <- NULL

time_tbl_eoir <- time_tbl_eoir[!duplicated(time_tbl_eoir),] #remove all fully duplicated cases
time_tbl_eoir <- time_tbl_eoir[order(time_tbl_eoir$idncase, time_tbl_eoir$idnproceeding),]
time_tbl_eoir <- time_tbl_eoir[!is.na(time_tbl_eoir$idnproceeding),] #remove missing rows


cases <- cases[!duplicated(cases$IDNCASE),] # remove rows with duplicate case ID number
colnames(cases) <- tolower(colnames(cases))

cases_columns <- c("idncase","nat","custody","case_type","gender","date_detained","date_released", "atty_nbr")
cases <- subset(cases, select = cases_columns)


#determine the race/ethnicity of these subjects 
countries <- countries[order(countries$strDescription),]
countries$strDescription <- str_to_title(countries$strDescription)
countries <- countries[,1:3]


#process the country data
africa_countries <- c(4,8,25,16,26,35,54,47,52,39,48,41,109,247,60,65,67,69,71,83,82,86,94,177,114,128,126,131,132,138,139,145,143,142,151,231,158,179,183,190,213,189,187,192,195,188,253,200,234,212,215,221,219,232,238,239)

caribbean_countries <- c(12,2,1,19,15,229,45,53,62,63,88,91,97,112,133,137,191,199,227,207,209)

blk_nat <-  c(4,8,25,16,26,35,54,47,52,39,48,41,109,247,60,65,67,69,71,83,82,86,94,177,114,128,126,131,132,138,139,145,143,142,151,231,158,179,183,190,213,189,187,192,195,188,253,200,234,212,215,221,219,232,238,239,12,2,1,19,15,229,45,53,62,63,88,91,97,112,133,137,191,199,227,207,209)

blk_nat_dat <- data.frame(blk_nat, rep(0, length(blk_nat)))
colnames(blk_nat_dat) <- c("country_id", "immi_type")
blk_nat_dat[1:56,2] <- rep(1,56)
blk_nat_dat[57:77,2] <- rep(2,21)

blk_nat_dat$immi_type <- as.factor(blk_nat_dat$immi_type)
levels(blk_nat_dat$immi_type) <- c("African","Caribbean")


#merge the country data to the case table
nat <- merge(blk_nat_dat, countries, by.x = "country_id", by.y = "idnCountry", all.y = T)
cases_nat <- merge(cases, nat, by.x = "nat", by.y = "strCode", all.x = T)
cases_nat <- cases_nat[!is.na(cases_nat$strDescription),]
cases_nat <- cases_nat[cases_nat$nat!="??",]
cases_nat <- cases_nat[!is.na(cases_nat$nat),]
colnames(cases_nat)[11]<-"country_name"

cases_nat$case_type <- as.factor(cases_nat$case_type)
cases_nat$custody <- as.factor(cases_nat$custody)
table(cases_nat$custody) #some are missing

#cases <- NULL

#cleaning the proceeding table 
colnames(proc) <-tolower(colnames(proc))

proc <- proc[order(proc$idnproceeding, proc$idncase),]

proc_keep <- c("idnproceeding","idncase","crim_ind")
proc <- subset(proc, select = proc_keep)

proc <- proc[proc$idnproceeding!= "",]
proc$crim_ind <- as.factor(proc$crim_ind)
table(proc$crim_ind)
proc <- proc[proc$crim_ind == "N"|proc$crim_ind == "Y",]
proc <- proc[!duplicated(proc),]

## merged the case and proc datasets
case_proc <- merge(proc, cases_nat, by.x = "idncase", by.y = "idncase", all.x = T)
cases_nat <- NULL #to save disk space
proc <- NULL
case_proc <- case_proc[case_proc$idncase!="",] 

case_proc$date_detained <- substr(case_proc$date_detained , 1, 10)
case_proc$date_detained <- as.Date(case_proc$date_detained, format = "%Y-%m-%d")

case_proc$date_released <- substr(case_proc$date_released  , 1, 10)
case_proc$date_released <- as.Date(case_proc$date_released , format = "%Y-%m-%d")

case_proc$time_detained <- case_proc$date_released - case_proc$date_detained
case_proc$time_detained[case_proc$time_detained<=0] <- NA

#create a list of case id that fall into the year range 15-21
caseid_15_21 <- time_tbl_eoir[,c("idncase","adj_date")]
time_tbl_eoir <- NULL
caseid_15_21 <- caseid_15_21[!duplicated(caseid_15_21[,1]),]

case_proc_15_21 <- merge(case_proc, caseid_15_21, by.x = "idncase", by.y = "idncase", all.y = T)
case_proc_15_21 <- case_proc_15_21[!is.na(case_proc_15_21$nat),]

case_proc_15_21$crim_ind <- as.character(case_proc_15_21$crim_ind)
case_proc_15_21$crim_ind <- as.factor(case_proc_15_21$crim_ind)


case_proc_15_21$custody <- as.character(case_proc_15_21$custody)
case_proc_15_21$custody[case_proc_15_21$custody=="R"] <- "D" #group released as detained since question of interest is whether one was ever detained
case_proc_15_21 <- case_proc_15_21[case_proc_15_21$custody!="",]

table(is.na(case_proc_15_21$date_detained), case_proc_15_21$custody) # 72517 obs were detained but not detained date ever recorded

### calculate the time under detention, which is time-variant on the caseid level
case_proc_15_21_detain_date_cal <- case_proc_15_21[!duplicated(case_proc_15_21[,c("idncase","date_detained","date_released")]),c("idncase","date_detained","date_released")]

case_proc_15_21_detain_date_cal$time_detention <- case_proc_15_21_detain_date_cal$date_released - case_proc_15_21_detain_date_cal$date_detained

#time in detention will be calculated until now (time that this code runs) if someone has a detained date 
#but no release time was posted (make sure to use the most updated data to avoid bias)
case_proc_15_21_detain_date_cal$time_detention[is.na(case_proc_15_21_detain_date_cal$date_released)] <- as.numeric(Sys.Date() - case_proc_15_21_detain_date_cal$date_detained[is.na(case_proc_15_21_detain_date_cal$date_released)]) 

case_proc_15_21_detain_date_cal$time_detention[case_proc_15_21_detain_date_cal$time_detention<0] <- NA

case_proc_15_21_detain_date_cal$time_detention <- as.numeric(case_proc_15_21_detain_date_cal$time_detention)

case_proc_15_21_detain_date_cal$adj_year <- as.numeric(format(case_proc_15_21_detain_date_cal$adj_date, "%Y"))

case_proc_15_21 <- case_proc[order(case_proc_15_21$idncase,case_proc_15_21$adj_date),] #make sure the earliest adj_date is kept for each caseid
case_proc_15_21_unique <- case_proc_15_21[,c("idncase","custody","case_type","immi_type","adj_date","atty_nbr")]
case_proc_15_21_unique <- case_proc_15_21_unique[!duplicated(case_proc_15_21_unique$idncase),] #immigrant-level (unique) stats

case_proc_15_21_agg <- summaryBy(crim_ind ~ idncase, FUN = c(mean), data = case_proc_15_21)

case_proc_15_21_agg$crim_vio <- rep(1, nrow(case_proc_15_21_agg))
case_proc_15_21_agg$crim_vio[case_proc_15_21_agg$crim_ind.mean<=1] <- 0 

case_proc_15_21_unique<- merge(case_proc_15_21_unique, case_proc_15_21_agg, by = "idncase")
case_proc_15_21_unique$adj_year <- as.numeric(format(case_proc_15_21_unique$adj_date,"%Y"))

#cleaning the bonds table 
bond <- read.csv("FOIA TRAC Report 20211201/D_TblAssociatedBond.csv", sep = "\t", header = T, skipNul = T)
bond <- bond[!duplicated(bond$IDNASSOCBOND),]
colnames(bond) <- tolower(colnames(bond))
bond_keep <- c("idncase", "bond_hear_req_date","initial_bond","new_bond")
bond <- subset(bond, select = bond_keep)

bond$bond_hear_req_date <- substr(bond$bond_hear_req_date, 1, 10)
bond$bond_hear_req_date  <- as.Date(bond$bond_hear_req_date, format = "%Y-%m-%d")

table(is.na(bond$bond_hear_req_date)) # 40 obs dont have a bond req date, would therefore be dropped
bond <- bond[!is.na(bond$bond_hear_req_date),]

bond$initial_bond <- as.numeric(bond$initial_bond)
bond$new_bond <- as.numeric(bond$new_bond)

bond$initial_bond[is.na(bond$initial_bond)] <- 0 
bond$new_bond[is.na(bond$new_bond)] <- 0 

#calculating the bond amount for each bond-id using initial and new bond amount
#the logic here is if an immigrant has a new bond but not initial bond, then the bond amount is the new bond
#if has initial bond but not new bond, the bond amount is the initial bond
#if has both initial bond and new bond, the bond amount will be the new bond
#if neither initial or new bond is available, the bond was never granted.

bond$bond_amount <- 0 
bond$bond_amount[bond$initial_bond==0 & bond$new_bond!=0] <- bond$new_bond[bond$initial_bond==0 & bond$new_bond!=0] #no initial bond but new bond
bond$bond_amount[bond$initial_bond!=0 & bond$new_bond!=0] <- bond$new_bond[bond$initial_bond!=0 & bond$new_bond!=0] #has initial bond but new bond
bond$bond_amount[bond$initial_bond!=0 & bond$new_bond==0] <- bond$initial_bond[bond$initial_bond!=0 & bond$new_bond==0] #has initial bond but no new bond
bond$bond_amount[bond$initial_bond==0 & bond$new_bond==0] <- bond$initial_bond[bond$initial_bond==0 & bond$new_bond==0] #no initial bond or new bond either, i.e., requested bond but did not get one for this proceeding/bond id

# averaging the bond amount for each case-id (immigrant)

bond_case <- summaryBy( cbind(bond_amount,initial_bond) ~ idncase, FUN = c(sum, mean), data = bond)

bond_case <- bond_case[2:nrow(bond_case),] #drop a blank obs

bond_case$req_bond <- 1

#merge bond and the unique case id data
case_proc_15_19_unique_bond <- merge(case_proc_15_19_unique, bond_case, by = "idncase", all.x = T)



#eoir case data requests

results_tbl <- matrix(0,24*7,10)

req_names <- read.csv(file = " FOIA TRAC Report 20211201/eoir_request_names.csv", sep = ",", header = F)

results_tbl[,1] <- req_names[,1]

colnames(results_tbl) <- c("request_names","total.African","total.Caribbean","total.Black","total.all","per.African","per.Caribbean","per.Black","per.all","year")

for (i in 1:7) {
  #below are tempo data that will be looped through the years
  tempo_data <- subset(case_proc_15_21_unique, adj_year == 2014+i)
  tempo_data_bond <- subset(case_proc_15_21_unique_bond, adj_year == 2014+i)
  tempo_data_detain_time <- subset(case_proc_15_21_detain_date_cal, adj_year == 2014 + i)
  results_tbl[(i-1)*24+1,10] <- 2014+i
  #request 1.
  x <- table(tempo_data$case_type[tempo_data$case_type == "RMV"])
  results_tbl[(i-1)*24+1,5] <- x[13]
  results_tbl[(i-1)*24+1,9] <- round(x[13]/nrow(tempo_data),4)
  
  #request 2.
  x <- table(tempo_data$custody[tempo_data$case_type=="RMV"])
  results_tbl[(i-1)*24+2,5] <- x[1]
  
  #request 3.
  x <- table(tempo_data$immi_type[tempo_data$case_type=="RMV"])
  results_tbl[(i-1)*24+3,2] <- x[1]
  results_tbl[(i-1)*24+3,3] <- x[2]
  results_tbl[(i-1)*24+3,4] <- x[1] + x[2]
  
  #request 4.
  x <- table(tempo_data$immi_type[tempo_data$case_type=="RMV" & tempo_data$custody == "D"])
  results_tbl[(i-1)*24+4,2] <- x[1]
  results_tbl[(i-1)*24+4,3] <- x[2]
  results_tbl[(i-1)*24+4,4] <- x[1] + x[2]
  
  #request 5.
  x <- table(tempo_data$custody[tempo_data$case_type=="RMV"])
  results_tbl[(i-1)*24+5,5] <- x[1]
  results_tbl[(i-1)*24+5,9] <- round(x[1]/(x[1] + x[2]),4)
  
  #request 6.
  x <- table(tempo_data$crim_vio[tempo_data$custody == "D"])
  results_tbl[(i-1)*24+6,5] <- x[1]
  results_tbl[(i-1)*24+6,9] <- round(x[1]/(x[1] + x[2]),4)
  
  #request 7.
  x <- table(tempo_data$crim_vio[tempo_data$custody == "D"])
  results_tbl[(i-1)*24+7,5] <- x[2]
  results_tbl[(i-1)*24+7,9] <- round(x[2]/(x[1] + x[2]),4)
  
  #request 8.
  x <- table(tempo_data$immi_type[tempo_data$case_type=="RMV"])
  results_tbl[(i-1)*24+8,2] <- x[1]
  results_tbl[(i-1)*24+8,3] <- x[2]
  results_tbl[(i-1)*24+8,4] <- x[1] + x[2]
  
  results_tbl[(i-1)*24+8,6] <- round(x[1]/nrow(tempo_data[tempo_data$case_type=="RMV",]),4)
  results_tbl[(i-1)*24+8,7] <- round(x[2]/nrow(tempo_data[tempo_data$case_type=="RMV",]),4)
  results_tbl[(i-1)*24+8,8] <- round((x[1] + x[2])/nrow(tempo_data[tempo_data$case_type=="RMV",]),4)
  
  #request 9.
  x <- table(tempo_data$immi_type[tempo_data$custody == "D"])
  results_tbl[(i-1)*24+9,2] <- x[1]
  results_tbl[(i-1)*24+9,3] <- x[2]
  results_tbl[(i-1)*24+9,4] <- x[1] + x[2]
  
  results_tbl[(i-1)*24+9,6] <- round(x[1]/nrow(tempo_data[tempo_data$case_type=="RMV",]),4)
  results_tbl[(i-1)*24+9,7] <- round(x[2]/nrow(tempo_data[tempo_data$case_type=="RMV",]),4)
  results_tbl[(i-1)*24+9,8] <- round((x[1] + x[2])/nrow(tempo_data[tempo_data$case_type=="RMV",]),4)
  
  #request 10.
  x <- table(tempo_data$immi_type[tempo_data$custody == "D"  & tempo_data$crim_vio == 0])
  results_tbl[(i-1)*24+10,2] <- x[1]
  results_tbl[(i-1)*24+10,3] <- x[2]
  results_tbl[(i-1)*24+10,4] <- x[1] + x[2]
  
  results_tbl[(i-1)*24+10,6] <- round(x[1]/nrow(tempo_data[tempo_data$custody == "D",]),4)
  results_tbl[(i-1)*24+10,7] <- round(x[2]/nrow(tempo_data[tempo_data$custody == "D",]),4)
  results_tbl[(i-1)*24+10,8] <- round((x[1] + x[2])/nrow(tempo_data[tempo_data$custody == "D",]),4)
  
  #request 11.
  x <- table(tempo_data$immi_type[tempo_data$custody == "D" & tempo_data$crim_vio == 1])
  results_tbl[(i-1)*24+11,2] <- x[1]
  results_tbl[(i-1)*24+11,3] <- x[2]
  results_tbl[(i-1)*24+11,4] <- x[1] + x[2]
  
  results_tbl[(i-1)*24+11,6] <- round(x[1]/nrow(tempo_data[tempo_data$custody == "D" & tempo_data$crim_vio == 0,]),4)
  results_tbl[(i-1)*24+11,7] <- round(x[2]/nrow(tempo_data[tempo_data$custody == "D" & tempo_data$crim_vio == 0,]),4)
  results_tbl[(i-1)*24+11,8] <- round((x[1] + x[2])/nrow(tempo_data[tempo_data$custody == "D" & tempo_data$crim_vio == 0,]),4)
  
  #request 12.
  x <- table(tempo_data$immi_type[tempo_data$case_type=="RMV"], tempo_data$custody[tempo_data$case_type=="RMV"])

  results_tbl[(i-1)*24+12,6] <- round(x[1]/(x[1]+x[1,2]),4)
  results_tbl[(i-1)*24+12,7] <- round(x[2,1]/(x[2,1]+x[2,2]),4)
  results_tbl[(i-1)*24+12,8] <- round(sum(x[,1])/sum(x[,]),4)
                                      
  #request 13.
  x <- table(tempo_data$immi_type[tempo_data$custody=="D"],tempo_data$crim_vio[tempo_data$custody=="D"])
                                      
  results_tbl[(i-1)*24+13,6] <- round(x[1]/(x[1]+x[1,2]),4)
  results_tbl[(i-1)*24+13,7] <- round(x[2,1]/(x[2,1]+x[2,2]),4)
  results_tbl[(i-1)*24+13,8] <- round(sum(x[,1])/sum(x[,]),4)
  
  #request 14.
  x <- table(tempo_data$immi_type[tempo_data$custody=="D"],tempo_data$crim_vio[tempo_data$custody=="D"])
                                      
  results_tbl[(i-1)*24+14,6] <- 1 - round(x[1]/(x[1]+x[1,2]),4)
  results_tbl[(i-1)*24+14,7] <- 1- round(x[2,1]/(x[2,1]+x[2,2]),4)
  results_tbl[(i-1)*24+14,8] <- 1- round(sum(x[,1])/sum(x[,]),4)     
                                      
  #request 15
  x <- table(tempo_data_bond$req_bond)
  results_tbl[(i-1)*24+15,5] <- x[1]
  results_tbl[(i-1)*24+15,9] <- round(x[1]/nrow(tempo_data_bond),4)
  
  #request 16
  x <- table(tempo_data_bond$bond_amount.sum!=0)
  results_tbl[(i-1)*24+16,5] <- x[2]
  results_tbl[(i-1)*24+16,9] <- round(x[1]/nrow(tempo_data_bond[!is.na(tempo_data_bond$req_bond),]),4)
  
  #request 17
  tempo_data_bond$req_bond[is.na(tempo_data_bond$req_bond)] <- 0
  x <- table(tempo_data_bond$immi_type, tempo_data_bond$req_bond)
  results_tbl[(i-1)*24+17,2] <- x[1,2]
  results_tbl[(i-1)*24+17,3] <- x[2,2]
  results_tbl[(i-1)*24+17,4] <- x[1,2] + x[2,2]
  
  results_tbl[(i-1)*24+17,6] <- round(x[1,2]/(x[1] + x[1,2]),4)
  results_tbl[(i-1)*24+17,7] <- round(x[2,2]/(x[2,1] + x[2,2]),4)
  results_tbl[(i-1)*24+17,8] <- round((x[1,2]+x[2,2])/sum(x[,]),4)
  
  #request 18
  tempo_data_bond$req_bond[is.na(tempo_data_bond$req_bond)] <- 0
  x <- table(tempo_data_bond$immi_type, tempo_data_bond$bond_amount.sum!=0)
  total_immi <- table(tempo_data_bond$immi_type)
  results_tbl[(i-1)*24+18,2] <- x[1,2]
  results_tbl[(i-1)*24+18,3] <- x[2,2]
  results_tbl[(i-1)*24+18,4] <- x[1] + x[2,2]
  
  results_tbl[(i-1)*24+18,6] <- round(x[1,2]/(x[1] + x[1,2]),4)
  results_tbl[(i-1)*24+18,7] <- round(x[2,2]/(x[2,1] + x[2,2]),4)
  results_tbl[(i-1)*24+18,8] <- round((x[1,2]+x[2,2])/sum(x[,]),4)
  
  #request 19
  x <- round(mean(tempo_data_bond$bond_amount.sum, na.rm = T),2)
  results_tbl[(i-1)*24+19,5] <- x
  
  #request 20
  x <- round(mean(tempo_data_bond$initial_bond.sum[tempo_data_bond$initial_bond.sum!=0], na.rm = T),2)
  results_tbl[(i-1)*24+20,5] <- x
  
  #request 21
  x <- c(round(mean(tempo_data_bond$bond_amount.sum[tempo_data_bond$immi_type == "African"], na.rm = T),1),round(mean(tempo_data_bond$bond_amount.sum[tempo_data_bond$immi_type == "Caribbean"], na.rm = T),1),round(mean(tempo_data_bond$bond_amount.sum[!is.na(tempo_data_bond$immi_type)], na.rm = T),1))

  results_tbl[(i-1)*24+21,2] <- x[1]
  results_tbl[(i-1)*24+21,3] <- x[2]
  results_tbl[(i-1)*24+21,4] <- x[3]
  
  #request 22
  x <- c(round(mean(tempo_data_bond$initial_bond.sum[tempo_data_bond$immi_type == "African" & tempo_data_bond$initial_bond.sum!=0], na.rm = T),1),
                    round(mean(tempo_data_bond$initial_bond.sum[tempo_data_bond$immi_type == "Caribbean" & tempo_data_bond$initial_bond.sum!=0], na.rm = T),1),
                    round(mean(tempo_data_bond$initial_bond.sum[!is.na(tempo_data_bond$immi_type) & tempo_data_bond$initial_bond.sum!=0], na.rm = T),1))
  
  results_tbl[(i-1)*24+22,2] <- x[1]
  results_tbl[(i-1)*24+22,3] <- x[2]
  results_tbl[(i-1)*24+22,4] <- x[3]
  
  #request 23 
  tempo_data_bond$atty_nbr <- as.numeric(tempo_data_bond$atty_nbr)
  
  x <- table(tempo_data_bond$atty_nbr== 0, useNA = "ifany")
  results_tbl[(i-1)*24+23,5] <- x[2]
  results_tbl[(i-1)*24+23,9] <- round(x[2]/nrow(tempo_data),4)
  
  #request 24
 
  x <- summary(tempo_data_detain_time$time_detention)
  
  results_tbl[(i-1)*24+24,5] <- paste0( round(x[4],1), " days")
}

results_tbl[1:168,1] <- rep(req_names[,1],7)

write.csv(results_tbl, file = " FOIA TRAC Report 20211201/eoir_results_byear_new.csv")

