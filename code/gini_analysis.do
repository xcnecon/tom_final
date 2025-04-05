//ssc install ineqdecgini
use "$data/chfs2017_clean.dta", clear
//use "$data/chfs2019_clean.dta", clear

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


// factor decompose gini for net worth
foreach k in "house_equity" "land_asset" "commercial_equity" "comprop_equity" "car_equity" "fina_equity" "other_equity" "educ_debt" "credit_debt" "medical_debt" {
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


matrix results_1 = (r_house_equity, g_house_equity, s_house_equity, contribution_house_equity \ ///
                    r_land_asset, g_land_asset, s_land_asset, contribution_land_asset \ ///
                    r_commercial_equity, g_commercial_equity, s_commercial_equity, contribution_commercial_equity \ ///
                    r_comprop_equity, g_comprop_equity, s_comprop_equity, contribution_comprop_equity \ ///
                    r_car_equity, g_car_equity, s_car_equity, contribution_car_equity \ ///
                    r_fina_equity, g_fina_equity, s_fina_equity, contribution_fina_equity \ ///
                    r_other_equity, g_other_equity, s_other_equity, contribution_other_equity \ ///
                    r_educ_debt, g_educ_debt, s_educ_debt, contribution_educ_debt \ ///
                    r_credit_debt, g_credit_debt, s_credit_debt, contribution_credit_debt \ ///
                    r_medical_debt, g_medical_debt, s_medical_debt, contribution_medical_debt)

matrix colnames results_1 = "Gini Correlation" "Gini Coefficient" "Share" "Contribution"
matrix rownames results_1 = "Household Equity" "Land Asset" "Commercial Equity" "Commercial Property" "Car Equity" "Financial Equity" "Other Equity" "Educational Debt" "Credit Debt" "Medical Debt"

matlist results_1, format(%15.4f)

// income gini based on rural and urban

quietly sum total_income [aw= weight_ind] if rural == 0, d
scalar mean_income_urban = r(mean)
scalar median_income_urban = r(p50)

quietly sum total_income [aw= weight_ind] if rural == 1, d
scalar mean_income_rural = r(mean)
scalar median_income_rural = r(p50)

display "Median of Rural Household Total Income: " median_income_rural
display "Median of Urban Household Total Income: " median_income_urban

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

