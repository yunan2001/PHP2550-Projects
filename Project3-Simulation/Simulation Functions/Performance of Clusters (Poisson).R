#' Simulate Performance of Poisson Model Across Varying Cluster Sizes and Cost Ratios
#'
#' This function evaluates the performance of a Poisson generalized linear mixed-effects model 
#' under varying numbers of clusters and cost ratios. It loops over a grid of parameters 
#' to assess metrics such as bias, variance, power, and confidence interval coverage.
#'
#' @param n_clusters_seq Vector. Sequence of cluster sizes to evaluate (e.g., `seq(10, 50, 5)`).
#' @param c1_c2_ratios Vector. Ratios of the first observation cost (`c1`) to the cost of subsequent observations (`c2`).
#' @param B Numeric. Total budget available for sampling across clusters.
#' @param c1 Numeric. Cost of the first observation in a cluster.
#' @param alpha Numeric. The intercept for the true model on the log scale.
#' @param beta Numeric. The true effect size of the treatment variable on the log scale.
#' @param gamma2 Numeric. Variance of the random cluster effects on the log scale.
#' @param n_sim Integer. Number of simulations to run for each parameter combination.
#' @param alpha_level Numeric. The significance level for hypothesis testing (default = 0.05).
#'
#' @return A data frame summarizing simulation results across all combinations of cluster sizes and cost ratios. 
#' Each row includes:
#' \describe{
#'   \item{n_clusters}{The number of clusters.}
#'   \item{n_obs_per_cluster}{Number of observations per cluster based on budget and cost constraints.}
#'   \item{true_beta}{The true slope of the treatment effect.}
#'   \item{beta_est_mean}{Mean of estimated treatment effects across simulations.}
#'   \item{beta_bias_mean}{Mean bias of the treatment effect estimates.}
#'   \item{beta_est_var}{Variance of the estimated treatment effects.}
#'   \item{power}{Proportion of simulations rejecting the null hypothesis.}
#'   \item{ci_coverage}{Proportion of simulations where the true beta is within the confidence interval.}
#'   \item{c1_c2_ratio}{Cost ratio (`c1/c2`).}
#' }
#'
sim_poisson_opt <- function(n_clusters_seq, c1_c2_ratios, B, c1, alpha, beta, gamma2, n_sim, alpha_level) {
  all_results <- list()
  
  # Loop over the parameter grid
  for (c1_c2_ratio in c1_c2_ratios) {
    for (n_clusters in n_clusters_seq) {
      # Run the simulation for each configuration
      result <- sim_poisson(
        n_clusters = n_clusters,
        B = B,
        c1 = c1,
        c1_c2_ratio = c1_c2_ratio,
        alpha = alpha,
        beta = beta,
        gamma2 = gamma2,
        n_sim = n_sim,
        alpha_level = alpha_level
      )
      
      # Store the results
      all_results <- append(all_results, list(
        result$metrics %>% mutate(c1_c2_ratio = c1_c2_ratio)
      ))
    }
  }
  
  # Combine all results into a single data frame
  combined_results <- bind_rows(all_results)
  return(combined_results)
}

# Example of generating result and saving
n_clusters_seq <- seq(10, 50, 5)  
c1_c2_ratios <- c(2, 5, 10, 20) 
res_poisson_opt <- sim_poisson_opt(n_clusters_seq = n_clusters_seq, c1_c2_ratios = c1_c2_ratios, B = 2000, c1 = 20, alpha = 2, beta = 1.5, gamma2 = 1, n_sim = 100, alpha_level = 0.05)

write.csv(res_poisson_opt, "res_poisson_opt.csv")
