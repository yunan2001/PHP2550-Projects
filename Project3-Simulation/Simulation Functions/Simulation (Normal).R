#' Simulate Data and Evaluate Model Performance under Normal Distribution
#'
#' This function simulates clustered data and evaluates the performance of a linear mixed-effects model 
#' in estimating parameters under various conditions. It calculates key metrics, such as bias, power, 
#' confidence interval coverage, and variability of the estimated coefficients.
#'
#' @param n_clusters Integer. The number of clusters in the simulation.
#' @param B Numeric. The total budget available for the simulation, controlling sample size allocation.
#' @param c1 Numeric. The cost of the first sample collected from a cluster.
#' @param c1_c2_ratio Numeric. The ratio of the cost of the first sample in a cluster (`c1`) to the cost of each additional sample (`c2`) in the same cluster.
#' @param alpha Numeric. The true intercept of the linear model.
#' @param beta Numeric. The true effect size (slope) of the treatment variable.
#' @param gamma2 Numeric. Variance of the random cluster effects.
#' @param sigma2 Numeric. Variance of the individual-level residuals.
#' @param n_sim Integer. The number of simulation iterations to perform.
#' @param alpha_level Numeric. Significance level for hypothesis testing (default = 0.05).
#'
#' @return A list containing:
#'   \describe{
#'     \item{metrics}{A data frame summarizing performance metrics across simulations, including:
#'       \describe{
#'         \item{n_clusters}{Number of clusters used in the simulation.}
#'         \item{n_obs_per_cluster}{Number of observations per cluster.}
#'         \item{true_beta}{The true effect size of the treatment.}
#'         \item{beta_est_mean}{Mean of the estimated effect size across simulations.}
#'         \item{min_beta_est}{Minimum estimated effect size across simulations.}
#'         \item{max_beta_est}{Maximum estimated effect size across simulations.}
#'         \item{beta_bias_mean}{Average bias of the estimated effect size.}
#'         \item{beta_est_var}{Variance of the estimated effect size.}
#'         \item{power}{Proportion of simulations where the null hypothesis was rejected.}
#'         \item{ci_coverage}{Proportion of simulations where the true beta is within the confidence interval.}
#'       }
#'     }
#'     \item{simulated_data}{A data frame containing the simulated dataset from the final iteration.}
#'   }
#'
sim_normal <- function(n_clusters, B, c1, c1_c2_ratio, alpha, beta, gamma2, sigma2, n_sim, alpha_level = 0.05) {
  set.seed(2550)
  # Calculate c2 from the ratio
  c2 <- c1 / c1_c2_ratio
  
  # Calculate the number of measurements per cluster
  n_obs_per_cluster <- floor((B - n_clusters * c1) / (n_clusters * c2)) + 1
  
  # Assign clusters to treatment (X = 1) or control (X = 0)
  cluster_treatment <- rep(c(0, 1), n_clusters / 2) 
  
  # Initialize data frame for metrics
  all_metrics <- data.frame(
    beta_est = numeric(n_sim),
    beta_bias = numeric(n_sim),
    power = numeric(n_sim),
    coverage = numeric(n_sim)
  )
  
  for (sim in 1:n_sim) {
    # Generate random cluster-level effects
    cluster_effects <- rnorm(n_clusters, mean = 0, sd = sqrt(gamma2))
    # Generate cluster-level means
    cluster_means <- alpha + beta * cluster_treatment + cluster_effects
    
    # Simulate data
    cluster_data <- data.frame(
      cluster_id = rep(1:n_clusters, each = n_obs_per_cluster)[1:(n_clusters * n_obs_per_cluster)],
      X = rep(cluster_treatment, each = n_obs_per_cluster)[1:(n_clusters * n_obs_per_cluster)],
      Y = rnorm(
        n_clusters * n_obs_per_cluster,
        mean = cluster_means[rep(1:n_clusters, each = n_obs_per_cluster)],
        sd = sqrt(sigma2)
      )[1:(n_clusters * n_obs_per_cluster)]
    )
    
    # Fit a linear mixed-effects model
    model <- lmerTest::lmer(Y ~ X + (1 | cluster_id), data = cluster_data)
    
    # Extract measurements
    beta_est <- fixef(model)["X"]
    ci <- confint(model, parm = "X", method = "Wald")
    ci_coverage <- (beta >= ci[1] & beta <= ci[2])
    p_value <- summary(model)$coefficients["X", "Pr(>|t|)"]
    
    # Store simulation results
    all_metrics[sim, ] <- c(
      beta_est = beta_est,
      beta_bias = beta_est - beta,
      power = ifelse(p_value < alpha_level, 1, 0),
      coverage = ci_coverage
    )
  }
  
  # Compute performance metrics
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
sim_normal_dat <- sim_normal(n_clusters = 5, B = 2000, c1 = 20, c1_c2_ratio = 5, alpha = 2, beta = 1.5, gamma2 = 1, n_sim = 100, alpha_level = 0.05)
write.csv(sim_normal_dat, "sim_normal_dat.csv")