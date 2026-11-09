# =============================================================================
# Tables 2 and 3 of the paper: covariate effects, standard errors and 95% Wald CIs
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

# =============================================================================
# Table 3: cumulative baseline hazard at 180, 365 and 730 days
# Sigma_Lambda_2 is the variance of sqrt(n) * (Lambda_hat - Lambda_0), so the
# standard error is sqrt(Sigma_Lambda_2 / n).
# =============================================================================

days       <- c(180, 365, 730)
Lambda_G   <- c(0.2978, 0.4280, 0.5635)
Sigma2_G   <- c(0.6319, 0.7469, 1.9194)
Lambda_L   <- c(0.3615, 0.4725, 0.6683)
Sigma2_L   <- c(0.3490, 0.5629, 1.3299)

lambda_table <- function(L, s2, n) {
  se <- sqrt(s2 / n)
  data.frame(day = days, Lambda = L, se = se,
             lower = L - qnorm(0.975) * se, upper = L + qnorm(0.975) * se)
}
print(round(lambda_table(Lambda_G, Sigma2_G, n), 4))   # Gehan weight
print(round(lambda_table(Lambda_L, Sigma2_L, n), 4))   # log-rank weight
