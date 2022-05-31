**cleaning(further) & analysis of 2015 ipums data 
clear all
do "/ipums_2015_dofile.do"

svyset cluster [pweight=perwt], strata(strata)

tab raced

gen blk_all = 1 if raced == 200 | raced == 801 | (raced >= 830 & raced <= 845) | (race >= 901 & race <= 904) | (raced >= 930 & raced <= 935) | (raced >= 950 & raced <= 955) | (raced >= 970 & raced <= 973) | (raced >= 980 & raced <= 983) | raced == 985 | raced == 986 | raced == 990
replace blk_all = 0 if blk_all != 1

tab blk_all race

gen african_immi_blk = 1 if ((bpld == 16020|bpld >= 60000) & bpld <= 60099) & blk_all == 1
replace african_immi_blk = 0 if african_immi != 1
tab african_immi_blk

gen caribb_immi_blk = 1 if ((bpld >= 25000 & bpld <= 26045) | (bpld >= 26052 & bpld <= 26070)) & blk_all == 1
replace caribb_immi_blk = 0 if caribb != 1
tab caribb_immi_blk

gen blk_immi = 1 if blk_all == 1 & bpl >= 150
replace blk_immi = 0 if blk_immi!=1
tab blk_immi

gen foreign_born = 1 if bpl >= 150
replace foreign_born = 0 if foreign_born != 1
tab foreign_born

gen asia_immi = 1 if bpl >= 500 & bpl <= 599
replace asia_immi = 0 if asia_immi !=1
tab asia_immi

gen hisp = 1 if hispan != 0
replace hisp = 0 if hispan == 0
tab hisp

gen hisp_immi = 1 if hisp == 1 &  bpl >= 150
replace hisp_immi = 0 if hisp_immi != 1
tab hisp_immi

gen eu_immi = 1 if bpl >= 400 & bpl <= 499
replace eu_immi = 0 if eu_immi!= 1
tab eu_immi

gen cen_amer = 1 if bpl == 210 
replace cen_amer = 0 if cen_amer != 1
tab cen_amer

//Percent of Black immigrants within the national Black population 
svy: tab blk_all foreign_born

di .013/.1366

//Total foreign-born population

svy: tab foreign_born if foreign_born == 1


//per of black within foreign-born population

svy: tab blk_all if foreign_born == 1


//Totals and percents of Black immigrants residing in the following  states/regions 
svy: tab stateicp if blk_immi == 1


//taluation with place of birth for african black immigrants(foreign born)
svy: tab bpld if blk_all == 1 & african_immi == 1

//taluation with place of birth for Caribbean black immigrants(foreign born)
svy: tab bpld if blk_all == 1 & caribb_immi == 1


//num. & per of naturalized foreign-born black immigrants
gen natural = 1 if yrnatur != 9999
gen s_american_immi = 1 if bpl == 300
svy: tab natural if african_immi_blk  ==1
svy: tab natural if caribb_immi_blk ==1
svy: tab natural if s_american_immi == 1 & blk_immi == 1

//num. & per of black immigrants from these regions

svy: mean cen_amer if blk_immi == 1
svy: mean asia_immi if blk_immi == 1
svy: mean eu_immi if blk_immi == 1
svy: mean s_american_immi if blk_immi == 1


///education 

gen bachelor = 1 if educ == 10 
replace bachelor = 0 if bachelor !=1

tab bachelor

gen ad_educ = 1 if educ == 11
replace ad_educ = 0 if ad_educ != 1 

tab ad_educ

svy: tab bachelor if blk_immi == 1
svy: tab bachelor if african_immi_blk == 1
svy: tab bachelor if caribb_immi_blk  == 1 
svy: tab bachelor if asia_immi  == 1
svy: tab bachelor if hisp_immi  == 1
svy: tab bachelor if eu_immi  == 1

svy: tab ad_educ if blk_immi == 1
svy: tab ad_educ if african_immi_blk == 1
svy: tab ad_educ if caribb_immi_blk  == 1 
svy: tab ad_educ if asia_immi  == 1
svy: tab ad_educ if hisp_immi  == 1
svy: tab ad_educ if eu_immi  == 1


clear all
do "/ipums_2019_dofile.do"

svyset cluster [pweight=perwt], strata(strata)

gen blk_all = 1 if raced == 200 | raced == 801 | (raced >= 830 & raced <= 845) | (race >= 901 & race <= 904) | (raced >= 930 & raced <= 935) | (raced >= 950 & raced <= 955) | (raced >= 970 & raced <= 973) | (raced >= 980 & raced <= 983) | raced == 985 | raced == 986 | raced == 990
replace blk_all = 0 if blk_all != 1

gen african_immi_blk = 1 if ((bpld == 16020|bpld >= 60000) & bpld <= 60099) & blk_all == 1
replace african_immi_blk = 0 if african_immi != 1
tab african_immi_blk

*svy: tab african_immi_blk

*svy: tab bpld if african_immi == 1

gen caribb_immi_blk = 1 if ((bpld >= 25000 & bpld <= 26045) | (bpld >= 26052 & bpld <= 26070)) & blk_all == 1
replace caribb_immi_blk = 0 if caribb != 1
tab caribb_immi_blk
*svy: tab bpld if caribb_immi_blk == 1

gen blk_immi = 1 if blk_all == 1 & bpl >= 150
replace blk_immi = 0 if blk_immi!=1
tab blk_immi

gen foreign_born = 1 if bpl >= 150
replace foreign_born = 0 if foreign_born != 1
tab foreign_born

gen asia_immi = 1 if bpl >= 500 & bpl <= 599
replace asia_immi = 0 if asia_immi !=1
tab asia_immi

gen hisp = 1 if hispan != 0
replace hisp = 0 if hispan == 0
tab hisp

gen hisp_immi = 1 if hisp == 1 &  bpl >= 150
replace hisp_immi = 0 if hisp_immi != 1
tab hisp_immi

gen eu_immi = 1 if bpl >= 400 & bpl <= 499
replace eu_immi = 0 if eu_immi!= 1
tab eu_immi

gen cen_amer = 1 if bpl == 210 
replace cen_amer = 0 if cen_amer != 1
tab cen_amer

//Percent of Black immigrants within the national Black population 
svy: tab blk_all foreign_born

di .0145/.1391

//Total foreign-born population

svy: mean foreign_born if foreign_born == 1

//per of black within foreign-born population

svy: tab blk_all if foreign_born == 1

//Totals and percents of Black immigrants residing in the following  states/regions 
svy: tab stateicp if blk_immi == 1

//taluation with place of birth for african black immigrants(foreign born)
svy: tab bpld if blk_all == 1 & african_immi == 1

//taluation with place of birth for Caribbean black immigrants(foreign born)
svy: tab bpld if blk_all == 1 & caribb_immi == 1


//num. & per of naturalized foreign-born black immigrants
gen natural = 1 if yrnatur != 9999
gen s_american_immi = 1 if bpl == 300
svy: tab natural if african_immi_blk  ==1
svy: tab natural if caribb_immi_blk ==1
svy: tab natural if s_american_immi == 1 & blk_immi == 1

//num. & per of black immigrants from these regions

svy: mean cen_amer if blk_immi == 1
svy: mean asia_immi if blk_immi == 1
svy: mean eu_immi if blk_immi == 1
svy: mean s_american_immi if blk_immi == 1

svy: tab foreorn if natural != 1


///education 

gen bachelor = 1 if educ == 10 
replace bachelor = 0 if bachelor !=1

tab bachelor

gen ad_educ = 1 if educ == 11
replace ad_educ = 0 if ad_educ != 1 

tab ad_educ

svy: tab bachelor if blk_immi == 1
svy: tab bachelor if african_immi_blk == 1
svy: tab bachelor if caribb_immi_blk  == 1 
svy: tab bachelor if asia_immi  == 1
svy: tab bachelor if hisp_immi  == 1
svy: tab bachelor if eu_immi  == 1

svy: tab ad_educ if blk_immi == 1
svy: tab ad_educ if african_immi_blk == 1
svy: tab ad_educ if caribb_immi_blk  == 1 
svy: tab ad_educ if asia_immi  == 1
svy: tab ad_educ if hisp_immi  == 1
svy: tab ad_educ if eu_immi  == 1
