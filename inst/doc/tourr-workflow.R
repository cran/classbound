## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse   = TRUE,
  comment    = "#>",
  fig.width  = 6,
  fig.height = 5
)
library(classbound)
tourr_available <- requireNamespace("tourr", quietly = TRUE)

## ----tourr_check, eval=FALSE--------------------------------------------------
# # Install tourr if needed
# install.packages("tourr")

## ----data_prep----------------------------------------------------------------
e <- new.env(parent = emptyenv())
data("data69_1", package = "classbound", envir = e)
data69_1 <- e$data69_1

# Work with a fast subset
d <- data69_1[1:300, c("Y", "V1", "V2", "V3", "V4", "V5")]
d$Y <- as.factor(d$Y)
feat_cols <- c("V1", "V2", "V3", "V4", "V5")

## ----fit_models, message=FALSE, warning=FALSE---------------------------------
m_rpart <- fit_model(d, Y ~ ., rpart::rpart)
m_rf <- fit_model(d, Y ~ ., randomForest::randomForest, interface = "matrix")

## ----tour_path, eval=tourr_available------------------------------------------
# Standardize the features before touring
x_std <- scale(d[, feat_cols])
center_vals <- attr(x_std, "scaled:center")
scale_vals <- attr(x_std, "scaled:scale")
x_std <- as.data.frame(x_std)

if (requireNamespace("tourr", quietly = TRUE)) {
  set.seed(42)
  tour_history <- tourr::save_history(
    x_std,
    tour_path = tourr::grand_tour(d = 2),
    max_bases = 5 # 5 tour frames for this example
  )
}

## ----tour_path_stub, echo=FALSE, eval=!tourr_available------------------------
# message("tourr is not installed. Install it with: install.packages('tourr')")

## ----tour_frame, eval=tourr_available, message=FALSE, warning=FALSE-----------
if (requireNamespace("tourr", quietly = TRUE) && exists("tour_history")) {
  # Use frame 3 as an example
  frame_idx <- 3
  basis <- matrix(tour_history[, , frame_idx], nrow = length(feat_cols), ncol = 2)
  rownames(basis) <- feat_cols

  proj_list <- list(basis = basis, center = center_vals, scale = scale_vals)

  # Forward-project the training data to get axis ranges
  x_mat <- scale(d[, feat_cols], center = center_vals, scale = scale_vals)
  z_mat <- x_mat %*% basis
  ranges <- list(
    Proj1 = range(z_mat[, 1]) + c(-0.3, 0.3),
    Proj2 = range(z_mat[, 2]) + c(-0.3, 0.3)
  )
  colnames(basis) <- c("Proj1", "Proj2")
  proj_list$basis <- basis

  # Compute boundary for rpart at this frame
  b_rpart <- boundary_compute(m_rpart,
    feature_range = ranges, resolution = 40,
    projection = proj_list
  )
  plot_boundary(b_rpart,
    obs_data = d, true_label = "Y",
    x_col = "Proj1", y_col = "Proj2"
  ) +
    ggplot2::ggtitle("rpart: Tour frame 3")
}

## ----compare_frame, eval=tourr_available, message=FALSE, warning=FALSE, fig.width=12, fig.height=6, out.width="100%"----
if (requireNamespace("tourr", quietly = TRUE) && exists("tour_history")) {
  b_rf <- boundary_compute(m_rf,
    feature_range = ranges, resolution = 40,
    projection = proj_list
  )
  plot_boundary(b_rf,
    obs_data = d, true_label = "Y",
    x_col = "Proj1", y_col = "Proj2"
  ) +
    ggplot2::ggtitle("Random Forest: Tour frame 3")
}

## ----animate_stub, eval=FALSE-------------------------------------------------
# # Pseudocode (adapt based on your animation workflow)
# for (i in seq_len(dim(tour_history)[3])) {
#   basis_i <- matrix(tour_history[, , i], nrow = length(feat_cols), ncol = 2)
#   rownames(basis_i) <- feat_cols
#   colnames(basis_i) <- c("Proj1", "Proj2")
#   proj_i <- list(basis = basis_i, center = center_vals, scale = scale_vals)
# 
#   b <- boundary_compute(m_rpart,
#     feature_range = ranges, resolution = 40,
#     projection = proj_i
#   )
#   p <- plot_boundary(b,
#     obs_data = d, true_label = "Y",
#     x_col = "Proj1", y_col = "Proj2"
#   )
#   print(p)
# }

