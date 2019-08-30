*****************************
* Merge PODES and Crosswalk *
*****************************

cd "/Users/josephteh/Desktop/ECON 494/Data"
use "kec_crosswalk.dta", clear

keep id1990 nm1990
drop if missing(id1990)
duplicates report id1990
duplicates drop id1990, force
duplicates report nm1990
duplicates drop nm1990, force
replace nm1990 = subinstr(nm1990," ","",.)

merge 1:1 id1990 using "podes_olken.dta"
keep if _merge==3

rename nm1990 name
drop _merge
save "podes_olken2.dta", replace


use "BPS_crosswalks_1998_2011", clear
	************Clean
	//1998
	keep if JML_KEC==1
	keep ID1998 NM1998
	duplicates report ID1998
	duplicates drop ID1998, force

	replace NM1998 = subinstr(NM1998," ","",.)

	rename ID1998 id1990
	save "bps1998.dta", replace

	//1999
	keep if JML_KEC==1
	keep ID1999 NM1999
	duplicates report ID1999
	duplicates drop ID1999, force

	replace NM1999 = subinstr(NM1999," ","",.)

	rename ID1999 id1990
	save "bps1999.dta", replace

	//2000
	keep if JML_KEC==1
	keep ID2000 NM2000
	duplicates report ID2000
	duplicates drop ID2000, force

	replace NM2000 = subinstr(NM2000," ","",.)

	rename ID2000 id1990
	save "bps2000.dta", replace

	//2001
	keep if JML_KEC==1
	keep ID2001 NM2001
	duplicates report ID2001
	duplicates drop ID2001, force

	replace NM2001 = subinstr(NM2001," ","",.)

	rename ID2001 id1990
	save "bps2001.dta", replace

	//2002
	keep if JML_KEC==1
	keep ID2002 NM2002
	duplicates report ID2002
	duplicates drop ID2002, force

	replace NM2002 = subinstr(NM2002," ","",.)

	rename ID2002 id1990
	save "bps2002.dta", replace

	//2003
	keep if JML_KEC==1
	keep ID2003 NM2003
	duplicates report ID2003
	duplicates drop ID2003, force

	replace NM2003 = subinstr(NM2003," ","",.)

	rename ID2003 id1990
	save "bps2003.dta", replace


	************Using 1999

	keep ID1999 NM1999
	drop if missing(ID1999)
	duplicates drop
	rename ID1999 id1990

	duplicates report id1990
	duplicates drop id1990, force

	merge 1:1 id1990 using "podesdata.dta"
	keep if _merge==3
	//1,435 matched

	rename NM1999 kecname 
	save "podescrosswalk.dta", replace

	************Using 2003

	keep ID2003 NM2003
	drop if missing(ID2003)
	duplicates drop
	rename ID2003 id1990

	duplicates report id1990
	duplicates drop id1990, force

	merge 1:1 id1990 using "podesdata.dta"
	keep if _merge==3

	rename NM2003 kecname 

save "podes_olken2.dta", replace










