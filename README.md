<p align="center">
  <img src="assets/header.png" alt="Accelerated effective age gap-time models" width="100%">
</p>

<p align="center">
  <a href="#method">Method</a> &middot;
  <a href="#repository-structure">Structure</a> &middot;
  <a href="#which-script-produces-which-table">Tables</a> &middot;
  <a href="#which-script-produces-which-figure">Figures</a> &middot;
  <a href="#requirements">Requirements</a> &middot;
  <a href="#reproducing-the-results">Reproducing</a> &middot;
  <a href="#notes-on-use">Notes</a> &middot;
  <a href="#citation">Citation</a>
</p>

---

Semiparametric accelerated gap-time models for recurrent event data in which
**covariates rescale an effective age process**. A subject ages faster or slower
than a baseline subject with the same intervention history, by a factor set by its
covariates. The baseline hazard is left unspecified. Interventions between events
may be minimal, perfect or imperfect, and the semiparametric AFT and AGT models are
special cases.

Code accompanying *Efficient Estimation in Semiparametric Accelerated Gap-Time
Models for Recurrent Event Data* by Emmanuel Djegou and Akim Adekpedjou. The
MATLAB scripts fit the model; the R scripts prepare the data and build the
tables and figures of the paper.

---

## Method

For subject `i` with time-invariant covariates `X_i` and effective age
`E_i(s)`:

```
intensity at calendar time s  =  lambda_0( E_i(s) * exp(beta' X_i) ) * exp(beta' X_i)
```

* `lambda_0` is an unknown baseline hazard; `beta` is the regression parameter.
* `E_i(s)` encodes the intervention mechanism:

| Intervention | Effective age `E_i(s)` | Special case |
|---|---|---|
| Minimal (as bad as old) | calendar time `s` | semiparametric AFT model |
| Perfect (as good as new) | time since the last event | semiparametric AGT model |
| Imperfect | Brown–Proschan, Block–Borges–Savits, Kijima-type, linear effective ages | new |

Because `beta` enters the argument of the unknown baseline hazard, neither
rank-based AGT methods nor profile likelihood methods for effective age models
can be used directly.

**Estimation.**

1. **Change of time scale.** A change of variable from calendar time to the
   accelerated effective age, using doubly-indexed processes, gives an at-risk
   process that depends on `beta`.
2. **Efficient score.** The efficient score and information bounds are derived
   for `beta` and the cumulative baseline hazard `Lambda_0`. The efficient weight
   is `psi(r) = 1 + r * lambda_0'(r) / lambda_0(r)`.
3. **Weighted estimating functions.** The unknown `psi` is replaced by
   data-driven weights.
   * The **Gehan** weight gives the gradient of a convex objective. Minimizing it
     gives `beta_G`.
   * A **one-step** update from `beta_G` gives estimators under general weights
     such as the **log-rank** weight, which is efficient under a Weibull baseline.
4. **Variance estimation.** Huang's numerical method is used for both estimators.
   A regression-based alternative is used for the one-step estimator.
5. **Baseline hazard.** `Lambda_0(t)` is estimated with a Nelson–Aalen-type
   estimator.

---

## Repository structure

```text
.
├── 2.Simulation/                          # Section 7: perfect-intervention (AGT) model
│   ├── simulation_sagt_model.m              data generation, Gehan and log-rank fits,
│   │                                        variance estimation, Lambda_0(1), Lambda_0(3)
│   ├── simulation_results.csv               per-replication output (500 per sample size)
│   ├── simulation_results_extended.csv      summary output by sample size
│   ├── table1_simulation.R                  Table 1 from simulation_results.csv
│   └── simulation_results_analysis.R        Figures 2-5 from the simulation output
│
├── 3.Application/                         # Section 8: colorectal cancer readmissions
│   ├── data_preprocessing.R                 frailtypack::readmission -> data_cp.csv
│   ├── application_sagt_model.m             Gehan and log-rank fits, variances, Lambda_0
│   ├── application_results.pdf              MATLAB output used in the paper
│   └── application_results_analysis.R       Tables 2-3 and a forest plot
│
└── assets/
    ├── header.png                         README banner
    └── make_header.R                      draws header.png (ggplot2)
```

---

## Which script produces which table

| Table | Contents | Produced by | Input |
|---|---|---|---|
| 1 | Simulation: bias, empirical SE, estimated SE, Wald coverage of `beta`, `Lambda_0(1)`, `Lambda_0(3)` | `2.Simulation/table1_simulation.R` | `simulation_results.csv` |
| 2 | Covariate effects, SEs and 95% Wald CIs (Gehan; log-rank with Huang and Reg SEs) | `3.Application/application_results_analysis.R` | values from `application_results.pdf` |
| 3 | `Lambda_0` at 180, 365 and 730 days with SEs and 95% CIs | same | same |

---

## Which script produces which figure

| Figure | Contents | Produced by | Output file |
|---|---|---|---|
| 1 | Gehan objective under Kijima's Model II, n = 10, 20, 50, 100 | not included in this repository | `Plot-3.png`, `Plot2.png`, `Plot3.png`, `Plot4.png` |
| 2 | Densities of the `beta` estimates | `2.Simulation/simulation_results_analysis.R` | `figure4_density.png` |
| 3 | Boxplots of the bias of `beta` | same | `figure1_bias_comparison.png` |
| 4 | `Lambda_0(1)` and `Lambda_0(3)` estimates | same | `figure5_lambda_comparison.png` |
| 5 | Densities of `Lambda_0(1)` and `Lambda_0(3)` | same | `figure8_lambda_density_faceted_t1_t3.png` |

`simulation_results_analysis.R` also writes some exploratory figures that are not
in the paper: `figure2_rmse.png`, `figure3_coverage.png`,
`figure6_lambda_t1_density.png` and `figure7_lambda_t3_density.png`.

---

## Requirements

* **MATLAB** with the Statistics and Machine Learning Toolbox (`binornd`,
  `unifrnd`). The fitting uses base MATLAB (`fminsearch`, `readtable`, `writetable`).
* **R** with:
  * `frailtypack`, `survival`, `reReg`, `reda`, `dplyr` and `ggplot2` for the application.
  * `ggplot2`, `dplyr`, `tidyr`, `kableExtra`, `gridExtra`, `RColorBrewer` and `viridis` for the simulation figures.

```r
install.packages(c("frailtypack", "survival", "reReg", "reda", "dplyr", "ggplot2",
                   "tidyr", "kableExtra", "gridExtra", "RColorBrewer", "viridis"))
```

The results in the paper were produced on a Linux machine, with the scripts run
interactively from the MATLAB desktop and RStudio.

---

## Reproducing the results

All scripts are run interactively. In MATLAB or RStudio, open the script, set the
working directory to the script's own folder (MATLAB: *Current Folder*; RStudio:
*Session → Set Working Directory → To Source File Location*), and run the whole
file.

### Simulation (Section 7)

1. **Fit the models.** Open `2.Simulation/simulation_sagt_model.m` and set the
   design at the top of the file. The values in the file are defaults; the paper
   uses:

   | Setting | Value in the paper |
   |---|---|
   | `n_values` | `[50, 100]` |
   | `replications` | `500` |
   | `B1`, `B2` | `100` |
   | `theta_0` | `0.8` |
   | `alpha`, `gamma` | `1.5` (Weibull baseline) |
   | `tau_max` | `3.5` (follow-up ~ Unif(0, 3.5)) |

   The covariate is Bernoulli(0.5), and the seed is fixed with `rng(45)`. Run the
   script. It writes `simulation_results_p.csv` (per replication) and
   `extended_simulation_results_p.csv` (summary).
2. **Table 1.** Run `table1_simulation.R`. It prints Table 1 for n = 50 and n = 100.
3. **Figures 2–5.** Run `simulation_results_analysis.R`.

To build the tables and figures from the stored output without refitting, use
the two CSV files in the folder. `table1_simulation.R` reads
`simulation_results.csv`. `simulation_results_analysis.R` reads the `*_p.csv`
names written by MATLAB, so copy the stored files to those names first.

Fitting is computationally intensive. Every replication runs a nonsmooth
minimization, Huang's variance estimator and the resampling steps of the one-step
estimator, and the cost grows roughly quadratically with the sample size.

### Real data (Section 8)

1. **Prepare the data.** Run `3.Application/data_preprocessing.R`. It loads
   `readmission` from `frailtypack`, codes the covariates and writes `data_cp.csv`.
   The coding is chemo = 1 if treated, sex = 1 if female, and Dukes' stage = 1
   (A–B), 2 (C) or 3 (D). The analysis uses n = 397 patients after preprocessing.
2. **Fit the models.** Run `3.Application/application_sagt_model.m` with
   `B1 = B2 = 1500`. It prints the estimates, the variance matrices and
   `Lambda_0` at 180, 365 and 730 days, as in `application_results.pdf`.
3. **Tables 2–3.** Run `3.Application/application_results_analysis.R`. It prints
   both tables and draws a forest plot of the covariate effects.

---

## Data availability

| Data set | Subjects | Source |
|---|---|---|
| Simulation | n = 50, 100; 500 replications each | generated by `simulation_sagt_model.m` |
| Colorectal cancer readmissions | 403 patients (397 analysed) | R package `frailtypack`, data set `readmission` (González et al., 2005) |

---

## Notes on use

**Standard errors are on the √n scale in the MATLAB output.** The MATLAB code
returns `Gamma = n * (theta_tilde - theta_hat)(theta_tilde - theta_hat)'`, the
asymptotic variance of `sqrt(n) * (theta_hat - theta_0)`. The same holds for the
`Sigma_Lambda_2` quantities of `Lambda_0`. The standard error of an estimate is
therefore `sqrt(variance / n)`. Both R table scripts apply this scaling.

**Sign convention in the application.** MATLAB returns `theta_hat`, the
coefficient in `T = T_tilde * exp(-theta' X)`. Table 2 reports `-theta_hat`, the
effect on the log gap time, so negative values mean shorter gaps between
readmissions.

**Perfect intervention is a working assumption.** Both the simulation and the
application use the perfect-intervention (AGT) effective age. The simulation
does so to validate the method against a well-understood special case. In the
application, the data contain no information on recovery after each
hospitalization. See Section 8 of the paper for the clinical discussion.

**Optimizer.** The Gehan objective is minimized with the Nelder–Mead simplex
algorithm (`fminsearch`). The objective is piecewise linear, so check
convergence from several starting values when applying the code to new data.

**Death as censoring.** In the application, follow-up ends at death for some
patients. Death is treated as censoring, which matches the noninformative
follow-up assumption only if death is unrelated to readmission given the
covariates.

---

## Citation

If you use this code, please cite the paper:

> **E. Djegou** & A. Adekpedjou. *Efficient Estimation in Semiparametric
> Accelerated Gap-Time Models for Recurrent Event Data.* Manuscript under review.

## Contact

Emmanuel Djegou (corresponding author), emmanueldjego5@gmail.com
