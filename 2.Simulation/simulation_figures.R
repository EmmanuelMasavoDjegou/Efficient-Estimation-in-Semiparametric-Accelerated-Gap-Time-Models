# =============================================================================
# Figures 2-5 of the paper, drawn from the per-replication output
# simulation_results.csv (500 replications for each of n = 50 and n = 100).
# Set the working directory to this folder before running.
#
#   Figure 2  figure4_density.png                        densities of beta-hat
#   Figure 3  figure1_bias_comparison.png                boxplots of the bias of beta-hat
#   Figure 4  figure5_lambda_comparison.png              Lambda_0(1) and Lambda_0(3) estimates
#   Figure 5  figure8_lambda_density_faceted_t1_t3.png   densities of Lambda_0(1), Lambda_0(3)
#
# The file names are the ones used by \includegraphics in the manuscript.
# =============================================================================

library(ggplot2)
library(dplyr)
library(gridExtra)
library(viridis)

theme_set(
  theme_minimal(base_size = 12) +
    theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank())
)

res <- read.csv("simulation_results.csv")
beta_0 <- 0.8

group_label <- function(weight, n) {
  factor(paste0(weight, " (n=", n, ")"),
         levels = c("Gehan (n=50)", "Gehan (n=100)", "Log-rank (n=50)", "Log-rank (n=100)"))
}

# ---- Figure 2: densities of beta-hat ----------------------------------------
beta_long <- rbind(
  data.frame(n = res$SampleSize, weight = "Gehan",    value = res$EstimatedThetaG_P),
  data.frame(n = res$SampleSize, weight = "Log-rank", value = res$EstimatedThetaLR_P)
) %>% mutate(group = group_label(weight, n))

fig_beta_density <- ggplot(beta_long, aes(x = value, fill = group)) +
  geom_density(alpha = 0.6, colour = NA) +
  labs(x = expression(hat(beta)), y = "Density", fill = "Weight") +
  scale_fill_viridis_d(option = "viridis", begin = 0.10, end = 0.95) +
  theme(legend.position = "bottom", axis.title = element_text(face = "bold"))
ggsave("figure4_density.png", fig_beta_density, width = 10, height = 6, dpi = 300)

# ---- Figure 3: boxplots of the bias of beta-hat ------------------------------
fig_beta_bias <- ggplot(beta_long %>% mutate(bias = value - beta_0),
                        aes(x = factor(n), y = bias, fill = weight)) +
  geom_boxplot(alpha = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  labs(x = "Sample size (n)", y = expression("Bias  " * (hat(beta) - beta[0])), fill = "Weight") +
  scale_fill_viridis_d(option = "viridis", begin = 0.15, end = 0.95) +
  theme(legend.position = "bottom")
ggsave("figure1_bias_comparison.png", fig_beta_bias, width = 8, height = 6, dpi = 300)

# ---- Figures 4 and 5: Lambda_0(1) and Lambda_0(3) ----------------------------
lambda_long <- rbind(
  data.frame(n = res$SampleSize, weight = "Gehan",    t = "t = 1", value = res$EstimatedLambdaG_P1),
  data.frame(n = res$SampleSize, weight = "Gehan",    t = "t = 3", value = res$EstimatedLambdaG_P2),
  data.frame(n = res$SampleSize, weight = "Log-rank", t = "t = 1", value = res$EstimatedLambdaLR_P1),
  data.frame(n = res$SampleSize, weight = "Log-rank", t = "t = 3", value = res$EstimatedLambdaLR_P2)
) %>% mutate(group = group_label(weight, n),
             t = factor(t, levels = c("t = 1", "t = 3")))

box_lambda <- function(tt, ylab) {
  ggplot(filter(lambda_long, t == tt), aes(x = factor(n), y = value, fill = weight)) +
    geom_boxplot(alpha = 0.8) +
    labs(x = "Sample size (n)", y = ylab, fill = "Weight") +
    scale_fill_viridis_d(option = "viridis", begin = 0.15, end = 0.95) +
    theme(legend.position = "bottom")
}
fig_lambda_box <- arrangeGrob(box_lambda("t = 1", expression(hat(Lambda)[0](1))),
                              box_lambda("t = 3", expression(hat(Lambda)[0](3))), ncol = 2)
ggsave("figure5_lambda_comparison.png", fig_lambda_box, width = 12, height = 6, dpi = 300)

fig_lambda_density <- ggplot(lambda_long, aes(x = value, fill = group)) +
  geom_density(alpha = 0.6, colour = NA) +
  facet_wrap(~ t, scales = "free_x", ncol = 2) +
  labs(x = "Estimate", y = "Density", fill = "Weight") +
  scale_fill_viridis_d(option = "viridis", begin = 0.10, end = 0.95) +
  theme(legend.position = "bottom", axis.title = element_text(face = "bold"))
ggsave("figure8_lambda_density_faceted_t1_t3.png", fig_lambda_density, width = 12, height = 6, dpi = 300)

message("Figures written: figure4_density.png, figure1_bias_comparison.png, ",
        "figure5_lambda_comparison.png, figure8_lambda_density_faceted_t1_t3.png")
