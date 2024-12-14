#' Simulate Data and Evaluate Performance Metrics for a Poisson Model
#'
#' This function simulates clustered count data and evaluates the performance of a Poisson generalized linear mixed-effects model (GLMM). 
#' It calculates key metrics such as bias, power, confidence interval coverage, and the variability of estimated coefficients across simulations.
#'
#' @param n_clusters Integer. The number of clusters in the simulation.
#' @param B Numeric. The total budget available for data collection, influencing sample size allocation.
#' @param c1 Numeric. The cost of collecting the first observation in a cluster.
#' @param c1_c2_ratio Numeric. The ratio of the cost of the first observation in a cluster (`c1`) to the cost of additional observations in the same cluster (`c2`), where `c2 = c1 / c1_c2_ratio`.
#' @param alpha Numeric. The true intercept of the Poisson model.
#' @param beta Numeric. The true effect size of the treatment variable.
#' @param gamma2 Numeric. The variance of the random cluster-level effects.
#' @param n_sim Integer. The number of simulations to perform.
#' @param alpha_level Numeric. The significance level for hypothesis testing (default = 0.05).
#'
#' @return A list containing:
#' \describe{
#'   \item{metrics}{A data frame summarizing performance metrics across simulations, including:
#'     \describe{
#'       \item{n_clusters}{Number of clusters in the simulation.}
#'       \item{n_obs_per_cluster}{Number of observations per cluster, derived from budget and cost parameters.}
#'       \item{true_beta}{The true effect size of the treatment variable.}
#'       \item{beta_est_mean}{Mean of the estimated effect size across simulations.}
#'       \item{min_beta_est}{Minimum estimated effect size across simulations.}
#'       \item{max_beta_est}{Maximum estimated effect size across simulations.}
#'       \item{beta_bias_mean}{Average bias of the estimated effect size.}
#'       \item{beta_est_var}{Variance of the estimated effect size.}
#'       \item{power}{Proportion of simulations where the null hypothesis was rejected (p-value < alpha level).}
#'       \item{ci_coverage}{Proportion of simulations where the true beta is within the confidence interval.}
#'     }
#'   }
#'   \item{simulated_data}{A data frame containing the simulated dataset from the last simulation iteration.}
#' }
#'
sim_poisson <- function(n_clusters, B, c1, c1_c2_ratio, alpha, beta, gamma2, n_sim, alpha_level = 0.05) {
  set.seed(2550)
  # calculate c2 from the ratio
  c2 <- c1 / c1_c2_ratio
  
  # calculate the number of measurements per cluster
  n_obs_per_cluster <- floor((B - n_clusters * c1) / (n_clusters * c2)) + 1
  
  
  # assign clusters to treatment (X = 1) or control (X = 0)
  cluster_treatment <- rep(c(0,1), n_clusters/2) 
  
  # initialize data frame
  all_metrics <- data.frame(
    beta_est = numeric(n_sim),
    beta_bias = numeric(n_sim),
    power = numeric(n_sim),
    coverage = numeric(n_sim)
  )
  
  for (sim in 1:n_sim) {
    
    # generate random cluster-level effects (log scale)
    cluster_effects <- rnorm(n_clusters, mean = alpha, sd = sqrt(gamma2))
    # generate cluster-level means (log scale)
    log_mu <- alpha + beta * cluster_treatment + cluster_effects
    mu <- exp(log_mu)  
    
    cluster_data <- data.frame(
      cluster_id = rep(1:n_clusters, each = n_obs_per_cluster)[1:(n_clusters * n_obs_per_cluster)],
      X = rep(cluster_treatment, each = n_obs_per_cluster)[1:(n_clusters * n_obs_per_cluster)],
      Y = rpois(n_clusters * n_obs_per_cluster, lambda = mu[rep(1:n_clusters, each = n_obs_per_cluster)])[1:(n_clusters * n_obs_per_cluster)])
    
    # fit a Poisson GLM with random intercept for clusters
    model <- lme4::glmer(Y ~ X + (1 | cluster_id), data = cluster_data, family = poisson())
    
    # extract measurements
    beta_est <- fixef(model)["X"]
    ci <- confint(model, parm = "X", method = "Wald")
    ci_coverage <- (beta >= ci[1] & beta <= ci[2]) 
    p_value <- summary(model)$coefficients["X", "Pr(>|z|)"]
    
    # store simulation results
    all_metrics[sim, ] <- c(
      beta_est = beta_est,
      beta_bias = beta_est - beta,
      power = ifelse(p_value < alpha_level, 1, 0),
      coverage = ci_coverage
    )
  }
  
  # Compute performance 
  beta_est_var <- var(all_metrics$beta_est)
  min_beta_est <- min(all_metrics$beta_est)
  max_beta_est <- max(all_metrics$beta_est)
  avg_metrics <- colMeans(all_metrics)
  
  # Return results
  results <- data.frame(
    n_clusters = n_clusters,
    n_obs_per_cluster = n_obs_per_cluster,
    true_beta = beta,
    beta_est_mean = avg_metrics["beta_est"],
    min_beta_est = min_beta_est,
    max_beta_est = max_beta_est,
    beta_bias_mean = avg_metrics["beta_bias"],
    beta_est_var = beta_est_var,
    power = avg_metrics["power"],
    ci_coverage = avg_metrics["coverage"]
  )
  
  return(list(
    metrics = results,
    simulated_data = cluster_data
  ))
}

# Example of generating data and saving
sim_poisson_dat <- sim_poisson(n_clusters = 5, B = 2000, c1 = 20, c1_c2_ratio = 5, alpha = 2, beta = 1.5, gamma2 = 1, n_sim = 100, alpha_level = 0.05)
write.csv(sim_poisson_dat, "sim_poisson_dat.csv")