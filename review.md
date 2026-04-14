# Critical Review: "Forecasting Indonesian National and Provincial GDP using Nighttime Light Index"

## 1. Identification and Causality

The paper frames this as a forecasting/correlation exercise, which is appropriate. However, the language occasionally drifts into causal territory (e.g., "scarring effect *hurts* long-term growth by 2%"). The scarring dummy captures *any* level shift post-2020 — not just pandemic scarring. It could absorb changes in BPS methodology, commodity price shifts, structural reform effects, or other post-2020 phenomena. The coefficient on the scarring dummy cannot be interpreted as the causal effect of COVID-19.

## 2. The Scarring Dummy is Doing Too Much Work

The scarring dummy (=1 from 2020 onward) is essentially a post-2020 intercept shift. The ARDL models with scarring have dramatically better AIC/BIC (-428 vs -276), but this is mechanical: fitting a level break with a dummy in a 51-observation sample where ~20 observations are post-2020. The "best forecasting fit" claim is partly tautological — the model with the most flexible dummy structure fits best in-sample. The real test is out-of-sample, and while the paper shows this in Figure 5, the out-of-sample window is very short (only 2024 onward, ~4-6 quarters). That is too few observations to make strong claims about forecast quality.

## 3. Very Small Sample Size (National Level)

With N=51 quarterly observations at the national level and 4 lags of GDP + lags of NTL + dummies, the ARDL specifications are heavily parameterized relative to sample size. The +Scar specification has ~12 parameters for 51 observations. This raises concerns about overfitting and the reliability of standard errors. The degrees of freedom are thin.

## 4. NTL Coefficient Is Weak Where It Matters Most

In the preferred ARDL+Scar specification, NTL is only significant at 10%. In the regional DFE+Scarring model, short-run NTL dynamics are entirely insignificant. The paper's title promises "forecasting GDP using nighttime lights," but the models are really forecasting GDP using *its own lags and a post-2020 dummy*. NTL contributes marginally at best. This is an important finding but should be stated more directly.

## 5. Divergence During COVID Undermines the Core Premise

The paper notes that NTL didn't drop during COVID while GDP crashed. This is a fundamental problem for the NTL-as-GDP-proxy story. The explanation offered (cloud cover, electricity subsidies) is speculative and not tested. If NTL fails precisely when you need an independent GDP check the most (during crises), its value as a validation tool is limited. This deserves more emphasis.

## 6. Regional Analysis: Econometric Concerns

### Pooled OLS

The 0.56 coefficient in pooled OLS is driven by the *between*-province variation (Java vs Papua), not the *within*-province time variation that matters for forecasting. The paper mentions this but still presents OLS prominently.

### TWFE

Once province and time FE are controlled for, the NTL coefficient drops to 0.0547. This is actually the most informative specification — it tells you that *within* a province, *controlling for common time shocks*, NTL growth has almost no explanatory power for GDP growth.

### PMG/MG vs DFE: Homogeneity Restrictions

The long-run NTL coefficients across estimators:

| Estimator | Baseline | +Scarring |
|-----------|----------|-----------|
| DFE       | 0.332*** | 0.589**   |
| MG        | 0.486*** | -0.713    |
| PMG       | 0.374    | 0.426     |

DFE is the only estimator that finds significance in the +Scarring specification, and PMG fails to find significance even in the baseline. The paper does not discuss this inconsistency, which is a serious omission.

The three estimators differ in how much heterogeneity across provinces they allow:

- **DFE (Dynamic Fixed Effects)**: Forces *all* slope coefficients — both short-run dynamics and the long-run relationship — to be identical across all 34 provinces. Only the intercept varies. This is the most restrictive.
- **PMG (Pooled Mean Group)**: Forces the long-run coefficients to be identical across provinces, but allows short-run dynamics (adjustment speed, lag coefficients) to differ. This is Pesaran, Shin & Smith's (1999) intermediate estimator.
- **MG (Mean Group)**: Allows everything — both long-run and short-run coefficients — to differ by province. It estimates a separate ARDL for each province, then averages. This is the most flexible (and the least efficient).

If the true long-run relationship between NTL and GDP differs across provinces, then pooling (as DFE does) generates a spurious "average" coefficient that doesn't represent any actual province. The pooling mechanically reduces standard errors by treating 34 heterogeneous relationships as one, which inflates the t-statistic.

Concretely, Indonesian provinces are enormously heterogeneous:

- In Java, NTL and GDP are tightly linked — dense urban economies where light intensity tracks commercial activity well.
- In Kalimantan or Papua, GDP is driven by mining and resource extraction, which generates high output but relatively little nighttime light. The NTL-GDP elasticity there could be near zero or even negative in some quarters.
- In agricultural provinces (parts of Sulawesi, NTT), the relationship is different again.

When DFE forces a single $\beta_{NTL}$ across all 34 provinces, it estimates a weighted average of these heterogeneous elasticities. The "significance" of that average doesn't mean the relationship is significant *anywhere* — it means that the average is nonzero, which can happen even if most provinces have an insignificant or differently-signed relationship, as long as a few large provinces (Java) dominate the pooled estimate.

The PMG/MG results expose this:

- **MG baseline**: Significant (0.486\*\*\*). Province-by-province estimation averaged yields a positive, significant mean elasticity.
- **MG +Scarring**: Insignificant (-0.713). Once the scarring dummy is added, the province-specific NTL coefficients become so noisy that the average flips sign and loses significance. This suggests the NTL long-run relationship is fragile when heterogeneity is allowed.
- **PMG baseline**: Insignificant (0.374). Even with the efficiency gain from pooling the long-run coefficient, PMG can't reject zero. This is the strongest evidence against the DFE result — PMG is designed to be efficient *if* the long-run homogeneity assumption holds, so if even PMG can't find significance, the DFE result is likely driven by the *additional* restriction of short-run homogeneity.

In the Pesaran, Shin & Smith framework, the standard practice is to use a Hausman test to compare PMG vs MG. If the test rejects, the long-run homogeneity restriction is invalid and MG should be preferred. The paper does not report this Hausman test. Given that PMG and MG disagree with DFE on significance, the Hausman test would likely reveal that the homogeneity restrictions driving DFE's result are not supported by the data.

## 7. Unit Root / Cointegration Issues

- ADF on NTL levels fails to reject the null at 10% (p=0.26), confirming I(1). ADF on OLS residuals rejects at ~1% (p=0.009) but *not* at the 1% critical value (-3.46 vs -3.57). The cointegration evidence is borderline.
- The Johansen test rejects r=0, but with only two variables and 51 observations, the test has low power and can be unreliable.
- If cointegration is uncertain, the ARDL-in-levels approach is fine (Pesaran bounds testing is designed for this), but the paper doesn't report bounds test results, which would strengthen the argument.

## 8. What CAN Be Inferred

- NTL is *consistently positively correlated* with GDP across all specifications — this is robust.
- The magnitude of the association drops substantially once dynamics (ARDL) and fixed effects are controlled for, indicating the raw OLS is biased upward.
- There is a clear structural break around 2020 in the GDP series.
- NTL alone is insufficient as a GDP predictor, but may contribute marginally in a multi-variable nowcasting model.

## 9. What CANNOT Be Inferred

- That the scarring dummy captures the *causal* effect of COVID-19 on GDP.
- That the 2% scarring estimate is the magnitude of pandemic damage (vs. any other post-2020 shift).
- That NTL is a reliable *leading* indicator — the paper tests contemporaneous correlation, not Granger causality or true out-of-sample forecasting performance over a meaningful horizon.
- That the ARDL model has good forecasting power — the out-of-sample test is too short to conclude this.
- That the speed-of-convergence comparison (6.75 years baseline vs 14.75 years with scarring) reflects a genuine change in adjustment dynamics — the scarring dummy absorbs variation that inflates the half-life mechanically.

## 10. Suggestions

1. Report Pesaran bounds test statistics for the ARDL to formally establish cointegration.
2. Report the Hausman test for PMG vs MG and discuss why PMG/MG fail to confirm the NTL long-run relationship found in DFE.
3. Consider a recursive or rolling out-of-sample forecast exercise rather than a single train/test split.
4. Be more cautious with the scarring language — call it a "post-2020 level shift" and discuss alternative explanations.
5. Test whether NTL Granger-causes GDP (or vice versa) to support the "leading indicator" framing.
