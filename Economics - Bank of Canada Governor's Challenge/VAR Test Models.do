**Different VAR models and their forecasted results**

use "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/v_f/v_f.dta", clear

//VAR1 (This model has qoq for gdp growth, unemployment and exchange rate; yoy for oil price growth and inflation; level for policy rate)
	append using "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/v_f/Files/wti_ff.dta", force
	var infl growth_qoq rte unem_qoq er_qoq if date>=tq(1995q1), lags(1/4) exog(wti_yoy) //R^2 is 0.75
	varsoc //Optimal lag is 2
	var infl growth_qoq rte unem_qoq er_qoq if date>=tq(1995q1), lags(1/2) exog(wti_yoy) //R^2 is 0.70
	varstable //All eigenvalues within the unit circle
		//Fit
		predict infl_pred, xb
		twoway (line infl_pred infl date if date>=tq(1995q1)) 
		//Forecast
		fcast compute f1_, step(7)
	//Enter core inflation
	var infl_com growth_qoq rte unem_qoq er_qoq if date>=tq(1995q1), lags(1/4) exog(wti_yoy) //R^2 is 0.93
	varsoc 
	var infl_com growth_qoq rte unem_qoq er_qoq if date>=tq(1995q1), lags(1/2) exog(wti_yoy) //R^2 is 
	varstable
		//Fit
		predict infl_com_pred, xb
		twoway (line infl_com_pred infl_com date if date>=tq(1995q1)) 
		//Forecast
		fcast compute f2_, step(7)
		generate infl_tar = 2
	//Forecast
		twoway (line infl infl_com f1_infl f2_infl_com infl_tar date if date>=tq(2010q1)), title("CPI Inflation Forecasted by VAR Model") ytitle("Year-Over-Year %") xtitle("") ///
		legend(on order (1 "CPI Inflation" 2 "Core Inflation")) note("Data: CANSIM, FRED, EIA")
	save "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 5 - Presentation/var1.dta", replace


//VAR2 (This model has yoy for gdp growth, unemployment, exchange rate, oil price growth and inflation; level policy rate)
	append using "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/v_f/Files/wti_ff.dta", force
	var infl growth rte unem_yoy er_yoy if date>=tq(1995q1), lags(1/4) exog(wti_yoy) //R^2 is 0.76 //High R^2 for other variables too
	varsoc //Optimal lag is 3
	var infl growth rte unem_yoy er_yoy if date>=tq(1995q1), lags(1/3) exog(wti_yoy) //R^2 is 0.74 //High R^2 for other variables too
	varstable //All eigenvalues within the unit circle
		//Fit
		predict infl_pred, xb
		twoway (line infl_pred infl date if date>=tq(1995q1))
		//Forecast
		fcast compute f1_, step(7)
	//Enter core inflation
	var infl_com growth rte unem_yoy er_yoy if date>=tq(1995q1), lags(1/4) exog(wti_yoy) //R^2 is 0.94 //R^2 is high for other variables too
	varsoc //Optimal lag is 2
	var infl_com growth rte unem_yoy er_yoy  if date>=tq(1995q1), lags(1/2) exog(wti_yoy) //R^2 is 0.93 //R^2 is high for other variables too
	varstable //All eigenvalues within the unit circle
		//Fit
		predict infl_com_pred, xb
		twoway (line infl_com_pred infl_com date if date>=tq(1995q1)) 
		//Forecast
		fcast compute f2_, step(7)
		generate infl_tar = 2
	//Forecast
		twoway (line infl infl_com f1_infl f2_infl_com infl_tar date if date>=tq(2010q1)), title("CPI Inflation Forecasted by VAR Model") ytitle("Year-Over-Year %") xtitle("") ///
		legend(on order (1 "CPI Inflation" 2 "Core Inflation")) note("Data: CANSIM, FRED, EIA")
	//Comments
		//CPI inflation and core inflation movements seem to contradict each other

//VAR3 (This model has yoy for gdp growth, unemployment, exchange rate, oil price growth, inflation and policy rate)
	append using "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/v_f/Files/wti_ff.dta", force
	var infl growth rte_yoy unem_yoy er_yoy if date>=tq(1995q1), lags(1/4) exog(wti_yoy) //R^2 is 0.77
	varsoc //Optimal lag is 2
	var infl growth rte_yoy unem_yoy er_yoy if date>=tq(1995q1), lags(1/2) exog(wti_yoy) //R^2 is 0.73 //High R^2 for other variables too
	varstable //All eigenvalues within the unit circle
		//Fit
		predict infl_pred, xb
		twoway (line infl_pred infl date if date>=tq(1995q1))
		//Forecast
		fcast compute f1_, step(7)
	//Enter core inflation
	var infl_com growth rte_yoy unem_yoy er_yoy if date>=tq(1995q1), lags(1/4) exog(wti_yoy) //R^2 is 0.94 //R^2 is high for other variables too
	varsoc //Optimal lag is 2
	var infl_com growth rte_yoy unem_yoy er_yoy  if date>=tq(1995q1), lags(1/2) exog(wti_yoy) //R^2 is 0.93 //R^2 is high for other variables too
	varstable //All eigenvalues within the unit circle
		//Fit
		predict infl_com_pred, xb
		twoway (line infl_com_pred infl_com date if date>=tq(1995q1)) 
		//Forecast
		fcast compute f2_, step(7)
		generate infl_tar = 2
	//Forecast
		twoway (line infl infl_com f1_infl f2_infl_com infl_tar date if date>=tq(2010q1)), title("CPI Inflation Forecasted by VAR Model") ytitle("Year-Over-Year %") xtitle("") ///
		legend(on order (1 "CPI Inflation" 2 "Core Inflation")) note("Data: CANSIM, FRED, EIA")
		twoway (line growth f2_growth date if date>=tq(2010q1)), title("GDP Forecast") ytitle("Year-Over-Year %") xtitle("") ///
		legend(on order (1 "GDP" 2 "GDP Forecast")) note("Data: CANSIM, FRED, EIA")
	//Comments
		//CPI inflation and core inflation movements seem to contradict each other

//VAR4 (This model has qoq for gdp growth, unemployment, exchange rate, policy rate, oil price growth; yoy for inflation)
	append using "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/v_f/Files/wti_ff.dta", force
	var infl growth_qoq rte_qoq unem_qoq er_qoq if date>=tq(1995q1), lags(1/4) exog(wti_qoq) //R^2 is 0.68 //R^2 is low for other variables
	varsoc //Optimal lag is 1
	var infl growth_qoq rte_qoq unem_qoq er_qoq if date>=tq(1995q1), lags(1/1) exog(wti_qoq) //R^2 is 0.55 //R^2 is low for other variables
	varstable //All eigenvalues within the unit circle
		//Fit
		predict infl_pred, xb
		twoway (line infl_pred infl date if date>=tq(1995q1)) 
		//Forecast
		fcast compute f1_, step(7)
	//Enter core inflation
	var infl_com growth_qoq rte_qoq unem_qoq er_qoq if date>=tq(1995q1), lags(1/4) exog(wti_qoq) //R^2 is 0.94 //R^2 is low for other variables
	varsoc  //Optimal lag is 2
	var infl_com growth_qoq rte_qoq unem_qoq er_qoq if date>=tq(1995q1), lags(1/2) exog(wti_qoq) //R^2 is 0.93 //R^2 is low for other variables
	varstable
		//Fit
		predict infl_com_pred, xb
		twoway (line infl_com_pred infl_com date if date>=tq(1995q1)) 
		//Forecast
		fcast compute f2_, step(7)
		generate infl_tar = 2
	//Forecast
		twoway (line infl infl_com f1_infl f2_infl_com infl_tar date if date>=tq(2010q1)), title("CPI Inflation Forecasted by VAR Model") ytitle("Year-Over-Year %") xtitle("") ///
		legend(on order (1 "CPI Inflation" 2 "Core Inflation")) note("Data: CANSIM, FRED, EIA")
	//Comments
		//The far end of the tail actually seems nice
		
//VAR5 (This model has qoq for gdp growth, unemployment, exchange rate and policy rate; yoy for oil price growth and inflation)
	append using "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/v_f/Files/wti_ff.dta", force
	var infl growth_qoq rte_qoq unem_qoq er_qoq if date>=tq(1995q1), lags(1/4) exog(wti_yoy) //R^2 is 0.77 //R^2 is quite low for other variables
	varsoc //Optimal lag is 1
	var infl growth_qoq rte_qoq unem_qoq er_qoq if date>=tq(1995q1), lags(1/2) exog(wti_yoy) //R^2 is 0.70 //R^2 is low for other variables
	varstable //All eigenvalues within the unit circle
		//Fit
		predict infl_pred, xb
		twoway (line infl_pred infl date if date>=tq(1995q1)) 
		//Forecast
		fcast compute f1_, step(7) bs
	//Enter core inflation
	var infl_com growth_qoq rte_qoq unem_qoq er_qoq if date>=tq(1995q1), lags(1/4) exog(wti_yoy) //R^2 is 0.94 //R^2 low for other variables
	varsoc //Optimal lag is 2
	var infl_com growth_qoq rte_qoq unem_qoq er_qoq if date>=tq(1995q1), lags(1/2) exog(wti_yoy) //R^2 is 0.92 //R^2 low for other variables
	varstable
		//Fit
		predict infl_com_pred, xb
		twoway (line infl_com_pred infl_com date if date>=tq(1995q1)) 
		//Forecast
		fcast compute f2_, step(7) bs
		generate infl_tar = 2
	//Forecast
		twoway (line infl infl_com f1_infl f2_infl_com infl_tar date if date>=tq(2011q1), clcolor (dknavy maroon dknavy maroon black) clpattern(solid solid dash dash solid) clwidth(medium medium medthick medthick medium)), ///
		title("Inflation Forecasts by VAR Model") ytitle("Year-over-year % growth") xtitle("") ///
		legend(on order (1 "CPI Inflation" 2 "Core Inflation")) note("Data: CANSIM, FRED, EIA")
			//GDP and unemployment
			twoway (line growth_qoq f2_growth_qoq date if date>=tq(2017q1), clpattern(solid dash)), title("Canada GDP, Seasonally-Adjusted") subtitle("2018Q2 - 2019Q4") ytitle("Quarterly % growth") xtitle("") ///
			legend(on order(1 "GDP growth" 2 "Forecast")) note("Data: CANSIM")
			twoway (line wti_yoy date if date>=tq(2010q1)), title("Oil Price Growth") ytitle("Year-on-year % change") xtitle("") ///
			note("Data: FRED, EIA")
		twoway (line infl f1_infl f1_infl_UB f1_infl_LB date if date>=tq(2011q1), clcolor (dknavy dknavy maroon maroon) clpattern(solid dash dash dash) clwidth(medium medium medium medium)), ///
		title("Inflation Forecasts by VAR Model") ytitle("Year-over-year % growth") xtitle("") ///
		legend(on order (1 "CPI Inflation" 2 "Forecast" 3 "95% UB" 4 "95% LB")) note("Data: CANSIM, FRED, EIA")
	save "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 5 - Presentation/Files/var5.dta", replace
	use "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 5 - Presentation/Files/var5.dta", clear
	
	
		//Graphing unemployment
		//Inflation and unemployment
		twoway (scatter infl unem_sa) (lfit infl unem_sa) if date>=tq(1995q1), title("Inflation and Unemployment Rate") subtitle(1995-2018) ytitle("Year-over-year % inflation") xtitle("Unemployment Rate (%)") note("Data: CANSIM, FRED") legend(on order(1 "Values" 2 "Fitted"))
		//Forecast?
		var unem_sa, lags(1/4)
		varsoc
		var unem_sa, lags(1/2)
		varstable
			//Forecast
			fcast compute f1_, step(8)
			twoway (line unem_sa date if date>=tq(1990q1)), title("Unemployment Rate, Seasonally-Adjusted") subtitle("1990-2018") ytitle("Unemployment rate (%)") xtitle("") ///
			note("Data: FRED")
		
		
		//Graphing global oil price (and CPI inflation?)
		use "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/v_f/Files/wti_f2.dta", clear
			append using "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/v_f/Files/wti_f.dta", force
			drop qdate
			rename date3 date
			rename wti wti_eia
			keep if date>=tm(2018m8)
		save "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 5 - Presentation/Files/wti.dta", replace
		use "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 4 - Vector Autoregressions/Assignment/V2_Monthly/v2.dta", clear
		drop if date==tm(2018m8)
		append using "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 5 - Presentation/Files/wti.dta", force
		save "/Users/josephteh/Desktop/The Governor's Challenge/Summer Modules/Module 5 - Presentation/Files/wti.dta", replace
		replace wti_eia = 70.98 in 1256
		twoway (line wti wti_eia date if date>=tm(1995m1)), title("Crude Oil, Western Texas Intermediary (WTI)") legend(on order(1 "WTI" 2 "EIA Forecast")) ytitle("Spot Price") xtitle("") ///
		note("Data: FRED, EIA") 
		
		
		//Graphing for logarithms
		generate gdp_pic = gdp/1000000000
		twoway (line gdp_pic date if date>=tq(1995q1)), title("Gross Domestic Product (2007 Dollars)") subtitle("1995-2018") ///
		ytitle("Real GDP (CAD Billion)") xtitle("") note("Date: CANSIM")
		twoway (line cpi date if date>=tq(1995q1)), title("Consumer Price Index, Seasonally-Adjusted") subtitle("Base Year: 2002") ///
		ytitle("CPI") xtitle("") note("Data: CANSIM")
		
		
		//Inflation and policy rate
		twoway (line infl rte date if date>=tq(1995q1)), title("Inflation Rate and Policy Rate") ytitle("%") xtitle("Date") note("Data: CANSIM, FRED") legend(on order(1 "Inflation rate" 2 "Policy rate"))
		
