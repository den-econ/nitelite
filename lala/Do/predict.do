gen lnpdrb_predict=b_ols+(ols*ln_ntl) if year==2024
gen MAE=ln_pdrb-lnpdrb_predict
replace
gen RMSE=(MAE)^2


reg $y2 $x2 if year <2024, r 
predict yhat_ols
gen abs_error_ols = abs($y2 - yhat_ols)
summ abs_error_ols

reg $y2 $x2, r 
predict yhat2
gen abs_error2 = abs($y2 - yhat2)
summ abs_error2

twoway scatter $y2 yhat2 if year==2024

xtpmg $y2 $x2 if year < 2024, ec(imed) dfe replace
predict yhat_dfe
xtset prov period_num
gen abs_error_dfe = abs($y2 - yhat_dfe)
gen abs_error_dfe2 = abs(L.$y2 + yhat_dfe)
summ abs_error_dfe

bysort province: egen mae_prov = mean(abs(y - yhat))


twoway scatter MAE ln_ntl
twoway scatter abs_error ln_ntl if year==2024

egen sum_mae=total(MAE)
egen sum_mae2=sum(MAE)

br year quarter ln_ntl ln_pdrb
