# =============================================================================
# Application results: covariate effects, standard errors and 95% Wald CIs
# Values are taken from application_results.pdf (output of application_sagt_model.m).
#
# The MATLAB code returns Gamma = n * (theta_tilde - theta_hat)(...)', the
# asymptotic variance of sqrt(n) * (theta_hat - theta_0). Standard errors of
# theta_hat are therefore sqrt(diag(Gamma) / n).
# Estimates are reported as effects on the log gap time, i.e. -theta_hat.
# =============================================================================

n      <- 397                                   # patients after preprocessing
labels <- c("Chemo", "Sex", "Dukes")

theta_G <- c(0.1459, -0.5984, 0.9343)           # Gehan
theta_L <- c(0.2046, -0.3335, 0.6956)           # log-rank (one-step)

gamma_G_huang <- c(7.9659, 7.9225, 3.4168)      # diag of Gamma, Gehan (Huang)
gamma_L_huang <- c(3.8175, 5.0255, 3.4994)      # diag of Gamma, log-rank (Huang)
gamma_L_reg   <- c(2.1078, 3.6909, 1.9195)      # diag of Gamma, log-rank (Reg)

wald <- function(theta, gamma_diag, n, level = 0.95) {
  est <- -theta                                 # effect on the log gap time
  se  <- sqrt(gamma_diag / n)
  z   <- qnorm(1 - (1 - level) / 2)
  data.frame(estimate = est, se = se, lower = est - z * se, upper = est + z * se,
             p_value = 2 * pnorm(-abs(est / se)))
}

res_G  <- wald(theta_G, gamma_G_huang, n)
res_LH <- wald(theta_L, gamma_L_huang, n)
res_LR <- wald(theta_L, gamma_L_reg,   n)
print(cbind(labels, round(res_G, 4)))
print(cbind(labels, round(res_LH, 4)))
print(cbind(labels, round(res_LR, 4)))

theta_L <- res_LH$estimate
theta_G <- res_G$estimate
ci_L <- as.matrix(res_LH[, c("lower", "upper")])
ci_G <- as.matrix(res_G[,  c("lower", "upper")])

# Create data frame
df <- data.frame(
  labels = rep(labels, 2),
  estimate = c(theta_L, theta_G),
  lower = c(ci_L[,1], ci_G[,1]),
  upper = c(ci_L[,2], ci_G[,2]),
  method = rep(c("Log-rank", "Gehan"), each = length(labels))
)

# Plot
library(ggplot2)

ggplot(df, aes(x = estimate, y = labels, color = method)) +
  geom_point(size = 3) +
  geom_errorbarh(aes(xmin = lower, xmax = upper), height = 0.2) +
  labs(x = "Effect on log gap time", title = "Forest plot of covariate effects (95% Wald CIs)") +
  theme_minimal() +
  theme(legend.title = element_blank())

# Variance Data
A_L <- c(2.00, 2.11, 1.21)
A_G <- c(2.40, 4.13, 3.74)

# Create data frame for variance comparison
df_variance <- data.frame(
  labels = labels,
  Log_rank = A_L,
  Gehan = A_G
)

# Plot
ggplot(df_variance, aes(x = labels)) +
  geom_bar(aes(y = Log_rank, fill = "Log-rank"), stat = "identity", position = "dodge") +
  geom_bar(aes(y = Gehan, fill = "Gehan"), stat = "identity", position = "dodge") +
  labs(x = "Variable", y = "Variance", title = "Comparison of Variances (A_L vs. A_G)") +
  scale_fill_manual(values = c("Log-rank" = "blue", "Gehan" = "red")) +
  theme_minimal() +
  theme(legend.title = element_blank())

# Time Points and Hazard Data
time <- c(50, 100)
Lambda_L <- c(0.19, 0.25)
Lambda_G <- c(0.19, 0.25)
B_L <- c(0.28, 0.32) # Variance
B_G <- c(0.36, 0.42)

# Create data frame for hazard estimation
df_hazard <- data.frame(
  time = rep(time, 2),
  Lambda = c(Lambda_L, Lambda_G),
  variance = c(B_L, B_G),
  method = rep(c("Log-rank", "Gehan"), each = length(time))
)

# Plot
ggplot(df_hazard, aes(x = time, y = Lambda, color = method)) +
  geom_line() +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = Lambda - sqrt(variance), ymax = Lambda + sqrt(variance)), width = 0.1) +
  labs(x = "Time", y = "Cumulative Baseline Hazard (\u03BB)", title = "Cumulative Baseline Hazard Estimates") +
  theme_minimal() +
  theme(legend.title = element_blank())

