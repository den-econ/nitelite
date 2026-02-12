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

use "$output/ntl_gdrp.dta", clear

*-------------------------------------------------------------------------------
* Scatterplot
*-------------------------------------------------------------------------------

local scat error_ols error_ols_co error_ols_sc error_fe error_fe_co error_fe_sc error_twfe error_twfe_co error_twfe_sc error_dfe error_dfe_co error_dfe_sc

local scat e e_twfe e_dfe

foreach x of local scat {

    twoway ///
        (scatter `x' ln_ntl if year==2024 & pulau==1, msymbol(circle) msize(small) mcolor("240 162 46"%40) mlcolor(none)) ///
        (scatter `x' ln_ntl if year==2024 & pulau==2, msymbol(circle) msize(small) mcolor("165 100 78"%40) mlcolor(none)) ///
        (scatter `x' ln_ntl if year==2024 & pulau==3, msymbol(circle) msize(small) mcolor("192 0 0"%40)  mlcolor(none)) ///
        (scatter `x' ln_ntl if year==2024 & pulau==4, msymbol(circle) msize(small) mcolor("161 149 116"%40) mlcolor(none)) ///
        (scatter `x' ln_ntl if year==2024 & pulau==5, msymbol(circle) msize(small) mcolor("58 58 58"%40)  mlcolor(none)) ///
        (scatter `x' ln_ntl if year==2024 & pulau==6, msymbol(circle) msize(small) mcolor("195 152 109"%40) mlcolor(none)) ///
        (scatter `x' ln_ntl if year==2024 & pulau==7, msymbol(circle) msize(small) mcolor("181 139 128"%40) mlcolor(none)) ///
        , ///
        title("`x' vs ln_ntl", size(small)) ///
        xtitle("Night-time light (ln)", size(vsmall)) ///
        ytitle("`x'", size(vsmall)) ///
        legend(order(1 "Sumatera" 2 "Jawa" 3 "Bali & Nusa Tenggara" 4 "Kalimantan" 5 "Sulawesi" 6 "Maluku" 7 "Papua") ///
               size(vsmall) rows(2) position(6) ring(0)) ///
        name(`x', replace)

    //graph export "$fig/`x'.png", replace
}

graph combine error_ols error_ols_co error_ols_sc, ///
    cols(2) imargin(tiny) ///
    graphregion(color(white))
	graph export "$fig/combine_ols.png", replace

	graph combine error_fe error_fe_co error_fe_sc, ///
    cols(2) imargin(tiny) ///
    graphregion(color(white))
	graph export "$fig/combine_fe.png", replace
	
graph combine error_twfe error_twfe_co error_twfe_sc, ///
    cols(2) imargin(tiny) ///
    graphregion(color(white))
		graph export "$fig/combine_twfe.png", replace
		
graph combine error_dfe error_dfe_co error_dfe_sc, ///
    cols(2) imargin(tiny) ///
    graphregion(color(white))
		graph export "$fig/combine_dfe.png", replace	
		
		
		graph combine error_ols_sc error_twfe_sc, ///
    cols(2) imargin(tiny) ///
    graphregion(color(white))
	graph export "$fig/combine_ols_twfe.png", replace


