******************************
*        Tajima Data         *
******************************

cd "/Users/josephteh/Desktop/ECON 494/Data/Tajima data"
use "podes05.dta", clear

******************************
*        Format kec          *
******************************

tostring kecid05, gen(ID2005) format("%12.0f")
replace ID2005 = ID2005 + substr("0000", 1, 10 - length(ID2005))
save "podes05.dta", replace

******************************
*  Merge with BPS Crosswalks *
******************************

use "BPS_crosswalks_1998_2011.dta", clear

keep if JML_KEC==1
keep ID2005 NM2005
duplicates report ID2005
duplicates drop ID2005, force
replace NM2005 = subinstr(NM2005," ","",.)
duplicates report NM2005
duplicates drop NM2005, force
drop if missing(ID2005)
drop if missing(NM2005)

merge 1:m ID2005 using "podes05.dta"
keep if _merge==3
rename NM2005 name
drop _merge

save "podes_tajima.dta", replace

******************************
*      Merge with Olken      *
******************************

use "podes_olken2.dta", clear
duplicates report name
duplicates drop name, force

merge 1:m name using "podes_tajima.dta"
keep if _merge==3
sort kec

save "podes_tajima_olken.dta", replace

******************************
*          Clean             *
******************************

use "podes_tajima_olken.dta", clear
drop id1990
rename name kecname
label variable kecname "Name of kecamatan"
drop elosspanel flosspanel wavenum
rename tvmaxtveloss5~A eloss_tvri
rename tvmaxtveloss5~B eloss_rcti
rename tvmaxtveloss5~C eloss_sctv
rename tvmaxtveloss5~D eloss_antv
rename tvmaxtveloss5~E eloss_indosiar
rename tvmaxtveloss5~F eloss_metro
rename tvmaxtveloss5~G eloss_tv7
rename tvmaxtveloss5~H eloss_trans
rename tvmaxtveloss5~I eloss_tpi
rename tvmaxtveloss5~J eloss_lativi
rename tvmaxtveloss5~K eloss_global
drop log_adultpop~90 pop_agric_w90 schools_w90 num_mosques_w90 num_musholla~90 otherreligio~90 sports_w90 arts_w90 soc_w90 youth_w90 coastal_w90 c_citypath_km
drop kabid
rename kabidwave kabnum
label variable kabnum "Kabupaten code"
rename kec kecnum

label variable ethfractvil "Ethnic fractionalization (Village)"
label variable relfractvil "Religious fractionalization (Village)"

drop kabid03
drop kecid05
rename ID2005 kecid05

order kecid05 prop kabid05, b(kecname)
order golkar1 pdip1 golkar1_05 pdip1_05, a(totany)
order totany, b(povrateksvil)
order prop kabid05, b(kecid05)
order kabnum, a(kabid05)
order kecnum, a(kecname)

tostring kabid05, generate(kab) format("%12.0f")
order kab, b(kabid05)
drop kabid05
rename kab kabid05

tostring prop, generate(prov) format("%12.0f")
order prov, b(prop)
drop prop

order kecnum, a(kecid05)

label variable kabid05 "Kabupaten PODES ID"
label variable kecid05 "Kecamatan PODES ID"

*************************************
*      Re-label some variables      *
*************************************
rename TV_TVRI_w05 TVRI
rename TV_TRANS_w05 TRANS
rename TV_TPI_w05 TPI
rename TV_RCTI_w05 RCTI
rename TV_SCTV_w05 SCTV
rename TV_INDOSIAR_w05 INDOSIAR
rename TV_TV7_w05 TV7
rename TV_GLOBAL_w05 GLOBAL
rename TV_ANTV_w05 ANTV
rename TV_LATIVI_w05 LATIVI
rename TV_METRO_w05 METRO

label variable TVRI "Receive TVRI"
label variable TRANS "Receive TRANS"
label variable TPI "Receive TPI"
label variable RCTI "Receive RCTI"
label variable SCTV "Receive SCTV"
label variable INDOSIAR "Receive INDOSIAR"
label variable TV7 "Receive TV7"
label variable GLOBAL "Receive GLOBAL"
label variable ANTV "Receive ANTV"
label variable LATIVI "Receive LATIVI"
label variable METRO "Receive METRO"

order TVRI TRANS TPI RCTI SCTV INDOSIAR TV7 GLOBAL ANTV LATIVI METRO, a(floss)

save "podes_tajima_olken.dta", replace
























