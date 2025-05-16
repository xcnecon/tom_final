// -----------------------------------------------------------------------------
// Clean and process CHFS 2019 and 2017 household survey data
// This script prepares household-level data for analysis by cleaning, generating
// variables, and harmonizing across years.
// -----------------------------------------------------------------------------

// =========================
// CHFS 2019 Data Cleaning
// =========================

// Load 2019 household raw data and extract household head IDs
use "$data/chfs2019_raw.dta", clear
keep hhid a1003a // Keep only household ID and head's individual ID
save "$data/2019_household_head.dta", replace // Save household head IDs

// Load 2019 main data and merge with household head IDs
use "$data/chfs2019.dta", clear
merge m:1 hhid using "$data/2019_household_head.dta"
drop _merge // Remove merge indicator
keep if pline == a1003a // Keep only household head records

// Replace missing values with zeros for all numeric variables
foreach var of varlist _all {
    capture confirm numeric variable `var'
    if !_rc {
        replace `var' = 0 if missing(`var')
    }
}

// Generate net worth and asset/debt variables
// Net worth = total assets - total debts
gen net_worth = total_asset - total_debt
// Combine house and garage assets
replace house_asset = house_asset + garage_asset
// Sum up commercial assets and debts
gen commercial_asset = agri_asset + busi_asset + comprop_asset
gen commercial_debt = agri_debt + busi_debt + comprop_debt
// Combine other debts
replace other_debt = othnf_debt + other_debt + educ_debt + credit_debt + medical_debt
// Assign other asset
gen other_asset = othnf_asset
// Financial equity = financial assets - financial debts
gen fina_equity = fina_asset - fina_debt

// Reverse sign for debt variables (make debts negative)
replace house_debt = -house_debt
replace vehicle_debt = -vehicle_debt
replace commercial_debt = -commercial_debt
replace other_debt = -other_debt
replace fina_debt = -fina_debt

// Label variables for clarity
label variable house_asset "House Asset"
label variable commercial_asset "Commercial Asset"
label variable commercial_debt "Commercial Debt"
label variable other_debt "Other Debt"
label variable fina_equity "Financial Equity"

// Drop unnecessary variables to tidy dataset
drop pline hhcid track pa28 city_lab county_lab pabcd pab garage_asset comprop_asset agri_asset busi_asset othnf_asset comprop_debt agri_debt busi_debt othnf_debt nfina_asset fina_debt fina_asset

// Define and assign value labels for rural/urban variable
label define rural_lbl ///
    0 "Urban" ///
    1 "Rural"
label values rural rural_lbl
label variable rural "1: Rural 0: Urban"

// Add year marker
gen year = 2019
order year

// Save cleaned 2019 data
save "$data/chfs2019_clean.dta", replace


// =========================
// CHFS 2017 Data Cleaning
// =========================

// Load 2017 household raw data and extract household head IDs
use "$data/chfs2017_raw.dta", clear
keep if hhead == 1 // Keep only household heads
keep hhid pline
rename pline a1003a // Standardize household head ID variable name
save "$data/2017_household_head.dta", replace

// Load 2017 main data and merge with household head IDs
use "$data/chfs2017.dta", clear
merge m:1 hhid using "$data/2017_household_head.dta"
drop _merge // Remove merge indicator
keep if pline == a1003a // Keep only household head records

drop if qc == 1 // Drop records with poor survey quality (qc not available in 2019)

// Replace missing values with zeros for all numeric variables
foreach var of varlist _all {
    capture confirm numeric variable `var'
    if !_rc {
        replace `var' = 0 if missing(`var')
    }
}

// Generate net worth and asset/debt variables
// Net worth = total assets - total debts
gen net_worth = total_asset - total_debt
// House asset (no garage asset in 2017)
replace house_asset = house_asset
// Sum up commercial assets and debts
gen commercial_asset = agri_asset + busi_asset + comprop_asset
gen commercial_debt = agri_debt + busi_debt + comprop_debt
// Combine other debts
replace other_debt = othnf_debt + other_debt
// Assign other asset
gen other_asset = othnf_asset
// Financial equity = financial assets - financial debts
gen fina_equity = fina_asset - fina_debt

// Reverse sign for debt variables (make debts negative)
replace house_debt = -house_debt
replace vehicle_debt = -vehicle_debt
replace commercial_debt = -commercial_debt
replace other_debt = -other_debt
replace fina_debt = -fina_debt

// Label variables for clarity
label variable house_asset "House Asset"
label variable commercial_asset "Commercial Asset"
label variable commercial_debt "Commercial Debt"
label variable other_debt "Other Debt"
label variable fina_equity "Financial Equity"

// Generate region variable based on province names
// 1: East, 2: Middle, 3: West, 4: Northeast
generate region = .

// Assign region codes for each province group
// East: Beijing, Tianjin, Hebei, Shanghai, Jiangsu, Zhejiang, Fujian, Shandong, Guangdong, Hainan
replace region = 1 if inlist(prov, ///
    "北京市", "天津市", "河北省", "上海市", "江苏省")
replace region = 1 if inlist(prov, ///
    "浙江省", "福建省", "山东省", "广东省", "海南省")
// Middle: Shanxi, Anhui, Jiangxi, Henan, Hubei, Hunan
replace region = 2 if inlist(prov, ///
    "山西省", "安徽省", "江西省", "河南省", "湖北省")
replace region = 2 if inlist(prov, ///
    "湖南省")
// West: Inner Mongolia, Guangxi, Chongqing, Sichuan, Guizhou, Yunnan, Tibet, Shaanxi, Gansu, Qinghai, Ningxia, Xinjiang
replace region = 3 if inlist(prov, ///
    "内蒙古自治区", "广西壮族自治区", "重庆市", "四川省", "贵州省")
replace region = 3 if inlist(prov, ///
    "云南省", "西藏自治区", "陕西省", "甘肃省", "青海省")
replace region = 3 if inlist(prov, ///
    "宁夏回族自治区", "新疆维吾尔自治区")
// Northeast: Liaoning, Jilin, Heilongjiang
replace region = 4 if inlist(prov, ///
    "辽宁省", "吉林省", "黑龙江省")

// Label region variable
label define region_lbl ///
    1 "East" ///
    2 "Middle" ///
    3 "West" ///
    4 "Northeast"
label values region region_lbl
label variable region "Region"

// Drop unnecessary variables to tidy dataset
drop hhid_2011 hhid_2013 hhid_2015 hhid_2017 prov prov_code pline hhcid pab city_lab county_lab comprop_asset agri_asset busi_asset othnf_asset comprop_debt agri_debt busi_debt othnf_debt nfina_asset fina_debt fina_asset qc

// Add year marker
gen year = 2017
order year

// Define and assign value labels for rural/urban variable
label define rural_lbl ///
    0 "Urban" ///
    1 "Rural"
label values rural rural_lbl
label variable rural "1: Rural 0: Urban"

// Save cleaned 2017 data
save "$data/chfs2017_clean.dta", replace