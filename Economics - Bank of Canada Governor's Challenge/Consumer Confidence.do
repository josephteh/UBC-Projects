************************

*Consumer Confidence*

************************

clear all
cd "/Users/josephteh/Desktop/ECON 492F/Overview/GDP"
import excel "confidence.xls", sheet("confidence") firstrow clear

keep Description H J
rename Description date
rename H conf
rename J conf_prairies

gen time = _n
gen month = tm(2002m1) + _n - 1
format month %tm
drop time date

gen qtr = qofd(dofm(month))
format qtr %tq
drop month

collapse (mean) conf conf_prairies, by(qtr)
tsset qtr

generate diff = conf - conf_prairies
egen diff2 = mean(diff) if qtr<=tq(2018q3) & qtr>=tq(2017q1)
replace diff2 = 37.01141 in 68
replace diff2 = 37.01141 in 69
replace counterfactual = conf - diff2

twoway (line conf qtr if qtr>=tq(2016q1), tline(2018q1)), ///
title("Consumer confidence has dampened") ytitle("") xtitle("") legend(on order(1 "consumer confidence index, 2014=100")) ///
note("Source: Conference Board of Canada")

save "confidence.dta", replace
