/*==============================================================================
|                             Nighttime Light and GDRP                         |
|------------------------------------------------------------------------------|
|  Written by : Meizahra Afidatie                                              |
|  Edited by : Krisna Gupta                                              |
|  Created    : October 2025                                                   |
|------------------------------------------------------------------------------|
|  Source     :                                                                |
==============================================================================*/

***********
*DATA PATH*
***********

gl user = c(username)
*path lala*	
//if "$user" == "meizahra"{
//	gl path "/Users/meizahra/Documents/nitelite"
//	}

gl path "C:\users\imedk\github\nitelite"
gl folder	"$path/Lala"
gl data 	"$folder/raw"
gl output 	"$folder/dat"
gl reg		"$folder/reg"		
gl do	 	"$folder/Do"		

set more off

*-------------------------------------------------------------------------------
* Cleaning GDRP
*-------------------------------------------------------------------------------

*----- Nominal GDRP Data -----*
import excel "$data/PDRB Seluruh Provinsi ADHK 2010-2025.xlsx", sheet("Level") firstrow clear

reshape long year_, i(prov) j(period, string)
ren year_ pdrb
gen year = substr(period, 1,4)
gen quarter = substr(period, 6, 7)
destring year quarter, replace
encode period, gen(period_num)


gen yr = real(substr(period,1,4))
gen mon = real(substr(period,6,.))      // 3,6,9,12
gen qnum = mon/3                         // 1,2,3,4
gen period2 = yq(yr, qnum)
format period2 %tq

tempfile nominal
save `nominal'

*----- Growth GDRP Data -----*
import excel "$data/PDRB Seluruh Provinsi ADHK 2010-2025.xlsx", sheet("Growth") firstrow clear
reshape long year_, i(prov) j(period, string)
ren year_ growth_qoq
gen year = substr(period, 1,4)
gen quarter = substr(period, 6, 7)
destring year quarter, replace

drop if prov==.
tempfile growth
save `growth'
 
merge 1:1 prov year quarter using `nominal'
drop _m

tempfile pdrb
save `pdrb'

*-------------------------------------------------------------------------------
* Cleaning NTL
*-------------------------------------------------------------------------------
import excel "$data/ntl_monthly_long.xlsx", sheet("Sheet1") firstrow clear	

gen quarter=.
replace quarter=3 if inrange(month, 1, 3)
replace quarter=6 if inrange(month, 4,6)
replace quarter=9 if inrange(month, 7,9)
replace quarter=12 if inrange(month, 10, 12)

collapse (mean) ntl_radiance, by(prov year quarter)

merge 1:1 prov year quarter using `pdrb' //Merging NTL with GDRP

*----- Additional Vars -----*
g		q1=0
replace	q1=1 if quarter==3 

gen		q2=0
replace	q2=1 if quarter==6

gen 	q3=0
replace	q3=1 if quarter==9 //Quarter dummy

g		covid=0
replace	covid=1 if inrange(year, 2020, 2022) //Covid dummy

gen covid_cont = 0
replace covid_cont = year - 2019 if inrange(year, 2020, 2022)

g		scarring=0
replace scarring=1 if inrange(year, 2020, 2025) //Scarring dummy

gen scar_cont = 0
replace scar_cont = year - 2019 if inrange(year, 2020, 2025)

g 		ln_ntl = ln(ntl_radiance)
g 		ln_pdrb = ln(pdrb) //ln variables

gen pulau = .
    replace pulau = 1 if inrange(prov,11,21)
    replace pulau = 2 if inrange(prov,31,36)
    replace pulau = 3 if inrange(prov,51,53)
    replace pulau = 4 if inrange(prov,61,65)
    replace pulau = 5 if inrange(prov,71,76)
    replace pulau = 6 if inrange(prov,81,82)
    replace pulau = 7 if inrange(prov,91,97) //Island Variables

    label define pulau_lbl  1 "SUMATERA" 2 "JAWA" 3 "BALI & NUSA TENGGARA" ///
                            4 "KALIMANTAN" 5 "SULAWESI" 6 "MALUKU" 7 "PAPUA"
    label values pulau pulau_lbl
	

*-------------------------------------------------------------------------------
* Analysis
*-------------------------------------------------------------------------------
gl x "ntl_radiance"
gl x2 "ln_ntl"

gl y "pdrb" 
gl y2 "ln_pdrb"
gl co "covid" //"covid"
gl sc "scarring" //"scarring"

gl year "2024"
gl format "tex"
gl master "ntl_analysis_master"
gl dfe "ntl_analysis_dfefull"
gl ols "ntl_ols2"
gl fe "ntl_fe2"
gl twfe "ntl_twfe2"
gl pmg "ntl_pmg2"
// gl dfe "ntl_dfe2"
xx
*----- OLS -----* 
	** Generate Residual
// reg $y2 $x2, r 
// predict e, resid
// reg $y2 $x2
// predict e_std, rstandard

reg $y2 $x2 if year < $year, r
predict e, resid
predict yhat_ols
gen abs_error_ols = abs($y2 - yhat_ols) 
gen error_ols = ($y2 - yhat_ols) 
outreg2 using "$reg/$master.$format", replace addtext(OLS, plain) label

reg $y2 $x2 $co if year < $year, r 
predict e_ols_co, resid
predict yhat_ols_co
gen abs_error_ols_co = abs($y2 - yhat_ols_co) 
gen error_ols_co = ($y2 - yhat_ols_co) 
outreg2 using "$reg/$master.$format", append addtext(OLS, Covid) label

reg $y2 $x2 $sc if year < $year, r 
predict e_ols_sc, resid
predict yhat_ols_sc
gen abs_error_ols_sc = abs($y2 - yhat_ols_sc) 
gen error_ols_sc = ($y2 - yhat_ols_sc) 
outreg2 using "$reg/$master.$format", append addtext(OLS, Scarring) label

*----- FE -----*
xtset prov period_num

// xtreg $y2 $x2 if year < $year, fe cluster(prov)
// predict e_fe, e

xtreg $y2 $x2 if year < $year, fe cluster(prov)
predict e_fe, resid
predict yhat_fe
gen abs_error_fe = abs($y2 - yhat_fe) 
gen error_fe = ($y2 - yhat_fe) 
outreg2 using "$reg/$master.$format", append addtext(FE, plain) label

xtreg $y2 $x2 $co if year < $year, fe cluster(prov)
predict e_fe_co, resid
predict yhat_fe_co
gen abs_error_fe_co = abs($y2 - yhat_fe_co) 
gen error_fe_co = ($y2 - yhat_fe_co) 
outreg2 using "$reg/$master.$format", append addtext(FE, Covid) label

xtreg $y2 $x2 $sc if year < $year, fe cluster(prov)
predict e_fe_sc, resid
predict yhat_fe_sc
gen abs_error_fe_sc = abs($y2 - yhat_fe_sc) 
gen error_fe_sc = ($y2 - yhat_fe_sc) 
outreg2 using "$reg/$master.$format", append addtext(FE, Scarring) label

*----- TWFE -----* 
xtreg $y2 $x2 i.year if year < $year, fe cluster(prov) 
predict e_twfe, resid
predict yhat_twfe
gen abs_error_twfe = abs($y2 - yhat_twfe) 
gen error_twfe = ($y2 - yhat_twfe) 
outreg2 using "$reg/$master.$format", append addtext(TWFE, plain) label

xtreg $y2 $x2 $co i.year if year < $year, fe cluster(prov) 
predict e_twfe_co, resid
predict yhat_twfe_co
gen abs_error_twfe_co = abs($y2 - yhat_twfe_co) 
gen error_twfe_co = ($y2 - yhat_twfe_co)
outreg2 using "$reg/$master.$format", append addtext(TWFE, Covid) label

xtreg $y2 $x2 $sc i.year if year < $year, fe cluster(prov) 
predict e_twfe_sc, resid
predict yhat_twfe_sc
gen abs_error_twfe_sc = abs($y2 - yhat_twfe_sc) 
gen error_twfe_sc = ($y2 - yhat_twfe_sc) 
outreg2 using "$reg/$master.$format", append addtext(TWFE, Scarring) label

/*----- PMG -----* 
xtpmg d.$y2 d.$x2, lr(L.$y2 $x2) pmg replace
outreg2 using "$reg/$master.$format", append addtext(PMG, plain) label
outreg2 using "$reg/$pmg.$format", append addtext(PMG, plain) label
xtpmg d.$y2 d.$x2 d.$co, lr($y2 $x2 $co) pmg replace
outreg2 using "$reg/$master.$format", append addtext(PMG, Covid) label
outreg2 using "$reg/$pmg.$format", append addtext(PMG, Covid) label
xtpmg d.$y2 d.$x2 d.$sc, lr($y2 $x2 $sc) pmg replace
outreg2 using "$reg/$master.$format", append addtext(PMG, Scarring) label
outreg2 using "$reg/$pmg.$format", append addtext(PMG, Scarring) label
*/ 

/*----- DFE -----* 

xtpmg d.$y2 d.$x2 if year < $year, lr(L.$y2 $x2) dfe replace
predict dyhat_dfe
gen yhat_dfe = L.$y2 + dyhat_dfe
gen error_dfe= ($y2 - yhat_dfe)
outreg2 using "$reg/$master.$format", append addtext(DFE, plain) label
outreg2 using "$reg/$dfe.$format", append addtext(DFE, plain) label

xtpmg d.$y2 d.$x2 d.$co if year < $year, lr(L.$y2 $x2 $co) dfe replace
predict dyhat_dfe_co
gen yhat_dfe_co = L.$y2 + dyhat_dfe_co
gen error_dfe_co= ($y2 - yhat_dfe_co)
outreg2 using "$reg/$master.$format", append addtext(DFE, Covid) label
outreg2 using "$reg/$dfe.$format", append addtext(DFE, Covid) label

xtpmg d.$y2 d.$x2 d.$scif year < $year, lr(L.$y2 $x2 $sc) dfe replace
predict dyhat_dfe_sc
gen yhat_dfe_sc = L.$y2 + dyhat_dfe_sc
gen error_dfe_sc= ($y2 - yhat_dfe_sc)
outreg2 using "$reg/$master.$format", append addtext(DFE, Scarring) label
outreg2 using "$reg/$dfe.$format", append addtext(DFE, Scarring) label
*/

*----- DFE -----* 
xtpmg d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2, ///
      lr(L.$y2 $x2) ec(ec_dfe) replace dfe
predict yhat_dfe, xb
gen e_dfe = $y2 - yhat_dfe  
// predict dyhat_dfe
// gen yhat_dfe = L.$y2 + dyhat_dfe
// gen error_dfe= ($y2 - yhat_dfe)
outreg2 using "$reg/$dfe.$format", append addtext(DFE, plain) label

xtpmg d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$co d.L(1/4).$co, ///
      lr(L.$y2 $x2 $co) ec(ec_dfe_co) replace dfe
predict yhat_dfe_co, xb
gen e_dfe_co = $y2 - yhat_dfe_co  
// predict dyhat_dfe_co
// gen yhat_dfe_co = L.$y2 + dyhat_dfe_co
// gen error_dfe_co= ($y2 - yhat_dfe_co)
outreg2 using "$reg/$dfe.$format", append addtext(DFE, Covid) label

xtpmg d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$sc d.L(1/4).$sc, ///
      lr(L.$y2 $x2 $sc) ec(ec_dfe_sc) replace dfe
predict yhat_dfe_sc, xb
gen e_dfe_sc = $y2 - yhat_dfe_sc  
// predict dyhat_dfe_sc
// gen yhat_dfe_sc = L.$y2 + dyhat_dfe_sc
// gen error_dfe_sc= ($y2 - yhat_dfe_sc)
outreg2 using "$reg/$dfe.$format", append addtext(DFE, Scarring) label


sa "$output/ntl_gdrp.dta", replace
// export excel "$output/ntl_gdrp.xls",  firstrow(variables) replace

*------ MG -----*

xtdcce2 d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$sc d.L(1/4).$sc, ///
      lr(L.$y2 $x2 $sc) nocrosssectional

*----- PMG -----*	  
	  
xtdcce2 d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$sc d.L(1/4).$sc, ///
      lr(L.$y2 $x2 $sc) nocrosssectional pooled(L.$y2 $x2)	  
