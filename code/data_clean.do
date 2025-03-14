// clean CHFS 2019 data
use "$data/chfs2019.dta", clear

// drop dubplicate household
duplicates drop hhid, force

// drop unneccesary variables
drop pline hhcid track pa28 weight_ind city_lab county_lab pabcd pab

// mark year
gen year = 2019
order year

save "$data/chfs2019_clean.dta", replace

// clean CHFS 2017 data
use "$data/chfs2017.dta", clear

// drop dubplicate household
duplicates drop hhid, force

// drop unneccesary variables
drop hhid_2011 hhid_2013 hhid_2015 hhid_2017 pline hhcid pab weight_ind city_lab county_lab

// mark year
gen year = 2017
order year

save "$data/chfs2017_clean.dta", replace




