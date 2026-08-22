# Efficient Estimation in Semiparametric Accelerated Gap-Time Models for Recurrent Event Data

This repository contains the code accompanying the paper *"Efficient Estimation in Semiparametric Accelerated Gap-Time Models for Recurrent Event Data"*

## Abstract

The accelerated failure time (AFT) model relates covariates to log-transformed event times under right censoring and extends naturally to recurrent events through the accelerated gap-time (AGT) formulation, providing a meaningful alternative to the Cox model. In many applications, such as reliability engineering and biomedical research, interventions between successive events may alter the timing of subsequent events, motivating models that explicitly accommodate such effects. We consider a broad class of semiparametric accelerated gap-time models for recurrent event data incorporating an effective age process, allowing a wide range of intervention mechanisms to be represented within a unified framework. To overcome estimation challenges arising from an infinite-dimensional baseline hazard and non-monotone score functions, we construct a sample-based weighted efficient score via parametric submodels. The resulting estimators are consistent and asymptotically normal. The proposed method is illustrated through simulation studies and an application to a biomedical dataset.

**Keywords:** Semiparametric models · Accelerated gap-time model · Efficient estimation · Survival analysis · Recurrent events · Incomplete follow-up

## Repository Structure

```
.
├── literature_review/     # Supporting literature review materials (see folder for details)
├── simulation/             # Monte Carlo simulation studies
│   ├── sagt_model.m
│   ├── simulation_results_analysis.R
│   ├── simulation_results.csv
│   └── simulation_results_extended.csv
└── application/            # Real-data application (bladder cancer recurrence data)
    ├── data_preprocessing.R
    ├── sagt_model.m
    ├── application_results_analysis.R
    └── application_results.pdf
```

### `simulation/`

Simulation studies evaluating the finite-sample performance of the proposed estimator against a log-rank-weighted alternative.

- **`sagt_model.m`** (MATLAB): Core implementation of the estimation procedure, including
  - `generate_recurrent_data_cp` — simulates recurrent event / gap-time data under a Weibull-based data-generating mechanism with covariates `Z1, Z2, Z3` and administrative censoring time `tau`.
  - Gehan-weight estimation routines (Algorithm 1): objective/score function, resampling-based variance estimation (`Sigma_G`), the perturbed/parametric-submodel estimator (`theta_tilde`), and estimation of the cumulative baseline hazard (`Lambda`) with its variance at fixed evaluation times.
  - Log-rank-weight estimation routines (Algorithm 2): analogous score function, one-step Newton-Raphson update from the Gehan estimator, and variance/hazard estimation (including both the sandwich-type and Huang-type variance estimators).
  - A main script (bottom of the file) that reads in the gap-time data (`data_cp.csv`), fits both weighting schemes, and prints the estimated regression coefficients, variance-covariance matrices, and cumulative baseline hazard estimates.

  To run a simulation replication, uncomment the `generate_recurrent_data_cp(n, tau_max, alpha, gamma)` call near the top of the main script (in place of `readtable('data_cp.csv')`) and set the desired sample size `n` and data-generating parameters (`alpha`, `gamma`, `tau_max`).

- **`simulation_results.csv`**: Per-replication estimates (regression coefficients, variance estimates, and cumulative hazard estimates at two time points) for both the Gehan- and log-rank-weighted estimators, across sample sizes.

- **`simulation_results_extended.csv`**: Replication-averaged summary statistics (absolute bias, standard deviation, mean estimated standard error, Wald and percentile coverage) for the regression coefficients and cumulative hazard estimates, by sample size.

- **`simulation_results_analysis.R`**: Produces publication-ready summary tables and figures from the two CSV files above, including:
  - Table 1/2: bias, standard deviation, and RMSE by sample size and estimator
  - Figure 1: bias comparison
  - Figure 2: RMSE comparison
  - Figure 3: coverage probabilities
  - Figure 4: sampling density of the coefficient estimates
  - Figures 5–8: cumulative baseline hazard comparisons and sampling densities at the evaluation time points

  **Note:** the script expects the input files to be named `simulation_results_p.csv` and `extended_simulation_results_p.csv` in the working directory — rename (or symlink) `simulation_results.csv` / `simulation_results_extended.csv` accordingly, or edit the `read.csv()` calls at the top of the script.

### `application/`

Application of the method to the `readmission` bladder cancer recurrence dataset (from the R package [`frailtypack`](https://cran.r-project.org/package=frailtypack)), which records repeated hospital readmissions for `n = 397` patients along with treatment (chemotherapy) and prognostic covariates.

- **`data_preprocessing.R`**: Loads the `readmission` dataset, performs exploratory summaries (events per patient by treatment group, event-time plots for a sample of patients), recodes categorical covariates (`chemo`, `sex`, `dukes`, `charlson`) numerically, enforces a single censoring record per subject, removes subjects with multiple recorded terminal events, and exports the cleaned gap-time data as `data_cp.csv` (columns: `id`, `time`, `gap_time`, `event`, `Z1`–`Z4`, `tau`) for use by `sagt_model.m`.

- **`sagt_model.m`** (MATLAB): Same estimation code as in `simulation/`; here it is run on `data_cp.csv` produced by `data_preprocessing.R` to fit the Gehan- and log-rank-weighted accelerated gap-time models to the real data and report the estimated coefficients, variance-covariance matrices, and cumulative baseline hazard estimates at selected follow-up times.

- **`application_results_analysis.R`**: Post-processes the MATLAB output into a forest plot comparing the Gehan and log-rank coefficient estimates and confidence intervals, a bar chart comparing estimated variances across covariates, and a plot of the estimated cumulative baseline hazard at selected time points, along with a helper function for computing p-values and confidence intervals from an estimate/standard-error pair.

  **Note:** as provided, this script contains illustrative/placeholder numeric values for the estimates, confidence intervals, and hazards; replace these with the corresponding output from `sagt_model.m` (see `application_results.pdf`) before regenerating the final figures.

- **`application_results.pdf`**: Console output from running `sagt_model.m` on the readmission data, including the fitted coefficients (`Theta`), variance-covariance matrices (`Sigma`, `Gamma`), the perturbed estimates (`Theta Tilde`), and the estimated cumulative baseline hazard (`Lambda`) with its variance at the reported time points, for both the Gehan-weighted (`g_p`) and log-rank-weighted (`lr_p`) estimators.

### `literature_review/`

Supporting literature review materials for the manuscript (see the folder itself for contents).

## Requirements

**MATLAB**
- MATLAB (R2020a or later recommended)
- Optimization Toolbox (for the numerical solvers used in `optimize_theta`, `optimize_theta_p`, etc.)

**R**
- `frailtypack`, `survival`, `reReg`, `reda`, `dplyr`, `tidyr`
- `ggplot2`, `gridExtra`, `RColorBrewer`, `viridis`
- `kableExtra`

Install the R dependencies with:

```r
install.packages(c("frailtypack", "survival", "reReg", "reda", "dplyr", "tidyr",
                    "ggplot2", "gridExtra", "RColorBrewer", "viridis", "kableExtra"))
```

## Reproducing the Results

1. **Simulation study**
   - Open `simulation/sagt_model.m` in MATLAB and configure `n`, `tau_max`, `alpha`, `gamma`, and the number of resampling replications (`B1`, `B2`) at the top of the file.
   - Run the script to generate synthetic data and fit both estimators; repeat across sample sizes and aggregate the output (as done in `simulation_results.csv` / `simulation_results_extended.csv`).
   - Run `simulation_results_analysis.R` (with the CSVs named/renamed as noted above) to reproduce the summary tables and figures.

2. **Application**
   - Run `application/data_preprocessing.R` in R to generate `data_cp.csv` from the `readmission` dataset.
   - Run `application/sagt_model.m` in MATLAB (with `data_cp.csv` in the working directory) to fit the model to the real data; see `application_results.pdf` for expected output.
   - Update `application_results_analysis.R` with the resulting estimates and run it to reproduce the forest plot, variance comparison, and cumulative hazard figures.

## Citation

If you use this code, please cite the associated paper.
