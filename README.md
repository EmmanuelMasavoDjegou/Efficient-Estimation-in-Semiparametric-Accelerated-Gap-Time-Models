<p align="center">
  <img src="assets/header.svg" alt="Effective age under minimal, imperfect and perfect intervention" width="100%">
</p>

<h1 align="center">Efficient Estimation in Semiparametric Accelerated Gap-Time Models for Recurrent Event Data</h1>

<p align="center">
  <b>Emmanuel Djegou</b> &nbsp;·&nbsp; <b>Akim Adekpedjou</b><br>
  Department of Mathematics and Statistics, Missouri University of Science and Technology
</p>

<p align="center">
  <img src="https://img.shields.io/badge/MATLAB-estimation-0076A8" alt="MATLAB">
  <img src="https://img.shields.io/badge/R-analysis%20%26%20figures-276DC3" alt="R">
  <img src="https://img.shields.io/badge/status-manuscript%20under%20review-5C4D8A" alt="Status">
</p>

This repository contains the code for the simulation study and the real-data application in the paper *Efficient Estimation in Semiparametric Accelerated Gap-Time Models for Recurrent Event Data*.

---

## About the paper

**The problem.** Accelerated gap-time (AGT) models let covariates stretch or compress the time between recurrent events, but they assume every intervention restores a subject to a like-new state. Effective age models allow imperfect interventions, but there covariates act on the hazard, not on the time scale. No semiparametric model let covariates accelerate time when interventions are imperfect.

**The model.** Covariates rescale the effective age itself. Subject $i$ ages $e^{\beta_0^\top X_i}$ times faster than a baseline subject with the same intervention history, and the intensity of the next event is

$$\lambda_0\bigl\lbrace\mathcal{E}_i(s)\,e^{\beta_0^\top X_i}\bigr\rbrace\,e^{\beta_0^\top X_i},$$

where $\mathcal{E}_i(s)$ is the effective age and $\lambda_0$ is an unspecified baseline hazard.

| Intervention | Effective age $\mathcal{E}_i(s)$ | Special case |
|---|---|---|
| Minimal (as bad as old) | calendar time $s$ | semiparametric AFT model |
| Perfect (as good as new) | time since last event | semiparametric AGT model |
| Imperfect | e.g. Brown–Proschan, Kijima-type, linear effective ages | new |

**Main contributions**

- A change-of-variable from calendar time to the accelerated effective age, using doubly-indexed processes. It yields an at-risk process that depends on $\beta$.
- The efficient score and semiparametric information bounds for $\beta_0$ and the cumulative baseline hazard $\Lambda_0$.
- Weighted rank estimating functions derived from the efficient score:
  - The **Gehan** weight gives the gradient of a convex objective, which provides a consistent starting value.
  - A **one-step** update gives estimators under general weights such as **log-rank**.
- Consistency and asymptotic normality, with numerical variance estimators (Huang's method and a regression-based alternative).
- A Nelson–Aalen-type estimator of $\Lambda_0$ with a Gaussian process limit, and a Hausman-type goodness-of-fit test.

---

## Repository structure

```
.
├── 2.Simulation/                          # Monte Carlo simulation study (perfect-intervention model)
│   ├── simulation_sagt_model.m            # Data generation + Gehan and log-rank estimation (MATLAB)
│   ├── simulation_results_analysis.R      # Tables and figures from the simulation output (R)
│   ├── simulation_results.csv             # Per-replication estimates and variance estimates
│   └── simulation_results_extended.csv    # Summary statistics by sample size (bias, SD, SE, coverage)
│
├── 3.Application/                         # Colorectal cancer readmission data
│   ├── data_preprocessing.R               # Builds the model-ready data set data_cp.csv (R)
│   ├── application_sagt_model.m           # Model estimation (MATLAB)
│   ├── application_results_analysis.R     # Tables and figures from the application output (R)
│   └── application_results.pdf            # Estimation output
│
└── assets/
    └── header.svg                         # README header image
```

---

## Requirements

- **MATLAB.** Base MATLAB is enough for the core routines (`fminsearch`, `readtable`, `writetable`). Data generation uses `binornd` and `unifrnd`, which require the Statistics and Machine Learning Toolbox.
- **R** with the packages:
  - `frailtypack`, `survival`, `reReg`, `reda`, `dplyr`, `ggplot2` (application)
  - `ggplot2`, `dplyr`, `tidyr`, `kableExtra`, `gridExtra`, `RColorBrewer`, `viridis` (simulation figures)

---

## Reproducing the results

### Simulation study

1. Open `2.Simulation/simulation_sagt_model.m`. The settings are at the top of the file:
   - `n_values`: the sample sizes
   - `replications`
   - `B1`, `B2`: the resampling sizes
   - the Weibull parameters `alpha` and `gamma`
   - `tau_max`: the upper bound of the uniform follow-up time
2. Run the script. It writes:
   - `simulation_results_p.csv`: per-replication output
   - `extended_simulation_results_p.csv`: summary output

   The files `simulation_results.csv` and `simulation_results_extended.csv` in this folder are the outputs used in the paper.
3. Run `simulation_results_analysis.R` in the same folder to produce the tables and figures. It reads the two `*_p.csv` files, so rename the provided files if you want to reuse them without rerunning the simulation.

> Fitting is computationally intensive. Each replication involves a nonsmooth minimization, Huang's variance estimator and resampling for the one-step estimator, and the cost grows roughly quadratically with the sample size.

### Real-data application

The application uses the `readmission` data from the R package [`frailtypack`](https://CRAN.R-project.org/package=frailtypack): hospital readmissions of 403 colorectal cancer patients (González et al., 2005). The covariates are chemotherapy, Dukes' stage and sex.

1. Run `3.Application/data_preprocessing.R`. It writes `data_cp.csv`.
2. Run `3.Application/application_sagt_model.m` in the same folder.
3. Run `3.Application/application_results_analysis.R` for the tables and figures.

The analysis uses the perfect-intervention (AGT) specification as a working model, for illustration and as a benchmark for this data set. See Section 8 of the paper for a discussion of this choice.

---

## Citation

If you use this code, please cite:

```bibtex
@unpublished{DjegouAdekpedjou2026,
  author = {Djegou, Emmanuel and Adekpedjou, Akim},
  title  = {Efficient Estimation in Semiparametric Accelerated Gap-Time Models for Recurrent Event Data},
  year   = {2026},
  note   = {Manuscript under review}
}
```

## Contact

Akim Adekpedjou (corresponding author), akima@mst.edu
