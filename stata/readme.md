Provincial pipeline (Stata) for *"Forecasting Indonesian National and Provincial GDP using Nighttime Light Index."*

Migrated from `imedk/github/nitelite/lala/` on 2026-04-14. Authored by Meizahra Afidatie.

- `Do/Nighttime Light_Reg.do` — provincial OLS, FE, TWFE, DFE (`xtpmg`), MG and PMG (`xtdcce2`), plus Hausman test for PMG vs MG.
- `Do/Nighttime light_Viz.do` — companion visualization script.
- `raw/` — provincial GDRP and NTL source spreadsheets.
- `dat/` — cleaned merged dataset (`ntl_gdrp.dta`).
- `reg/` — `outreg2` output (`ntl_analysis_master.xls`); the matching `.tex` lives in the repo root.

Path globals at the top of each `.do` file dispatch on `c(username)`. Add a new branch for any additional user.
