#' Perform LASSO with bootstrapping on multiple imputed datasets.
#'
#' This function applies LASSO regression on bootstrapped samples of multiple imputed datasets. 
#' It selects optimal regularization parameters (`lambda`), evaluates model performance, and summarizes the results.
#' 
#' @param data List. A list of imputed datasets to be analyzed.
#' @param seed Integer. Seed value for reproducibility (default = 2550).
#' @param bootstrap_iterations Integer. Number of bootstrap iterations for each imputed dataset (default = 10).
#' @return A list containing:
#'   \describe{
#'     \item{best_lambdas}{List. Optimal `lambda` values for each bootstrap iteration across imputed datasets.}
#'     \item{coef_list}{List. Coefficients from the LASSO model for each bootstrap iteration.}
#'     \item{auc_list}{List. AUC values for each bootstrap iteration, representing test set performance.}
#'     \item{bootstrap_results}{List. Comprehensive results for each bootstrap iteration, including `lambda`, coefficients, and AUC.}
#'     \item{avg_coef}{Numeric vector. Average coefficient estimates across all bootstrapped models.}
#'     \item{train_data_full}{Data frame. Combined training datasets from all bootstrap iterations.}
#'     \item{test_data_full}{Data frame. Combined test datasets from all bootstrap iterations.}
#'   }

perform_cv_lasso_mod <- function(data, seed = 2550, bootstrap_iterations = 10) {
  # Initialize lists to store results
  best_lambdas <- list()
  coef_list <- list()
  auc_list <- list()
  roc_plots <- list()
  bootstrap_results <- list()
  train_data_full <- NULL
  test_data_full <- NULL
  
  # Loop through each imputed dataset
  for (i in 1:5) {
    # Complete the imputed dataset
    project2_imputed_s <- data[[i]]
    
    # Perform bootstrap iterations
    for (b in 1:bootstrap_iterations) {
      # Generate bootstrap sample
      set.seed(seed + b)  # Ensure reproducibility for each bootstrap iteration
      bootstrap_sample <- project2_imputed_s[sample(1:nrow(project2_imputed_s), replace = TRUE), ]
      
      # Split bootstrapped dataset into training and testing sets
      set.seed(seed + b)  # Reuse the same seed for consistency
      train_index <- createDataPartition(bootstrap_sample$Group, p = 0.7, list = FALSE)
      train_data <- bootstrap_sample[train_index, ]
      test_data <- bootstrap_sample[-train_index, ]
      
      # Combine train and test datasets
      train_data_full <- bind_rows(train_data_full, train_data)
      test_data_full <- bind_rows(test_data_full, test_data)
      
      # Assign folds for cross-validation in training data
      train_data$foldid <- NA
      for (group in unique(train_data$Group)) {
        group_data <- train_data[train_data$Group == group, ]
        fold_idex <- sample(rep(1:10, length.out = nrow(group_data)))
        train_data$foldid[train_data$Group == group] <- fold_idex
      }
      
      # Create model matrices for training data
      x_mat <- model.matrix(
        abst ~ BA * (age_ps + sex_ps + inc + edu + ftcd_score + ftcd.5.mins + bdi_score_w00 +
                       cpd_ps + crv_total_pq1 + hedonsum_n_pq1_sqrt + hedonsum_y_pq1_sqrt +
                       shaps_score_pq1_log + otherdiag + antidepmed + mde_curr + NMR_log +
                       Only.Menthol + readiness + Race) +
          Var * (age_ps + sex_ps + inc + edu + ftcd_score + ftcd.5.mins + bdi_score_w00 +
                   cpd_ps + crv_total_pq1 + hedonsum_n_pq1_sqrt + hedonsum_y_pq1_sqrt +
                   shaps_score_pq1_log + otherdiag + antidepmed + mde_curr + NMR_log +
                   Only.Menthol + readiness + Race),
        data = train_data
      )[, -1]
      y <- train_data$abst
      
      # Perform LASSO cross-validation to find the best lambda
      lasso_model_cv <- cv.glmnet(
        x_mat, y, alpha = 1, nfolds = 10, foldid = train_data$foldid,
        family = "binomial"
      )
      
      # Fit LASSO model with the optimal lambda
      best_lambda <- lasso_model_cv$lambda.min
      best_lambdas[[paste(i, b)]] <- best_lambda  # Store the best lambda for this iteration
      lasso_model <- glmnet(
        x_mat, y, alpha = 1, lambda = best_lambda, family = "binomial"
      )
      
      # Store the coefficients with names
      coef_list[[paste(i, b)]] <- as.matrix(coef(lasso_model))[, , drop = FALSE]
      
      # Evaluate the model on the test set
      x_mat_test <- model.matrix(
        abst ~ BA * (age_ps + sex_ps + inc + edu + ftcd_score + ftcd.5.mins + bdi_score_w00 +
                       cpd_ps + crv_total_pq1 + hedonsum_n_pq1_sqrt + hedonsum_y_pq1_sqrt +
                       shaps_score_pq1_log + otherdiag + antidepmed + mde_curr + NMR_log +
                       Only.Menthol + readiness + Race) +
          Var * (age_ps + sex_ps + inc + edu + ftcd_score + ftcd.5.mins + bdi_score_w00 +
                   cpd_ps + crv_total_pq1 + hedonsum_n_pq1_sqrt + hedonsum_y_pq1_sqrt +
                   shaps_score_pq1_log + otherdiag + antidepmed + mde_curr + NMR_log +
                   Only.Menthol + readiness + Race),
        data = test_data
      )[, -1]
      y_test <- test_data$abst
      
      # Predict probabilities on the test data
      test_predictions <- predict(lasso_model, newx = x_mat_test, type = "response")
      
      # Calculate AUC
      test_roc <- roc(y_test, as.vector(test_predictions))
      test_auc <- auc(test_roc)
      auc_list[[paste(i, b)]] <- test_auc
      
      # Store bootstrap results
      bootstrap_results[[paste(i, b)]] <- list(
        best_lambda = best_lambda,
        coefficients = coef_list[[paste(i, b)]],
        auc = test_auc
      )
    }
  }
  
  # Combine the coefficient lists into a matrix and calculate the average coefficients
  coef_matrix <- do.call(cbind, coef_list)  # Combine list of named vectors into a matrix
  avg_coef <- rowMeans(coef_matrix, na.rm = TRUE)
  
  # Return results as a list
  list(
    best_lambdas = best_lambdas,
    coef_list = coef_list,
    auc_list = auc_list,
    bootstrap_results = bootstrap_results,
    avg_coef = avg_coef,
    train_data_full = train_data_full,  # Return the combined dataset
    test_data_full = test_data_full
  )
}

# Example of generating result 
results_mod <- perform_cv_lasso_mod(data = project2_imp_trans, seed = 1234, bootstrap_iterations = 10)