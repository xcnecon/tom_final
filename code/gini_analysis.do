//ssc install ineqdecgini
use "$data/chfs2017_clean.dta", clear

//count
count

//Calculate the gini index and MLD for household total income
quietly sum total_income [aw= weight_ind],d
scalar mean_income = r(mean)
scalar median_income = r(p50)
quietly cumul total_income [aw=weight_ind], g(Fy_income) 
quietly corr total_income Fy_income [aw=weight_ind], c 
scalar cov_income = r(cov_12)
scalar gini_income = 2 * cov_income / mean_income 

// calculate the gini index and MLD for household net worth
quietly sum net_worth [aw= weight_ind], d
scalar mean_net_worth = r(mean)
scalar median_net_worth = r(p50)
quietly cumul net_worth [aw=weight_ind], g(Fy_net_worth) 
quietly corr net_worth Fy_net_worth [aw=weight_ind], c 
scalar cov_net_worth = r(cov_12)
scalar gini_net_worth = 2 * cov_net_worth / mean_net_worth 

display "Mean of Household Total Income: " mean_income
display "Median of Household Total Income: " median_income
display "Gini Index of Household Total Income: " gini_income
display "Mean of Household Net Worth: " mean_net_worth
display "Median of Household Net Worth: " median_net_worth
display "Gini Index of Household Net Worth: " gini_net_worth

// add proportion‑zero column
local varlist "house_asset land_asset fina_equity vehicle_asset commercial_asset other_asset house_debt vehicle_debt commercial_debt other_debt"
local nvars : word count `varlist'

matrix asset_stats = J(`nvars',3,.)   // 3 columns: Mean | Median | Prop_zero
local i = 1
foreach v of varlist `varlist' {
    // mean and median (weighted)
    quietly sum `v' [aw=weight_ind], detail
    matrix asset_stats[`i',1] = r(mean)
    matrix asset_stats[`i',2] = r(p50)

    // proportion of zero values (weighted)
    gen byte zero_`v' = (`v'==0)
    quietly sum zero_`v' [aw=weight_ind]
    matrix asset_stats[`i',3] = r(mean)
    drop zero_`v'

    local ++i
}

matrix colnames asset_stats = "Mean" "Median" "Prop_zero"
matrix rownames asset_stats = "House Asset" "Land Asset" "Financial Equity" "Vehicle Asset" "Commercial Asset" "Other Asset" "House Debt" "Vehicle Debt" "Commercial Debt" "Other Debt"

matlist asset_stats, format(%15.2f)

// factor decompose gini for net worth
foreach k in "house_asset" "land_asset" "fina_equity" "vehicle_asset" "commercial_asset" "other_asset" "house_debt" "vehicle_debt" "commercial_debt" "other_debt" {
	preserve
    // calculate the covariance between `k' and Fy
	quietly corr `k' Fy_net_worth [aw=weight_ind], c
	scalar cov_`k'_fy = r(cov_12)
    // calculate the covariance between `k' and Fy_k
    cumul `k' [aw=weight_ind], gen(Fy_`k')
	quietly corr `k' Fy_`k' [aw=weight_ind], c
	scalar cov_`k'_fyk = r(cov_12)
    // calculate the gini correlation
	scalar r_`k' = cov_`k'_fy / cov_`k'_fyk 
    // calculate the mean of this source of net worth
	quietly ameans `k' [aw=weight_ind]
	scalar u_`k' = r(mean) 
    // calculate the gini coefficient for this source
	scalar g_`k' = 2 * cov_`k'_fyk / u_`k'
    // calculate the share of this source of net worth
	scalar s_`k' = u_`k' / mean_net_worth
    // calculate the contribution of this source to the overall gini
	scalar contribution_`k' = r_`k' * g_`k' * s_`k' / gini_net_worth
	restore
}


matrix results_1 = (r_house_asset, g_house_asset, s_house_asset, contribution_house_asset \ ///
                    r_land_asset, g_land_asset, s_land_asset, contribution_land_asset \ ///
                    r_fina_equity, g_fina_equity, s_fina_equity, contribution_fina_equity \ ///
                    r_commercial_asset, g_commercial_asset, s_commercial_asset, contribution_commercial_asset \ ///
                    r_vehicle_asset, g_vehicle_asset, s_vehicle_asset, contribution_vehicle_asset \ ///
                    r_other_asset, g_other_asset, s_other_asset, contribution_other_asset \ ///
                    r_house_debt, g_house_debt, s_house_debt, contribution_house_debt \ ///
                    r_vehicle_debt, g_vehicle_debt, s_vehicle_debt, contribution_vehicle_debt \ ///
                    r_commercial_debt, g_commercial_debt, s_commercial_debt, contribution_commercial_debt \ ///
                    r_other_debt, g_other_debt, s_other_debt, contribution_other_debt)

matrix colnames results_1 = "Gini Correlation" "Gini Coefficient" "Share" "Contribution"
matrix rownames results_1 = "House Asset" "Land Asset" "Financial Equity" "Commercial Asset" "Vehicle Asset" "Other Asset" "House Debt" "Vehicle Debt" "Commercial Debt" "Other Debt"

matlist results_1, format(%15.4f)

// income gini based on rural and urban

quietly sum net_worth [aw= weight_ind] if rural == 0, d
scalar mean_net_worth_urban = r(mean)
scalar median_net_worth_urban = r(p50)

quietly sum net_worth [aw= weight_ind] if rural == 1, d
scalar mean_net_worth_rural = r(mean)
scalar median_net_worth_rural = r(p50)

display "Median of Rural Household Net Worth: " median_net_worth_rural
display "Median of Urban Household Net Worth: " median_net_worth_urban

// group decomposition of gini
ineqdecgini net_worth [aw=weight_ind], by(rural)


// net worth gini based on region
preserve
quietly sum net_worth [aw= weight_ind] if region == 1, d
scalar mean_net_worth_east = r(mean)
scalar median_net_worth_east = r(p50)

quietly sum net_worth [aw= weight_ind] if region == 2, d
scalar mean_net_worth_middle = r(mean)
scalar median_net_worth_middle = r(p50)

quietly sum net_worth [aw= weight_ind] if region == 3, d
scalar mean_net_worth_west = r(mean)
scalar median_net_worth_west = r(p50)

quietly sum net_worth [aw= weight_ind] if region == 4, d
scalar mean_net_worth_northeast = r(mean)
scalar median_net_worth_northeast = r(p50)

display "Median of East Household Net Worth: " median_net_worth_east
display "Median of Middle Household Net Worth: " median_net_worth_middle
display "Median of West Household Net Worth: " median_net_worth_west
display "Median of Northeast Household Net Worth: " median_net_worth_northeast

// group decomposition of gini
ineqdecgini net_worth [aw=weight_ind], by(region)

