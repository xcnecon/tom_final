//use the 2019 household raw data
use "$data/chfs2019_raw.dta", clear
// get the individual id of the household head
keep hhid a1003a
save "$data/2019_household_head.dta", replace

// clean CHFS 2019 data
use "$data/chfs2019.dta", clear
merge m:1 hhid using "$data/2019_household_head.dta"
drop _merge
// keep the household head
keep if pline == a1003a

// Replace missing values with zeros for numeric variables only
foreach var of varlist _all {
    capture confirm numeric variable `var'
    if !_rc {
        replace `var' = 0 if missing(`var')
    }
}

// generate variables
gen net_worth = total_asset - total_debt
// calculate the equity value of various assets by subtracting the debt from the asset
replace house_asset = house_asset + garage_asset
gen commercial_asset = agri_asset + busi_asset + comprop_asset
gen commercial_debt = agri_debt + busi_debt + comprop_debt
replace other_debt = othnf_debt + other_debt + educ_debt + credit_debt + medical_debt
gen other_asset = othnf_asset
gen fina_equity = fina_asset - fina_debt

replace house_debt = -house_debt
replace vehicle_debt = -vehicle_debt
replace commercial_debt = -commercial_debt
replace other_debt = -other_debt
replace fina_debt = -fina_debt

label variable house_asset "House Asset"
label variable commercial_asset "Commercial Asset"
label variable commercial_debt "Commercial Debt"
label variable other_debt "Other Debt"
label variable fina_equity "Financial Equity"

// drop unneccesary variables
drop pline hhcid track pa28 city_lab county_lab pabcd pab garage_asset comprop_asset agri_asset busi_asset othnf_asset comprop_debt agri_debt busi_debt othnf_debt nfina_asset fina_debt fina_asset

// replace value labels
label define rural_lbl ///
    0 "Urban" ///
    1 "Rural"
label values rural rural_lbl
label variable rural "1: Rural 0: Urban"

// mark year
gen year = 2019
order year

save "$data/chfs2019_clean.dta", replace


//use the 2017 household raw data
use "$data/chfs2017_raw.dta", clear
// get the individual id of the household head
keep if hhead == 1
keep hhid pline
rename pline a1003a
save "$data/2017_household_head.dta", replace

// clean CHFS 2017 data
use "$data/chfs2017.dta", clear
merge m:1 hhid using "$data/2017_household_head.dta"
drop _merge
// keep the household head
keep if pline == a1003a

drop if qc == 1 // drop if the quality of the survey is bad; this qc variable is not available in 2019

// Replace missing values with zeros for numeric variables only
foreach var of varlist _all {
    capture confirm numeric variable `var'
    if !_rc {
        replace `var' = 0 if missing(`var')
    }
}

// generate variables
gen net_worth = total_asset - total_debt
// calculate the equity value of various assets by subtracting the debt from the asset
replace house_asset = house_asset
gen commercial_asset = agri_asset + busi_asset + comprop_asset
gen commercial_debt = agri_debt + busi_debt + comprop_debt
replace other_debt = othnf_debt + other_debt
gen other_asset = othnf_asset
gen fina_equity = fina_asset - fina_debt

replace house_debt = -house_debt
replace vehicle_debt = -vehicle_debt
replace commercial_debt = -commercial_debt
replace other_debt = -other_debt
replace fina_debt = -fina_debt

label variable house_asset "House Asset"
label variable commercial_asset "Commercial Asset"
label variable commercial_debt "Commercial Debt"
label variable other_debt "Other Debt"
label variable fina_equity "Financial Equity"

// generate the missing rural variable
generate region = .

**************************************************************************
* East：北京、天津、河北、上海、江苏、浙江、福建、山东、广东、海南
**************************************************************************
replace region = 1 if inlist(prov, ///
    "北京市", "天津市", "河北省", "上海市", "江苏省")
replace region = 1 if inlist(prov, ///
    "浙江省", "福建省", "山东省", "广东省", "海南省")

**************************************************************************
* Middle：山西、安徽、江西、河南、湖北、湖南
**************************************************************************
replace region = 2 if inlist(prov, ///
    "山西省", "安徽省", "江西省", "河南省", "湖北省")
replace region = 2 if inlist(prov, ///
    "湖南省")

**************************************************************************
* West：内蒙古、广西、重庆、四川、贵州、云南、西藏、陕西、甘肃、青海、宁夏、新疆
**************************************************************************
replace region = 3 if inlist(prov, ///
    "内蒙古自治区", "广西壮族自治区", "重庆市", "四川省", "贵州省")
replace region = 3 if inlist(prov, ///
    "云南省", "西藏自治区", "陕西省", "甘肃省", "青海省")
replace region = 3 if inlist(prov, ///
    "宁夏回族自治区", "新疆维吾尔自治区")

**************************************************************************
* Northeast：辽宁、吉林、黑龙江
**************************************************************************
replace region = 4 if inlist(prov, ///
    "辽宁省", "吉林省", "黑龙江省")

label define region_lbl ///
    1 "East" ///
    2 "Middle" ///
    3 "West" ///
    4 "Northeast"
label values region region_lbl
label variable region "Region"

// drop unneccesary variables
drop hhid_2011 hhid_2013 hhid_2015 hhid_2017 prov prov_code pline hhcid pab city_lab county_lab comprop_asset agri_asset busi_asset othnf_asset comprop_debt agri_debt busi_debt othnf_debt nfina_asset fina_debt fina_asset qc

// mark year
gen year = 2017
order year

// replace value labels
label define rural_lbl ///
    0 "Urban" ///
    1 "Rural"
label values rural rural_lbl
label variable rural "1: Rural 0: Urban"

save "$data/chfs2017_clean.dta", replace




