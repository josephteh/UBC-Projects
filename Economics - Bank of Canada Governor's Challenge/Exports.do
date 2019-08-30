***International merchandise trade by commodity, chained 2012 dollars, quarterly (x 1,000,000)***

********************************************

*Source: https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=1210012401

********************************************

clear all
cd "/Users/josephteh/Desktop/ECON 492F/Overview/Exports"
import delimited "exports.csv", clear

generate date = date(ref_date, "YM")
generate qtr = qofd(date)
format qtr %tq

keep if trade=="Export"
drop if vector=="v1001808793"

//Commodity exports include:
	//Fisheries - v1001808794
	//Energy - v1001808795
	//Metal ores and non-metallic minerals - v1001808796
	//Metal and non-metallic mineral products - v1001808797
	//Forestry products and building and packaging materials - v1001808799
	
//Non-commodity exports include:
	//Basic and industrial chemical, plastic and rubber products - v1001808798
	//Industrial machinery, equipment and parts - v1001808800
	//Electronic and electrical equipment and parts - v1001808801
	//Motor vehicles and parts - v1001808802
	//Aircraft and other transportation equipment and parts - v1001808803
	//Consumer goods - v1001808804
	//Special transactions trade - v1001808805
	//Other balance of payments adjustments - v1001808806
	
drop date ref_date geo dguid trade northamericanproductclassificati uom uom_id scalar_factor scalar_id coordinate status symbol terminated decimals
reshape wide value, i(qtr) j(vector) string

rename valuev1001808794 fisheries
rename valuev1001808795 energy
rename valuev1001808796 metal_ores
rename valuev1001808797 metal
rename valuev1001808799 forestry

rename valuev1001808798 chemical
rename valuev1001808800 machinery
rename valuev1001808801 electronics
rename valuev1001808802 auto
rename valuev1001808803 aircraft
rename valuev1001808804 consumer
rename valuev1001808805 special
rename valuev1001808806 other

generate comm = fisheries + energy + metal_ores + metal + forestry
generate noncomm = chemical + machinery + electronics + auto + aircraft + consumer + special + other 
label variable comm "Commodity Exports"
label variable noncomm "Non-Commodity Exports"
generate TOTAL = comm + noncomm

*Create an index
generate noncomm_index = noncomm/61514.598*100
tsset qtr
save "exports.dta", replace

*Combine with exchange rate
merge 1:1 qtr using "ceri-ceer.dta"
tsset qtr

replace ceer = ceer/112.6233333333*100

twoway (line noncomm_index ceer qtr if qtr>=tq(2017q1)), ytitle("Index, 2014 = 100") ///
xtitle("") title("Lower CAD has supported non-commodity exports") note("Bank of Canada, Statistics Canada, Team Calculations, Last Observation: 2018Q4") ///
legend(on order(1 "Non-Commodity Exports" 2 "Real Effective Exchange Rate"))

save "exports_ceer.dta", replace

