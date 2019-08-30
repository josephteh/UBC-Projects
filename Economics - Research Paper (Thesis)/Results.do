*************************************
*   ECON 494: Estimation results    *
*           By Joseph Teh           *
*           Data sources: 			*
*     Olken (2009), Tajima (2013)   *
*************************************

set mem 8g
set maxvar 10000 
set matsize 11000

cd "/Users/josephteh/Desktop/ECON 494/Product/Data"
use "TV_Teh.dta", clear

***************************
*label variable tvchannels "Number of TV channels"
*label variable floss "Direct signal strength"
*rename floss direct
*rename eloss signal

*drop TV7 LATIVI METRO GLOBAL TRANS eloss_tv7 eloss_lativi eloss_metro eloss_global eloss_trans
*rename eloss_tvri signal_tvri
*rename eloss_rcti signal_rcti
*rename eloss_tpi signal_tpi
*rename eloss_sctv signal_sctv
*rename eloss_indosiar signal_indosiar
*rename eloss_antv signal_antv

*label variable golkar1 "Golkar first in village"
*label variable pdip1 "PDIP first in village"
*label variable direct "Direct average signal strength"
*label variable logvillpop "Log of village population"
*label variable logdensvil "Log population density of village"
*label variable povrateksvil "Poverty rate in village"
*label variable relfractvil "Religious fractionalization in village"
*label variable ethfractvil "Ethnic fractionalization in village"
*label variable islam "Majority of village is Muslim"
*label variable urban "Village is urban"

*save "TV_Teh.dta", replace

replace tvchannels = tvchannels - 5
replace tvchannels = 0.0 if tvchannels < 0.0

***************************

global villagecontrols = "logvillpop logdensvil povrateksvil relfractvil ethfractvil mean_adulted_w00 totany islam"
global geography = "city_dist_w05 aspect4north aspect4east aspect4south urban"
global tv_strengths = "signal_tvri signal_rcti signal_sctv signal_antv signal_indosiar signal_tpi"
tab prov, gen(provdummy)
global tv = "TVRI TPI RCTI SCTV INDOSIAR ANTV"


*************************************
*   Table 1: Administrative units   *
*************************************

foreach var of varlist golkar1 pdip1 tvchannels signal direct $tv $tv_strengths $villagecontrols $geography{ 
drop if `var'==.
}
egen num_kab=group(kabnum)
egen num_kec=group(kecnum)
egen num_prop=group(prov)
gen num_des=25086
by kecnum, sort: egen vil_kec=count(num_des)

eststo clear
eststo: quietly estpost summ num_kab num_kec num_des vil9_kec, listwise
esttab using table1.tex, cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
label replace compress title("Administrative Units") nomtitle noobs nonumber


*************************************
* Table 2: Descriptive Statistics   *
*************************************

eststo clear
eststo: quietly estpost summ golkar1 pdip1 tvchannels signal direct $tv $tv_strengths $villagecontrols $geography, listwise
esttab using table2.tex, cells("count mean(fmt(2)) sd(fmt(2))") ///
label replace compress title("Descriptive Statistics") nomtitle noobs nonumber


*************************************
* Table 3: Existence of a 1st stage *
*************************************

eststo clear
eststo: quietly reg tvchannels signal direct $villagecontrols , robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Village controls "Yes", replace
estadd local Geographic controls "No", replace
eststo: quietly reg tvchannels signal direct $villagecontrols $geography , robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Village controls "Yes", replace
estadd local Geographic controls "Yes", replace
eststo: quietly reg tvchannels signal direct $villagecontrols $geography kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Village controls "Yes", replace
estadd local Geography "Yes", replace

esttab using table3.tex, b(3) se(3) nocons ar2 label replace compress ///
title("The effect of average signal strength on number of TV channels") ///
mtitles("OLS" "OLS" "OLS") addnotes("The number of channels and average strength are averaged at the subdistrict level.") ///
indicate("Village controls = $villagecontrols" "District FE = kabiddummy*" "Geographic controls = $geography")


**********************************************
*      Table 4: Main Results - Golkar        *
**********************************************

eststo clear

*2. 2SLS
eststo: quietly ivreg golkar1 $villagecontrols direct (tvchannels = signal) , robust cluster(kecnum)
estadd local District fixed effects "No" , replace
estadd local Province fixed effects "No" , replace
estadd local Village controls "Yes", replace
estadd local Geographic controls "No", replace

*2. 2SLS with geographic controls
eststo: quietly ivreg golkar1 $villagecontrols $geography direct (tvchannels = signal) , robust cluster(kecnum)
estadd local District fixed effects "No" , replace
estadd local Province fixed effects "No" , replace
estadd local Village controls "Yes", replace
estadd local Geographic controls "Yes", replace

*2. 2SLS with district fixed effects 
eststo: quietly ivreg golkar1 $villagecontrols $geography direct (tvchannels = signal) kabiddummy*, robust cluster(kecnum)
estadd local District fixed effects "Yes" , replace
estadd local Province fixed effects "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*4. MLE 
eststo: quietly ivprobit golkar1 $villagecontrols direct (tvchannels = signal), robust cluster(kecnum)
estadd local Province fixed effects "No" , replace
estadd local District fixed effects "No" , replace
estadd local Geography "No", replace
estadd local Village controls "Yes", replace

*4. MLE with geographic controls
eststo: quietly ivprobit golkar1 $villagecontrols $geography direct (tvchannels = signal), robust cluster(kecnum)
estadd local Province fixed effects "No" , replace
estadd local District fixed effects "No" , replace
estadd local Geography "Yes", replace
estadd local Village controls "Yes", replace

*4. MLE with province FE
eststo: quietly ivprobit golkar1 $villagecontrols $geography direct (tvchannels = signal) provdummy*, robust cluster(kecnum)
estadd local Province fixed effects "Yes" , replace
estadd local District fixed effects "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

esttab using table4.tex, b(3) se(3) nocons ar2 label replace compress ///
title("The effect of the number of channels on the probability of Golkar winning") ///
mtitles("IV" "IV" "IV" "MLE" "MLE" "MLE") addnotes("Standard errors are clustered at the subdistrict level") ///
indicate("Province fixed effects = provdummy*" "District fixed effects = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")

* Report here with the three ivreg equations; eststo clear above
*Reporting marginal effects*
quietly ivprobit golkar1 $villagecontrols direct (tvchannels = signal), robust cluster(kecnum)
eststo: quietly margins, dydx(tvchannels) predict(pr) post

quietly ivprobit golkar1 $villagecontrols $geography direct (tvchannels = signal), robust cluster(kecnum)
eststo: quietly margins, dydx(tvchannels) predict(pr) post

quietly ivprobit golkar1 $villagecontrols $geography direct (tvchannels = signal) provdummy*, robust cluster(kecnum)
eststo: quietly margins, dydx(tvchannels) predict(pr) post

esttab using table4_me.tex, b(3) se(3) nocons ar2 label replace compress ///
title("The effect of the number of channels on the probability of Golkar winning") ///
mtitles("IV" "IV" "IV" "MLE" "MLE" "MLE") addnotes("Standard errors are clustered at the subdistrict level") ///
indicate("District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")


**********************************************
*        Tables 5: Main Results - PDIP       *
**********************************************

eststo clear 

eststo: quietly ivreg pdip1 $villagecontrols direct (tvchannels = signal), robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "No", replace
estadd local Province FE "No", replace
estadd local Geography "No", replace

eststo: quietly ivreg pdip1 $villagecontrols $geography direct (tvchannels = signal), robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "No", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivreg pdip1 $villagecontrols $geography direct (tvchannels = signal) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit pdip1 $villagecontrols direct (tvchannels = signal), robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "No", replace
estadd local Geographic controls "No", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (tvchannels = signal), robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "No", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (tvchannels = signal) provdummy*, robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

esttab using table5.tex, b(3) se(3) nocons ar2 label replace compress ///
title("The effect of the number of channels on the probability of PDIP winning") ///
mtitles("IV" "IV" "IV" "MLE" "MLE" "MLE") addnotes("Standard errors are clustered at the subdistrict level") ///
indicate("Province FE = provdummy*" "District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")

* Report here with the three ivreg equations; eststo clear above
*Reporting marginal effects*

quietly ivprobit pdip1 $villagecontrols $geography direct (tvchannels = signal), robust cluster(kecnum)
eststo: quietly margins, dydx(tvchannels) predict(pr) post

quietly ivprobit pdip1 $villagecontrols $geography direct (tvchannels = signal), robust cluster(kecnum)
eststo: quietly margins, dydx(tvchannels) predict(pr) post

quietly ivprobit pdip1 $villagecontrols $geography direct (tvchannels = signal) provdummy*, robust cluster(kecnum)
eststo: quietly margins, dydx(tvchannels) predict(pr) post

esttab using table5_me.tex, b(3) se(3) nocons ar2 label replace compress ///
title("The effect of the number of channels on the probability of PDIP winning") ///
mtitles("IV" "IV" "IV" "MLE" "MLE" "MLE") addnotes("Standard errors are clustered at the subdistrict level" "Number of channels at subdistrict level") ///
indicate("District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")


**********************************************
* Table 6: Political bias (PDI-P only)        *
**********************************************

eststo clear 

*5. ANTV
eststo: quietly ivreg pdip1 $villagecontrols $geography direct (ANTV = signal_antv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (ANTV = signal_antv) provdummy*, robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*6. SCTV
eststo: quietly ivreg pdip1 $villagecontrols $geography direct (SCTV = signal_sctv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (SCTV = signal_sctv) provdummy*, robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

esttab using table6.tex, b(3) se(2) nocons ar2 label replace compress ///
title("The effect of specific channels on the probability of PDIP winning") ///
mtitles("IV" "MLE" "IV" "MLE") ///
addnotes("Standard errors are clustered at the subdistrict level") ///
indicate("Province FE = provdummy*" "District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")

* Reporting marginal effects * 

quietly ivprobit pdip1 $villagecontrols $geography direct (ANTV = signal_antv) provdummy*, robust cluster(kecnum)
eststo: quietly margins, dydx(ANTV) predict(pr) post

quietly ivprobit pdip1 $villagecontrols $geography direct (SCTV = signal_sctv) provdummy*, robust cluster(kecnum)
eststo: quietly margins, dydx(SCTV) predict(pr) post

esttab using table6_me.tex, b(3) se(2) nocons pr2 ar2 label replace compress ///
title("The effect of specific channels on the probability of PDIP winning") ///
mtitles("IV" "MLE" "IV" "MLE") ///
addnotes("Standard errors are clustered at the subdistrict level") ///
indicate("District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")

**********************************************
*      Table 7: Heterogenous Effects         *
**********************************************

*** Number of channels 
eststo clear 

gen antvchannels = ANTV*tvchannels
gen ivantvchannels = signal_antv*tvchannels

eststo: quietly ivreg pdip1 $villagecontrols $geography direct tvchannels (ANTV antvchannels = signal_antv ivantvchannels) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

gen sctvchannels = SCTV*tvchannels
gen ivsctvchannels = signal_sctv*tvchannels

eststo: quietly ivreg pdip1 $villagecontrols $geography direct tvchannels (SCTV sctvchannels = signal_sctv ivsctvchannels) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*** Urban

gen urban_int_antv = urban*ANTV
gen urban_int_sigantv = urban*signal_antv

eststo: ivreg pdip1 $villagecontrols $geography direct (ANTV urban_int_antv = signal_antv urban_int_sigantv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: ivprobit pdip1 $villagecontrols $geography direct (ANTV urban_int_antv = signal_antv urban_int_sigantv) provdummy*, robust cluster(kecnum)
estadd local District FE "No", replace
estadd local Province FE "Yes", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

gen urban_int_sctv = urban*SCTV
gen urban_int_sigsctv = urban*signal_sctv

eststo: quietly ivreg pdip1 $villagecontrols $geography direct (SCTV urban_int_sctv = signal_sctv urban_int_sigsctv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (SCTV urban_int_sctv = signal_sctv urban_int_sigsctv) provdummy*, robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*** Islam

gen islam_int_sctv = islam*SCTV
gen islam_int_sigsctv = islam*signal_sctv

eststo: quietly ivreg pdip1 $villagecontrols $geography direct (SCTV urban_int_sctv = signal_sctv urban_int_sigsctv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (SCTV urban_int_sctv = signal_sctv urban_int_sigsctv) provdummy*, robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace




**********************************************
*             Robustness checks              *
**********************************************

* 1. Addressing 'number of channels'
// Controlling for number of channels 
ivprobit pdip1 $villagecontrols $geography direct tvchannels (ANTV = signal_antv) provdummy*, robust cluster(kecnum)
ivprobit pdip1 $villagecontrols $geography tvchannels direct (SCTV = signal_sctv) provdummy*, robust cluster(kecnum)
ivreg pdip1 $villagecontrols $geography tvchannels direct (SCTV = signal_sctv) kabiddummy*, robust cluster(kecnum)

// Dropping 
eststo clear

eststo: quietly ivreg pdip1 $villagecontrols $geography floss (ANTV = eloss_antv) kabiddummy* if tvchannels>=4.0, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No", replace
estadd local Geography "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit pdip1 $villagecontrols $geography floss (ANTV = eloss_antv) provdummy* if tvchannels>=4.0, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "Yes", replace
estadd local Geography "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivreg pdip1 $villagecontrols $geography floss (SCTV = eloss_sctv) kabiddummy* if tvchannels>=4.0, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No", replace
estadd local Geography "Yes", replace
estadd local Village controls "Yes", replace

esttab using table8.tex, b(3) se(2) nocons ar2 label replace compress ///
title("The effect of specific channels on the probability of PDIP winning") ///
mtitles("IV" "MLE" "IV") ///
addnotes("The signal strength is at the subdistrict level." "Standard errors are clustered at the subdistrict level." "Corresponds to subsample of more than 4 channels.") ///
indicate("Province FE = provdummy*" "District FE = kabiddummy*" "Geography = $geography" "Village controls = $villagecontrols")

*2. Adding Islam to village controls - The narrative doesn't change
* Adding variable islam to $villagecontrols

eststo: quietly ivreg pdip1 $villagecontrols2 $geography floss (SCTV = eloss_sctv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Geography "Yes", replace
estadd local Village controls "Yes", replace
eststo: quietly ivreg pdip1 $villagecontrols2 $geography floss (SCTV = eloss_sctv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Geography "Yes", replace
estadd local Village controls "Yes", replace

*********************************
*Clustering at different levels *
*********************************

*Main results*
* Cluster at district level 

eststo clear

* Golkar
*1. 2SLS without district fixed effects
eststo: ivreg golkar1 $villagecontrols $geography floss (tvchannels = eloss), robust cluster(kabnum)
estadd local District FE "No" , replace
estadd local Province FE "No" , replace
estadd local Village controls "Yes", replace
estadd local Geographic controls "Yes", replace

*2. 2SLS with district fixed effects 
eststo: ivreg golkar1 $villagecontrols $geography floss (tvchannels = eloss) kabiddummy*, robust cluster(kabnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*4. MLE 
eststo: ivprobit golkar1 $villagecontrols $geography floss (tvchannels = eloss), robust cluster(kabnum)
estadd local Province FE "No" , replace
estadd local District FE "No" , replace
estadd local Geography "Yes", replace
estadd local Village controls "Yes", replace

*4. MLE with province FE
eststo: ivprobit golkar1 $villagecontrols $geography floss (tvchannels = eloss) provdummy*, robust cluster(kabnum)
estadd local Province FE "Yes" , replace
estadd local District FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

esttab using table3_pres.tex, b(3) se(2) nocons ar2 label replace compress ///
title("The effect of the number of channels on the probability of Golkar winning") ///
mtitles("IV" "IV" "MLE" "MLE") addnotes("Standard errors are clustered at the subdistrict level" "Number of channels at subdistrict level") ///
indicate("Province FE = provdummy*" "District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")


eststo clear

* PDIP

eststo: ivreg pdip1 $villagecontrols $geography floss (tvchannels = eloss), robust cluster(kabnum)
estadd local District FE "No" , replace
estadd local Province FE "No", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: ivreg pdip1 $villagecontrols $geography floss (tvchannels = eloss) kabiddummy*, robust cluster(kabnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: ivprobit pdip1 $villagecontrols $geography floss (tvchannels = eloss), robust cluster(kabnum)
estadd local District FE "No" , replace
estadd local Province FE "No", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: ivprobit pdip1 $villagecontrols $geography floss (tvchannels = eloss) provdummy*, robust cluster(kabnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes", replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

esttab using table5_pres.tex, b(3) se(2) nocons ar2 label replace compress ///
title("The effect of the number of channels on the probability of PDIP winning") ///
mtitles("IV" "IV" "MLE" "MLE") addnotes("Standard errors are clustered at the subdistrict level" "Number of channels at subdistrict level") ///
indicate("Province FE = provdummy*" "District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")


* Political bias

eststo clear

eststo: ivreg pdip1 $villagecontrols $geography floss (ANTV = eloss_antv) kabiddummy*, robust cluster(kabnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: ivprobit pdip1 $villagecontrols $geography floss (ANTV = eloss_antv) provdummy*, robust cluster(kabnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: ivreg pdip1 $villagecontrols $geography direct (SCTV = signal_sctv) kabiddummy*, robust cluster(kabnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: ivprobit pdip1 $villagecontrols $geography direct (SCTV = signal_sctv) provdummy*, robust cluster(kabnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

esttab using table7.tex, b(3) se(2) nocons ar2 label replace compress ///
title("The effect of specific channels on the probability of PDIP winning") ///
mtitles("IV" "MLE" "IV" "MLE") ///
addnotes("Standard errors are clustered at the subdistrict level" "Number of channels at subdistrict level") ///
indicate("Province FE = provdummy*" "District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")


**********************************************
*                  Appendix                  *
**********************************************

**********************************************
*              Appendix Table 1              *
**********************************************

eststo clear 
*1. TVRI
eststo: quietly ivreg pdip1 $villagecontrols $geography direct (TVRI = signal_tvri) kabiddummy*, robust cluster(kecnum)
estadd local Province fixed effects "No" , replace
estadd local District fixed effects "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace
eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (TVRI = signal_tvri) provdummy*, robust cluster(kecnum)
estadd local Province fixed effects "Yes" , replace
estadd local District fixed effects "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*2. RCTI
eststo: quietly ivreg pdip1 $villagecontrols $geography direct (RCTI = signal_rcti) kabiddummy*, robust cluster(kecnum)
estadd local Province fixed effects "No" , replace
estadd local District fixed effects "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace
eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (RCTI = signal_rcti) provdummy*, robust cluster(kecnum)
estadd local Province fixed effects "Yes" , replace
estadd local District fixed effects "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*6. Indosiar
eststo: quietly ivreg pdip1 $villagecontrols $geography direct (INDOSIAR = signal_indosiar) kabiddummy*, robust cluster(kecnum)
estadd local Province fixed effects "No" , replace
estadd local District fixed effects "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace
eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (INDOSIAR = signal_indosiar) provdummy*, robust cluster(kecnum)
estadd local Province fixed effects "Yes" , replace
estadd local District fixed effects "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*3. TPI
eststo: quietly ivreg pdip1 $villagecontrols $geography direct (TPI = signal_tpi) kabiddummy*, robust cluster(kecnum)
estadd local Province fixed effects "No" , replace
estadd local District fixed effects "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace
eststo: quietly ivprobit pdip1 $villagecontrols $geography direct (TPI = signal_tpi) provdummy*, robust cluster(kecnum)
estadd local Province fixed effects "Yes" , replace
estadd local District fixed effects "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

**********************************************
*           Appendix Table 2                 *
**********************************************

eststo clear 

*5. ANTV
eststo: quietly ivreg golkar1 $villagecontrols $geography direct (ANTV = signal_antv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit golkar1 $villagecontrols $geography direct (ANTV = signal_antv) provdummy*, robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

*6. SCTV
eststo: quietly ivreg golkar1 $villagecontrols $geography direct (SCTV = signal_sctv) kabiddummy*, robust cluster(kecnum)
estadd local District FE "Yes" , replace
estadd local Province FE "No" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

eststo: quietly ivprobit golkar1 $villagecontrols $geography direct (SCTV = signal_sctv) provdummy*, robust cluster(kecnum)
estadd local District FE "No" , replace
estadd local Province FE "Yes" , replace
estadd local Geographic controls "Yes", replace
estadd local Village controls "Yes", replace

esttab using appendix2.tex, b(3) se(2) nocons ar2 label replace compress ///
title("The effect of specific channels on the probability of PDIP winning") ///
mtitles("IV" "MLE" "IV" "MLE") ///
addnotes("Standard errors are clustered at the subdistrict level") ///
indicate("Province FE = provdummy*" "District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")

* Reporting marginal effects * 

quietly ivprobit golkar1 $villagecontrols $geography direct (ANTV = signal_antv) provdummy*, robust cluster(kecnum)
eststo: quietly margins, dydx(ANTV) predict(pr) post

quietly ivprobit golkar1 $villagecontrols $geography direct (SCTV = signal_sctv) provdummy*, robust cluster(kecnum)
eststo: quietly margins, dydx(SCTV) predict(pr) post

esttab using appendix2_me.tex, b(3) se(2) nocons pr2 ar2 label replace compress ///
title("The effect of specific channels on the probability of PDIP winning") ///
mtitles("IV" "MLE" "IV" "MLE") ///
addnotes("Standard errors are clustered at the subdistrict level") ///
indicate("District FE = kabiddummy*" "Geographic controls = $geography" "Village controls = $villagecontrols")
