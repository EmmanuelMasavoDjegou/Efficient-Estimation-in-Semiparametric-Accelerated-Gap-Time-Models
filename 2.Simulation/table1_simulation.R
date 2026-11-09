# =============================================================================
# Table 1 of the paper, computed from the per-replication output
# simulation_results.csv (500 replications for each of n = 50 and n = 100).
#
# The MATLAB code stores the variance of sqrt(n) * (estimate - truth), so the
# standard error of an estimate is sqrt(variance / n). Wald intervals are
# estimate +/- 1.96 * SE.
# Set the working directory to this folder before running.
# =============================================================================

res <- read.csv("simulation_results.csv")

truth <- c(beta = 0.8, L1 = 1.5, L3 = 7.79)   # Lambda_0(3) = 1.5 * 3^1.5, rounded as in the paper

summ <- function(est, var, true, n) {
  ok <- is.finite(est) & is.finite(var)
  est <- est[ok]; se <- sqrt(var[ok] / n)
  c(abs_bias = abs(mean(est) - true),
    emp_SE   = sd(est),
    mean_SE  = mean(se),
    wald_cov = mean(abs(est - true) <= 1.96 * se))
}

rows <- list(
  "beta,  Log-rank, Huang SE" = c("EstimatedThetaLR_P",   "EstimatedGammaHuangLR_P",    "beta"),
  "beta,  Log-rank, Reg SE"   = c("EstimatedThetaLR_P",   "EstimatedGammaLR_P",         "beta"),
  "beta,  Gehan,    Huang SE" = c("EstimatedThetaG_P",    "EstimatedGammaG_P",          "beta"),
  "L0(1), Log-rank"           = c("EstimatedLambdaLR_P1", "EstimatedSigmaLambda2LR_P1", "L1"),
  "L0(1), Gehan"              = c("EstimatedLambdaG_P1",  "EstimatedSigmaLambda2G_P1",  "L1"),
  "L0(3), Log-rank"           = c("EstimatedLambdaLR_P2", "EstimatedSigmaLambda2LR_P2", "L3"),
  "L0(3), Gehan"              = c("EstimatedLambdaG_P2",  "EstimatedSigmaLambda2G_P2",  "L3")
)

for (n in c(50, 100)) {
  d <- res[res$SampleSize == n, ]
  tab <- t(sapply(rows, function(r) summ(d[[r[1]]], d[[r[2]]], truth[[r[3]]], n)))
  cat("\n==== n =", n, "( replications:", nrow(d), ") ====\n")
  print(round(tab, 3))
}
