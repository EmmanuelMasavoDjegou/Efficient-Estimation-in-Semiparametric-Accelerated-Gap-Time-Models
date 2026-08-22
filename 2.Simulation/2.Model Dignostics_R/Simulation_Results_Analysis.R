# =============================================================================
# Simulation Results Analysis (NO background grids + viridis harmony colors)
# =============================================================================

# Load necessary libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(kableExtra)
library(gridExtra)
library(RColorBrewer)
library(viridis)

# -----------------------------------------------------------------------------
# Global theme: remove panel grids everywhere (major + minor)
# -----------------------------------------------------------------------------
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )
)

# Read the data
results_basic <- read.csv("simulation_results_p.csv")
results_extended <- read.csv("extended_simulation_results_p.csv")

# =============================================================================
# TABLE 1: Summary Statistics by Sample Size and Estimator Type
# =============================================================================

# For Theta estimators (G vs LR)
theta_summary <- rbind(
  results_basic %>%
    group_by(SampleSize) %>%
    summarise(
      Estimator = "Gamma (G)",
      Mean_Theta = mean(EstimatedThetaG_P),
      Bias = mean(EstimatedThetaG_P - 0.8),
      SD = sd(EstimatedThetaG_P),
      RMSE = sqrt(mean((EstimatedThetaG_P - 0.8)^2)),
      .groups = "drop"
    ),
  results_basic %>%
    group_by(SampleSize) %>%
    summarise(
      Estimator = "LR",
      Mean_Theta = mean(EstimatedThetaLR_P),
      Bias = mean(EstimatedThetaLR_P - 0.8),
      SD = sd(EstimatedThetaLR_P),
      RMSE = sqrt(mean((EstimatedThetaLR_P - 0.8)^2)),
      .groups = "drop"
    )
)

# Create publication-ready table
table1 <- kable(
  theta_summary,
  digits = 4,
  caption = "Table 1: Performance Comparison of Theta Estimators",
  col.names = c("Sample Size", "Estimator", "Mean", "Bias", "SD", "RMSE")
) %>%
  kable_styling(
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width = FALSE,
    font_size = 12
  ) %>%
  add_header_above(c(" " = 2, "Point Estimates" = 4))

print(table1)

# =============================================================================
# TABLE 2: Coverage Probabilities
# =============================================================================

coverage_summary <- results_extended %>%
  group_by(SampleSize) %>%
  summarise(
    `G: Wald CI` = mean(CoverageWaldG_P),
    `G: Percentile CI` = mean(CoveragePercentileG_P),
    `LR: Wald CI` = mean(CoverageWaldLR_P),
    `LR: Percentile CI` = mean(CoveragePercentileLR_P),
    `Lambda G1: Wald` = mean(CoverageWaldLambdaG_P1),
    `Lambda LR1: Wald` = mean(CoverageWaldLambdaLR_P1),
    .groups = "drop"
  )

table2 <- kable(
  coverage_summary,
  digits = 3,
  caption = "Table 2: Coverage Probabilities (Nominal Level: 0.952)"
) %>%
  kable_styling(
    bootstrap_options = c("striped", "hover"),
    full_width = FALSE
  )

print(table2)

# =============================================================================
# FIGURE 1: Bias Comparison Across Sample Sizes
# =============================================================================

bias_data <- rbind(
  results_basic %>%
    mutate(Estimator = "Gamma (G)",
           Bias = EstimatedThetaG_P - 0.8),
  results_basic %>%
    mutate(Estimator = "LR",
           Bias = EstimatedThetaLR_P - 0.8)
) %>%
  select(SampleSize, Estimator, Bias)

fig1 <- ggplot(bias_data, aes(x = factor(SampleSize), y = Bias, fill = Estimator)) +
  geom_boxplot(alpha = 0.8) +
  labs(
    title = "",
    x = "Sample Size (n)",
    y = "Bias (Estimated - True Value)",
    fill = "Estimator Type"
  ) +
  scale_fill_viridis_d(option = "viridis", begin = 0.15, end = 0.95) +
  theme(legend.position = "bottom")

ggsave("figure1_bias_comparison.png", fig1, width = 8, height = 6, dpi = 300)

# =============================================================================
# FIGURE 2: RMSE Comparison
# =============================================================================

rmse_data <- theta_summary %>%
  select(SampleSize, Estimator, RMSE)

fig2 <- ggplot(rmse_data, aes(x = SampleSize, y = RMSE, color = Estimator, group = Estimator)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  labs(
    title = "Figure 2: Root Mean Squared Error by Sample Size",
    x = "Sample Size (n)",
    y = "RMSE",
    color = "Estimator"
  ) +
  scale_color_viridis_d(option = "viridis", begin = 0.15, end = 0.95) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "bottom"
  )

ggsave("figure2_rmse.png", fig2, width = 8, height = 6, dpi = 300)

# =============================================================================
# FIGURE 3: Coverage Probability Comparison
# =============================================================================

coverage_long <- results_extended %>%
  select(SampleSize, starts_with("Coverage")) %>%
  pivot_longer(
    cols = starts_with("Coverage"),
    names_to = "CI_Type",
    values_to = "Coverage"
  ) %>%
  mutate(
    Method = case_when(
      grepl("G_P", CI_Type) & grepl("Wald", CI_Type) ~ "Gamma: Wald",
      grepl("G_P", CI_Type) & grepl("Percentile", CI_Type) ~ "Gamma: Percentile",
      grepl("LR_P", CI_Type) & grepl("Wald", CI_Type) ~ "LR: Wald",
      grepl("LR_P", CI_Type) & grepl("Percentile", CI_Type) ~ "LR: Percentile",
      TRUE ~ "Other"
    )
  ) %>%
  filter(Method != "Other") %>%
  group_by(SampleSize, Method) %>%
  summarise(Coverage = mean(Coverage), .groups = "drop")

fig3 <- ggplot(coverage_long, aes(x = SampleSize, y = Coverage, color = Method, group = Method)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  geom_hline(yintercept = 0.952, linetype = "dashed", color = "red", linewidth = 0.8) +
  labs(
    title = "Figure 3: Coverage Probabilities of Confidence Intervals",
    x = "Sample Size (n)",
    y = "Coverage Probability",
    color = "Method"
  ) +
  scale_color_viridis_d(option = "viridis", begin = 0.10, end = 0.95) +
  scale_y_continuous(limits = c(0.85, 1.0), breaks = seq(0.85, 1.0, 0.05)) +
  theme(
    plot.title = element_text(hjust = 0.8, face = "bold"),
    legend.position = "bottom"
  )

ggsave("figure3_coverage.png", fig3, width = 10, height = 6, dpi = 300)

# =============================================================================
# FIGURE 4: Density Plots for Theta Estimates
# =============================================================================

density_data <- rbind(
  results_basic %>%
    filter(SampleSize == 50) %>%
    mutate(Estimator = "Gehan (n=50)", Value = EstimatedThetaG_P),
  results_basic %>%
    filter(SampleSize == 100) %>%
    mutate(Estimator = "Gehan (n=100)", Value = EstimatedThetaG_P),
  results_basic %>%
    filter(SampleSize == 50) %>%
    mutate(Estimator = "LR (n=50)", Value = EstimatedThetaLR_P),
  results_basic %>%
    filter(SampleSize == 100) %>%
    mutate(Estimator = "LR (n=100)", Value = EstimatedThetaLR_P)
) %>%
  select(Estimator, Value)

fig4 <- ggplot(density_data, aes(x = Value, fill = Estimator)) +
  geom_density(alpha = 0.6, color = NA) +
  labs(
    title = "Distribution of Theta Estimates",
    x = "hat(theta)",
    y = "Density",
    fill = "Weight"
  ) +
  scale_fill_viridis_d(option = "viridis", begin = 0.10, end = 0.95) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "bottom",
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 10)
  )

ggsave("figure4_density.png", fig4, width = 10, height = 6, dpi = 300)

# =============================================================================
# FIGURE 5: Lambda Parameter Comparison
# =============================================================================

lambda_data <- rbind(
  data.frame(
    SampleSize = results_basic$SampleSize,
    Estimator = "Gehan",
    Lambda1 = results_basic$EstimatedLambdaG_P1,
    Lambda2 = results_basic$EstimatedLambdaG_P2
  ),
  data.frame(
    SampleSize = results_basic$SampleSize,
    Estimator = "LR",
    Lambda1 = results_basic$EstimatedLambdaLR_P1,
    Lambda2 = results_basic$EstimatedLambdaLR_P2
  )
)

fig5a <- ggplot(lambda_data, aes(x = factor(SampleSize), y = Lambda1, fill = Estimator)) +
  geom_boxplot(alpha = 0.8) +
  labs(
    title = "",
    x = "Sample Size",
    y = "hat(Lambda)_0(1)",
    fill = "Weight"
  ) +
  scale_fill_viridis_d(option = "viridis", begin = 0.15, end = 0.95) +
  theme(legend.position = "bottom")

fig5b <- ggplot(lambda_data, aes(x = factor(SampleSize), y = Lambda2, fill = Estimator)) +
  geom_boxplot(alpha = 0.8) +
  labs(
    title = "",
    x = "Sample Size",
    y = "hat(Lambda)_0(3)",
    fill = "Weight"
  ) +
  scale_fill_viridis_d(option = "viridis", begin = 0.15, end = 0.95) +
  theme(legend.position = "bottom")

fig5 <- grid.arrange(fig5a, fig5b, ncol = 2, top = "")

ggsave("figure5_lambda_comparison.png", fig5, width = 12, height = 6, dpi = 300)

# =============================================================================
# Save all tables to LaTeX
# =============================================================================

table1_latex <- kable(
  theta_summary,
  format = "latex",
  digits = 4,
  caption = "Performance Comparison of Theta Estimators",
  booktabs = TRUE
)
writeLines(table1_latex, "table1_theta_performance.tex")

table2_latex <- kable(
  coverage_summary,
  format = "latex",
  digits = 3,
  caption = "Coverage Probabilities",
  booktabs = TRUE
)
writeLines(table2_latex, "table2_coverage.tex")

print("Analysis complete! All tables and figures have been saved.")

# =============================================================================
# FIGURE 6: Density Plots for Lambda Estimates (t = 1 and t = 3)
# =============================================================================

# ---- Lambda(t=1) density (Lambda1) ----
lambda_t1_density_data <- rbind(
  results_basic %>%
    filter(SampleSize == 50) %>%
    mutate(Estimator = "Gehan (n=50)", Value = EstimatedLambdaG_P1),
  results_basic %>%
    filter(SampleSize == 100) %>%
    mutate(Estimator = "Gehan (n=100)", Value = EstimatedLambdaG_P1),
  results_basic %>%
    filter(SampleSize == 50) %>%
    mutate(Estimator = "LR (n=50)", Value = EstimatedLambdaLR_P1),
  results_basic %>%
    filter(SampleSize == 100) %>%
    mutate(Estimator = "LR (n=100)", Value = EstimatedLambdaLR_P1)
) %>%
  select(Estimator, Value)

fig6 <- ggplot(lambda_t1_density_data, aes(x = Value, fill = Estimator)) +
  geom_density(alpha = 0.6, color = NA) +
  labs(
    title = "Distribution of Lambda(t = 1) Estimates",
    x = "hat(Lambda)_0(1)",
    y = "Density",
    fill = "Weight"
  ) +
  scale_fill_viridis_d(option = "viridis", begin = 0.10, end = 0.95) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "bottom",
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 10)
  )

ggsave("figure6_lambda_t1_density.png", fig6, width = 10, height = 6, dpi = 300)

# ---- Lambda(t=3) density (Lambda2) ----
lambda_t3_density_data <- rbind(
  results_basic %>%
    filter(SampleSize == 50) %>%
    mutate(Estimator = "Gehan (n=50)", Value = EstimatedLambdaG_P2),
  results_basic %>%
    filter(SampleSize == 100) %>%
    mutate(Estimator = "Gehan (n=100)", Value = EstimatedLambdaG_P2),
  results_basic %>%
    filter(SampleSize == 50) %>%
    mutate(Estimator = "LR (n=50)", Value = EstimatedLambdaLR_P2),
  results_basic %>%
    filter(SampleSize == 100) %>%
    mutate(Estimator = "LR (n=100)", Value = EstimatedLambdaLR_P2)
) %>%
  select(Estimator, Value)

fig7 <- ggplot(lambda_t3_density_data, aes(x = Value, fill = Estimator)) +
  geom_density(alpha = 0.6, color = NA) +
  labs(
    title = "Distribution of Lambda(t = 3) Estimates",
    x = "hat(Lambda)_0(3)",
    y = "Density",
    fill = "Weight"
  ) +
  scale_fill_viridis_d(option = "viridis", begin = 0.10, end = 0.95) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "bottom",
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 10)
  )

ggsave("figure7_lambda_t3_density.png", fig7, width = 10, height = 6, dpi = 300)

# ---- Optional: one faceted plot (t=1 + t=3 together) ----
lambda_density_faceted <- rbind(
  data.frame(
    SampleSize = results_basic$SampleSize,
    Estimator = "Gehan",
    Lambda_t = "t = 1",
    Value = results_basic$EstimatedLambdaG_P1
  ),
  data.frame(
    SampleSize = results_basic$SampleSize,
    Estimator = "Gehan",
    Lambda_t = "t = 3",
    Value = results_basic$EstimatedLambdaG_P2
  ),
  data.frame(
    SampleSize = results_basic$SampleSize,
    Estimator = "LR",
    Lambda_t = "t = 1",
    Value = results_basic$EstimatedLambdaLR_P1
  ),
  data.frame(
    SampleSize = results_basic$SampleSize,
    Estimator = "LR",
    Lambda_t = "t = 3",
    Value = results_basic$EstimatedLambdaLR_P2
  )
) %>%
  filter(SampleSize %in% c(50, 100)) %>%
  mutate(
    Group = paste0(Estimator, " (n=", SampleSize, ")"),
    Group = factor(Group, levels = c("Gehan (n=50)", "Gehan (n=100)", "LR (n=50)", "LR (n=100)")),
    Lambda_t = factor(Lambda_t, levels = c("t = 1", "t = 3"))
  )

fig8 <- ggplot(lambda_density_faceted, aes(x = Value, fill = Group)) +
  geom_density(alpha = 0.6, color = NA) +
  facet_wrap(~ Lambda_t, scales = "free_x", ncol = 2) +
  labs(
    title = "Distribution of Lambda Estimates",
    x = "Estimate",
    y = "Density",
    fill = "Weight"
  ) +
  scale_fill_viridis_d(option = "viridis", begin = 0.10, end = 0.95) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    legend.position = "bottom",
    axis.title = element_text(face = "bold"),
    axis.text = element_text(size = 10)
  )

ggsave("figure8_lambda_density_faceted_t1_t3.png", fig8, width = 12, height = 6, dpi = 300)