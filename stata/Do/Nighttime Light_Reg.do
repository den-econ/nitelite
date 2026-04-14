/*==============================================================================
|                             Nighttime Light and GDRP                         |
|------------------------------------------------------------------------------|
|  Written by : Meizahra Afidatie                                              |
|  Created    : October 2025                                                   |
|------------------------------------------------------------------------------|
|  Source     :                                                                |
==============================================================================*/

***********
*DATA PATH*
***********

gl user = c(username)
*path lala (original)*
if "$user" == "meizahra"{
	gl path "/Users/meizahra/Documents/nitelite"
	gl folder "$path/Lala"
	}
*path nitelite2 (migrated copy)*
if "$user" == "imedk"{
	gl folder "C:/Users/imedk/github/nitelite2/stata"
	}

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

gl year "2026"
gl format "xls"
gl master "ntl_analysis_master"
gl dfe "ntl_analysis_ardlv3"
gl ols "ntl_ols2"
gl fe "ntl_fe2"
gl twfe "ntl_twfe2"
gl pmg "ntl_pmg2"


*----- OLS -----* 

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


*----- DFE -----* 
xtpmg d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 if year < $year, ///
      lr(L.$y2 $x2) ec(ec_dfe) replace dfe
predict yhat_dfe, xb
gen e_dfe = $y2 - yhat_dfe  
outreg2 using "$reg/$master.$format", append addtext(DFE, plain) label

xtpmg d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$co d.L(1/4).$co if year < $year, ///
      lr(L.$y2 $x2 $co) ec(ec_dfe_co) replace dfe
predict yhat_dfe_co, xb
gen e_dfe_co = $y2 - yhat_dfe_co  
outreg2 using "$reg/$master.$format", append addtext(DFE, Covid) label

xtpmg d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$sc d.L(1/4).$sc if year < $year, ///
      lr(L.$y2 $x2 $sc) ec(ec_dfe_sc) replace dfe
predict yhat_dfe_sc, xb
gen e_dfe_sc = $y2 - yhat_dfe_sc  
outreg2 using "$reg/$master.$format", append addtext(DFE, Scarring) label

*------ MG -----*
xtdcce2 d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2, ///
      lr(L.$y2 $x2) nocrosssectional
estimates store mg_base
predict yhat_mg, xb
gen e_mg = $y2 - yhat_mg
outreg2 using "$reg/$master.$format", append addtext(MG, Plain) label

xtdcce2 d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$co d.L(1/4).$co, ///
      lr(L.$y2 $x2 $co) nocrosssectional
estimates store mg_covid
predict yhat_mg_co, xb
gen e_mg_co = $y2 - yhat_mg_co
outreg2 using "$reg/$master.$format", append addtext(MG, Covid) label

xtdcce2 d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$sc d.L(1/4).$sc, ///
      lr(L.$y2 $x2 $sc) nocrosssectional
estimates store mg_scar
predict yhat_mg_sc, xb
gen e_mg_sc = $y2 - yhat_mg_sc
outreg2 using "$reg/$master.$format", append addtext(MG, Scarring) label

*----- PMG -----*
xtdcce2 d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2, ///
      lr(L.$y2 $x2) nocrosssectional pooled(L.$y2 $x2)
estimates store pmg_base
predict yhat_pmg, xb
gen e_pmg = $y2 - yhat_pmg
outreg2 using "$reg/$master.$format", append addtext(PMG, Plain) label

xtdcce2 d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$co d.L(1/4).$co, ///
      lr(L.$y2 $x2 $co) nocrosssectional pooled(L.$y2 $x2)
estimates store pmg_covid
predict yhat_pmg_co, xb
gen e_pmg_co = $y2 - yhat_pmg_co
outreg2 using "$reg/$master.$format", append addtext(PMG, Covid) label

xtdcce2 d.$y2 d.L(1/4).$y2 d.$x2 d.L(1/4).$x2 ///
      d.$sc d.L(1/4).$sc, ///
      lr(L.$y2 $x2 $sc) nocrosssectional pooled(L.$y2 $x2)
estimates store pmg_scar
predict yhat_pmg_sc, xb
gen e_pmg_sc = $y2 - yhat_pmg_sc
outreg2 using "$reg/$master.$format", append addtext(PMG, Scarring) label

*-------------------------------------------------------------------------------
* Hausman test: PMG vs MG (long-run homogeneity restriction)
*-------------------------------------------------------------------------------
* H0: long-run coefficients are common across provinces (PMG efficient & consistent)
* H1: long-run coefficients differ across provinces (only MG consistent)
* Reject H0 ==> use MG; fail to reject ==> PMG preferred (more efficient).
* `sigmamore` enforces a common variance estimate, recommended when xtdcce2 posts
* heterogeneous covariance matrices.

display _newline as text "=== Hausman test: PMG vs MG, baseline ==="
capture noisily hausman mg_base pmg_base, sigmamore
if _rc {
    display as error "Standard hausman failed (rc=" _rc "); see manual fallback below"
}

display _newline as text "=== Hausman test: PMG vs MG, +Covid ==="
capture noisily hausman mg_covid pmg_covid, sigmamore
if _rc {
    display as error "Standard hausman failed (rc=" _rc "); see manual fallback below"
}

display _newline as text "=== Hausman test: PMG vs MG, +Scarring ==="
capture noisily hausman mg_scar pmg_scar, sigmamore
if _rc {
    display as error "Standard hausman failed (rc=" _rc "); see manual fallback below"
}

* Manual quadratic-form fallback if `hausman` chokes on xtdcce2's e(V).
* Restrict the comparison to the long-run coefficient(s) of $x2 (and the relevant
* covid/scarring dummy where applicable). Adjust the column selectors to match
* the names xtdcce2 uses in e(b) for the long-run block (typically "lr_<varname>").
*
* Example for the baseline spec:
*   estimates restore mg_base
*   matrix b_mg  = e(b)
*   matrix V_mg  = e(V)
*   estimates restore pmg_base
*   matrix b_pmg = e(b)
*   matrix V_pmg = e(V)
*   matrix b_diff = b_mg - b_pmg
*   matrix V_diff = V_mg - V_pmg
*   scalar H = (b_diff * invsym(V_diff) * b_diff')[1,1]
*   scalar df = colsof(b_diff)
*   scalar p  = chi2tail(df, H)
*   display "Manual Hausman: chi2(" df ") = " H ", p = " p


sa "$output/ntl_gdrp.dta", replace
export excel "$output/ntl_gdrp.xls",  firstrow(variables) replace

