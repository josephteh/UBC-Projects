

**********************
* Debt Service Ratio * 
* Table: 11-10-0065-01
* Source: https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1110006501
**********************

clear all
cd "/Users/josephteh/Desktop/ECON 492F/Model/Household Debt/Data"
import delimited "dsr.csv", clear
keep if vector=="v1001696804" | vector=="v1001696810" | vector=="v1001696813"
sort ref_date
generate date2 = monthly(ref_date, "YM")
generate qtr = qofd(dofm(date2))
format qtr %tq
drop  ref_date geo dguid seasonaladjustment estimates uom uom_id scalar_factor scalar_id coordinate status symbol terminated decimals date2

reshape wide value, i(qtr) j(vector) string
rename  valuev1001696804 debt
rename  valuev1001696810 interest
rename valuev1001696813 dsr

label variable debt "Total Debt Payments (Millions)"
label variable int "Total Interest Paid (Millions)"
label variable dsr "Debt Service Ratio (Total Debt Payments/Disposable Income)"

tsset qtr


*Stationary? 
dfuller dsr, lags(12) regress
generate d_dsr = d.dsr/l.dsr*100
label variable d_dsr "Quarterly % Change"

save debt.dta, replace 

*Graph debt service ratio

twoway (line dsr qtr if qtr>=tq(2016q1)), ///
title("Debt costs have increased") xtitle("") ytitle("") legend(on order(1 "debt service ratio")) note("Source: Statistics Canada")


*Annual

clear all
cd "/Users/josephteh/Desktop/ECON 492F/Model/Household Debt/Data"
import delimited "dsr.csv", clear
keep if vector=="v1001696813"
sort ref_date
generate date2 = monthly(ref_date, "YM")
generate year = yofd(dofm(date2))
drop ref_date geo dguid seasonaladjustment estimates uom uom_id scalar_factor scalar_id coordinate status symbol terminated decimals date2

collapse (mean) value, by(year)
rename value dsr

tsset year

twoway (line dsr year), ytitle("dsr") xtitle("")

save "dsr_yearly.dta", replace







