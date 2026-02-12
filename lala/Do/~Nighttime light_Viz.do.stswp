/*==============================================================================
|                       Nighttime Light and GDRP Data Viz                      |
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
*path lala*	
if "$user" == "meizahra"{
	gl path "/Users/meizahra/Documents/nitelite"
	}

gl folder	"$path/Lala"
gl data 	"$folder/raw"
gl output 	"$folder/dat"
gl reg		"$folder/reg"		
gl do	 	"$folder/Do"		
gl fig 		"$folder/fig"

set more off

use "$output/ntl_gdrp.dta", replace

*-------------------------------------------------------------------------------
* Scatter Plot
*-------------------------------------------------------------------------------
regress ln_ntl ln_pdrb if !missing(ln_ntl, ln_pdrb)
local coeff : display %6.3f _b[ln_pdrb]
local r2    : display %6.3f e(r2)
local N     = e(N)

twoway ///
    (lfit ln_ntl ln_pdrb, lcolor(black) lwidth(medthick)) ///
    (scatter ln_ntl ln_pdrb if pulau==1, msymbol(circle) mcolor("240 162 46"%40)) ///
(scatter ln_ntl ln_pdrb if pulau==2, msymbol(circle) mcolor("165 100 78"%40)) ///
(scatter ln_ntl ln_pdrb if pulau==3, msymbol(circle) mcolor("192 0 0"%40)) ///
(scatter ln_ntl ln_pdrb if pulau==4, msymbol(circle) mcolor("161 149 116"%40)) ///
(scatter ln_ntl ln_pdrb if pulau==5, msymbol(circle) mcolor("58 58 58"%40)) ///
(scatter ln_ntl ln_pdrb if pulau==6, msymbol(circle) mcolor("195 152 109"%40)) ///
(scatter ln_ntl ln_pdrb if pulau==7, msymbol(circle) mcolor("181 139 128"%40)), ///
    title("Night-time Light vs. Regional GDP (ln)", size(small)) ///
    note("Coeff: `coeff'; R-squared = `r2' (N=`N')", size(vsmall)) ///
    ytitle("Regional GDP (ln)", size(vsmall)) ///
    xtitle("Night-time Light (ln)", size(vsmall)) ///
    ylabel(, labsize(vsmall)) ///
    xlabel(, labsize(vsmall)) ///
    xscale(extend) yscale(extend) ///
    plotregion(margin(6 10 6 10)) ///
    graphregion(margin(3 3 3 3)) ///
    legend(order(2 "Sumatera" 3 "Jawa" 4 "Bali & Nusa Tenggara" 5 "Kalimantan" 6 "Sulawesi" 7 "Maluku" 8 "Papua") ///
           size(small) position(6) row(1))
graph export "$fig/scatter_ntl.png", replace
xx

* ---- Scatter Residual ---- *
	*** e vs. pdrb ***
scatter e ln_pdrb, ///
    yline(0, lcolor(red) lpattern(dash)) ///
    title("Residual vs. ln(GDRP)") ///
    ytitle("Residual (Error Term)") ///
    xtitle("ln(GDRP)") ///
    mcolor(navy%50) msymbol(circle)
graph export "$fig/scatter_e_pdrb.png", replace

	*** e vs. ntl ***
scatter e ln_ntl, ///
    yline(0, lcolor(red) lpattern(dash)) ///
    title("Residual vs. ln(NTL)") ///
    ytitle("Residual (Error Term)") ///
    xtitle("ln(NTL)") ///
    mcolor(navy%50) msymbol(circle)
graph export "$fig/scatter_e_ntl.png", replace

	*** e vs. ntl ***
scatter e_fe ln_ntl, ///
    yline(0, lcolor(red) lpattern(dash)) ///
    title("Residual (FE Model) vs. ln(NTL)") ///
    ytitle("Residual (Error Term)") ///
    xtitle("ln(NTL)") ///
    mcolor(navy%50) msymbol(circle)
graph export "$fig/scatter_efe_ntl.png", replace
		   