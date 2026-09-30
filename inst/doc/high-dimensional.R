## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse   = TRUE,
  comment    = "#>",
  fig.width  = 6,
  fig.height = 5
)

## ----setup_data, message=FALSE, warning=FALSE---------------------------------
library(classbound)
library(palmerpenguins)

# Use three numeric features from palmerpenguins
penguins <- na.omit(palmerpenguins::penguins[
  ,
  c("species", "bill_length_mm", "bill_depth_mm", "flipper_length_mm")
])

# Fit a decision tree on all three features
m3 <- fit_model(
  penguins, species ~ bill_length_mm + bill_depth_mm + flipper_length_mm,
  rpart::rpart
)
m3

## ----slice, message=FALSE, warning=FALSE--------------------------------------
# Visualize bill_length_mm vs bill_depth_mm
# flipper_length_mm is automatically fixed at its training-set median
m3_slice <- boundary_compute(
  m3,
  feature_range = list(bill_length_mm = c(30, 60), bill_depth_mm = c(10, 25)),
  resolution    = 60
)

plot_boundary(
  m3_slice,
  obs_data   = penguins,
  x_col      = "bill_length_mm",
  y_col      = "bill_depth_mm",
  true_label = "species"
)

## ----slice_reference, message=FALSE, warning=FALSE----------------------------
# Fix flipper_length_mm at a specific value instead of the median
m3_slice2 <- boundary_compute(
  m3,
  feature_range = list(bill_length_mm = c(30, 60), bill_depth_mm = c(10, 25)),
  resolution    = 60,
  reference     = list(flipper_length_mm = 200)
)

plot_boundary(m3_slice2,
  obs_data = penguins,
  x_col = "bill_length_mm", y_col = "bill_depth_mm",
  true_label = "species"
)

## ----projection, message=FALSE, warning=FALSE---------------------------------
feat_cols <- c("bill_length_mm", "bill_depth_mm", "flipper_length_mm")

# Compute PCA on the three numeric features
pca <- prcomp(penguins[, feat_cols], scale. = TRUE)
basis <- pca$rotation[, 1:2] # first two principal components

# Project the training data manually to get axis ranges
x_mat <- scale(penguins[, feat_cols], center = pca$center, scale = pca$scale)
z_mat <- x_mat %*% basis

# Compute boundary in projected space, inverse-project for prediction
m3_proj <- boundary_compute(
  m3,
  feature_range = list(
    PC1 = range(z_mat[, 1]) + c(-0.5, 0.5),
    PC2 = range(z_mat[, 2]) + c(-0.5, 0.5)
  ),
  resolution = 60,
  projection = list(basis = basis, center = pca$center, scale = pca$scale)
)

plot_boundary(
  m3_proj,
  obs_data   = penguins,
  x_col      = "PC1",
  y_col      = "PC2",
  true_label = "species"
)

## ----data69, eval=FALSE-------------------------------------------------------
# data(data69_1)
# dim(data69_1) # 5000 x 22
# 
# # Fit on first 5 features for a manageable example
# d <- data69_1[1:500, c("Y", "V1", "V2", "V3", "V4", "V5")]
# d$Y <- as.factor(d$Y)
# m_nd <- fit_model(d, Y ~ ., rpart::rpart)
# 
# # 2D slice: V1 vs V2, others at median
# m_nd_slice <- boundary_compute(m_nd,
#   feature_range = list(V1 = c(-3, 3), V2 = c(-3, 3)),
#   resolution    = 50
# )
# 
# plot_boundary(m_nd_slice,
#   obs_data = d,
#   x_col = "V1", y_col = "V2", true_label = "Y"
# )

