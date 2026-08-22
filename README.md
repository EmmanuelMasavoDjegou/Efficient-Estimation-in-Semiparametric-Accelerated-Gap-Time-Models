## Repository Structure

```
.
├── literature_review/       # Literature review materials
│
├── simulation/               # Monte Carlo simulation study
│   ├── sagt_model.m                        # Data generation + model estimation (MATLAB)
│   ├── simulation_results_analysis.R       # Tables and figures from simulation output
│   ├── simulation_results.csv              # Per-replication estimates
│   └── simulation_results_extended.csv     # Summary statistics (bias, SD, coverage, ...)
│
└── application/              # Application to real recurrent-event data
    ├── data_preprocessing.R              # Cleans raw data into model-ready format
    ├── sagt_model.m                      # Model estimation (MATLAB)
    ├── application_results_analysis.R    # Tables and figures from application output
    └── application_results.pdf           # Estimation output
```
