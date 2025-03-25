// import data
//global root "C:\Users\CHENY\Documents\GitHub\temp\ps1"
//global data "$root\asec.dta"
//cd "$root"
//use $data, clear


// Q1
// 1) create the categorical variable with five categories
recode hhinc ///
    (0/29999 = 1)    ///
    (30000/59999 = 2)  ///
    (60000/89999 = 3)  ///
    (90000/119999 = 4)  ///
    (120000/max = 5), ///
    generate(hhinc_cat5)
	
label define lbl_hhinc_cat5 ///
    1 "< $30k"        ///
    2 "$30k - $60k" ///
    3 "$60k - $90k" ///
    4 "$90k - $120k" ///
    5 "≥ $120k"

label values hhinc_cat5 lbl_hhinc_cat5

// 2) create the categorical variable with ten categories
recode hhinc ///
    (0/19999 = 1)    ///
    (20000/39999 = 2)  ///
    (40000/59999 = 3)  ///
    (60000/79999 = 4)  ///
    (80000/99999 = 5)  ///
    (100000/119999 = 6)  ///
    (120000/139999 = 7)  ///
    (140000/159999 = 8)  ///
    (160000/179999 = 9)  ///
    (180000/max = 10), ///
    generate(hhinc_cat10)

label define lbl_hhinc_cat10 ///
    1  "< $20k"       ///
    2  "$20k - $40k" ///
    3  "$40k - $60k" ///
    4  "$60k - $80k" ///
    5  "$80k - $100k" ///
    6  "$100k - $120k" ///
    7  "$120k - $140k" ///
    8  "$140k - $160k" ///
    9  "$160k - $180k" ///
    10 "≥ $180k"

label values hhinc_cat10 lbl_hhinc_cat10

// 3) create the categorical variable with fifteen categories
recode hhinc ///
    (0/29999 = 1)    ///
    (30000/59999 = 2)  ///
    (60000/89999 = 3)  ///
    (90000/119999 = 4)  ///
    (120000/149999 = 5)  ///
    (150000/179999 = 6)  ///
    (180000/209999 = 7)  ///
    (210000/239999 = 8)  ///
    (240000/269999 = 9)  ///
    (270000/299999 = 10)  ///
    (300000/329999 = 11)  ///
    (330000/359999 = 12)  ///
    (360000/389999 = 13)  ///
    (390000/419999 = 14)  ///
    (420000/max = 15), ///
    generate(hhinc_cat15)

label define lbl_hhinc_cat15 ///
    1  "< $30k"       ///
    2  "$30k - $60k"  ///
    3  "$60k - $90k"  ///
    4  "$90k - $120k" ///
    5  "$120k - $150k" ///
    6  "$150k - $180k" ///
    7  "$180k - $210k" ///
    8  "$210k - $240k" ///
    9  "$240k - $270k" ///
    10 "$270k - $300k" ///
    11 "$300k - $330k" ///
    12 "$330k - $360k" ///
    13 "$360k - $390k" ///
    14 "$390k - $420k" ///
    15 "≥ $420k"

label values hhinc_cat15 lbl_hhinc_cat15

// Create the three graphs and save them
graph hbar (percent) [pweight=weight], over(hhinc_cat5) ///
    title("5 Custom Brackets", size(medium)) ///
    ytitle("Weighted Percentages", size(small)) ///
    blabel(bar, size(small)) name(g5, replace)

graph hbar (percent) [pweight=weight], over(hhinc_cat10) ///
    title("10 Custom Brackets", size(medium)) ///
    ytitle("Weighted Percentages", size(small)) ///
    blabel(bar, size(small)) name(g10, replace)

graph hbar (percent) [pweight=weight], over(hhinc_cat15) ///
    title("15 Custom Brackets", size(medium)) ///
    ytitle("Weighted Percentages", size(small)) ///
    blabel(bar, size(small)) name(g15, replace)

// Combine the three graphs into a single (1,2) graph
graph combine g5 g10 g15, rows(1) cols(3) ///
    title("Distribution of Household Income", size(large)) ///
    ysize(10) xsize(20) iscale(0.9)

// Export the combined graph
graph export "income_distribution_combined.png", replace width(3000)

// Q2
// calculate theil index for the entire sample
quietly ameans hhinc [aw = weight]
scalar a_mean = r(mean) // get the arithmetic mean
scalar g_mean = r(mean_g) // get the geometric mean
scalar theil_L = ln(a_mean) - ln(g_mean) // calculate theil L

// calcualte Atkinson index (e = 1) for total population
scalar aktinson = 1 - g_mean / a_mean

// calcualte both index based on race
foreach race in 1 2 3 4 5 {
    preserve
    keep if race == `race'
    quietly ameans hhinc [aw = weight]
    scalar a_mean_`race' = r(mean)
    scalar g_mean_`race' = r(mean_g)
    scalar theil_L_`race' = ln(a_mean_`race') - ln(g_mean_`race')
    scalar aktinson_`race' = 1 - g_mean_`race' / a_mean_`race'
    restore
}

// calculate the Gini coefficients
// for the entire sample
cumul hhinc [aw=weight], g(Fy) // calculate the probability of income below hhinc
quietly corr hhinc Fy [aw=weight], c // calculate the covariance between hhinc and Fy
scalar cov = r(cov_12)
scalar g = 2 * cov / a_mean // calcualte gini coefficients

//for different races
foreach race in 1 2 3 4 5 {
    preserve
    keep if race == `race'
    cumul hhinc [aw=weight], gen(Fy_race)
    quietly corr hhinc Fy_race [aw=weight], c
    scalar cov_`race' = r(cov_12)
    scalar g_`race' = 2 * cov_`race' / a_mean_`race'
    restore
} 

// create a table to store the results
matrix results = (g, g_1, g_2, g_3, g_4, g_5 \ ///
                  theil_L, theil_L_1, theil_L_2, theil_L_3, theil_L_4, theil_L_5 \ ///
                  aktinson, aktinson_1, aktinson_2, aktinson_3, aktinson_4, aktinson_5)

matrix colnames results = "Population" White Black Latinx Asian Other
matrix rownames results = "Gini" "Theil L" "Aktinson (e=1)"

matlist results, format(%15.4f)


// 3) calculate mean median ratio
// for the entire sample
quietly sum hhinc [aw=weight], d
scalar median_inc = r(p50)
// for each race
foreach race in 1 2 3 4 5 {
	quietly sum hhinc [aw=weight] if race == `race', d
	scalar median_inc_`race' = r(p50)
} //White Black Latinx Asian Other

// create a table to store the means and medians
matrix results_1 = (a_mean, a_mean_1, a_mean_2, a_mean_3, a_mean_4, a_mean_5 \ ///
                   median_inc, median_inc_1, median_inc_2, median_inc_3, median_inc_4, median_inc_5)

matrix colnames results_1 = "Population" "White" "Black" "Latinx" "Asian" "Other"
matrix rownames results_1 = "Mean Income" "Median Income"

matlist results_1, format(%15.4f)


// Q3
// decompose Gini
foreach k in "transferinc" "retireinc" "propertyinc" "otherinc" "earnedinc" {
	preserve
    // calculate the covariance between `k' and Fy
	quietly corr `k' Fy [aw=weight], c
	scalar cov_`k'_fy = r(cov_12)
    // calculate the covariance between `k' and Fy_k
    cumul `k' [aw=weight], gen(Fy_k)
	quietly corr `k' Fy_k [aw=weight], c
	scalar cov_`k'_fyk = r(cov_12)
    // calculate the gini correlation
	scalar r_`k' = cov_`k'_fy / cov_`k'_fyk 
    // calculate the mean of this source of income
	quietly ameans `k' [aw=weight]
	scalar u_`k' = r(mean) 
    // calculate the gini coefficient for this source
	scalar g_`k' = 2 * cov_`k'_fyk / u_`k'
    // calculate the share of this source of income
	scalar s_`k' = u_`k' / a_mean
    // calculate the contribution of this source to the overall gini
	scalar contribution_`k' = r_`k' * g_`k' * s_`k' / g
	restore
}

matrix results_2 = (r_transferinc, g_transferinc, s_transferinc, contribution_transferinc \ ///
                    r_retireinc, g_retireinc, s_retireinc, contribution_retireinc \ ///
                    r_propertyinc, g_propertyinc, s_propertyinc, contribution_propertyinc \ ///
                    r_otherinc, g_otherinc, s_otherinc, contribution_otherinc \ ///
                    r_earnedinc, g_earnedinc, s_earnedinc, contribution_earnedinc)

matrix colnames results_2 = "Gini Correlation" "Gini Coefficient" "Share" "Contribution"
matrix rownames results_2 = "Transfer Income" "Retire Income" "Property Income" "Other Income" "Earned Income"

matlist results_2, format(%15.4f)



