***CEER: Real Canadian Effective Exchange Rate Index***

********************************************

*Source: https://www.bankofcanada.ca/rates/exchange/canadian-effective-exchange-rates
*Download 'Monthly Real' in .csv and covert to .xls for data modification purposes

********************************************

clear all
cd "/Users/josephteh/Desktop/ECON 492F/Model/Exchange Rate/Data"
import excel "ceer_real.xls", sheet("ceer_real")
keep in 13/252
keep A D
rename A Date
rename D ceer
generate date2 = date(Date, "MDY")
generate qtr = qofd(date2)
format qtr %tq
drop Date date2
destring ceer, replace
collapse (mean) ceer, by(qtr)
label variable ceer "Real Effective Exchange Rate Index"

tsset qtr
drop if qtr<tq(1999q3)

save "ceer_real.dta", replace

***CERI: Nominal Canadian-Dollar Effective Exchange Rate Index***

********************************************

*Source: https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3310016301
*CANSIM Table 33-10-0163-01

********************************************

clear all
cd "/Users/josephteh/Desktop/ECON 492F/Model/Exchange Rate/Data"
import delimited "ceri_nom.csv", clear
keep if vector=="v111666277"
generate date = monthly(ref_date, "YM")
drop ref_date geo dguid typeofcurrency uom uom_id scalar_factor scalar_id coordinate status symbol terminated decimals
reshape wide value, i(date) j(vector) string
rename valuev111666277 ceri
generate qtr = qofd(dofm(date))
format qtr %tq
drop date
collapse (mean) ceri, by(qtr)

*Harmonize base year to match CEER's base year 1999
*Divide by CERI 1999q3 value, multiply by CEER 1999q3 value
generate ceri_new = ceri/83.600105
replace ceri_new = ceri_new*100.3733333333
drop ceri
rename ceri_new ceri

tsset qtr
drop if qtr>=tq(1999q3)
label variable ceri "Nominal Effective Exchange Rate Index"

save "ceri_nom.dta", replace


***Combining CEER and CERI***

********************************************

clear all
cd "/Users/josephteh/Desktop/ECON 492F/Model/Exchange Rate/Data"

use "ceri_nom.dta", clear
rename ceri ceer
append using "ceer_real.dta", force
tsset qtr
twoway (line ceer qtr)
generate lceer = ln(ceer)
generate dln_ceer = d.lceer*100
label variable dln_ceer "Log Difference - Effective Exchange Rate Index"
label variable ceer "Real Effective Exchange Rate"
twoway (line dln_ceer qtr)
drop if qtr<tq(1990q1)

save "ceri-ceer.dta", replace

*Analysis
twoway (line ceer qtr if qtr>=tq(2017q1))



	



