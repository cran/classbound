## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 6,
  fig.height = 5
)

## ----eval=FALSE---------------------------------------------------------------
# devtools::install_github("natydasilva/classbound")

## ----quickstart, message=FALSE, warning=FALSE---------------------------------
library(classbound)
library(palmerpenguins)

penguins <- na.omit(penguins[, c("species", "bill_length_mm", "bill_depth_mm")])

classbound(
  data       = penguins,
  formula    = species ~ bill_length_mm + bill_depth_mm,
  classifier = rpart::rpart
)

## ----pipeline, message=FALSE, warning=FALSE-----------------------------------
# Step 1: Fit the model
model <- fit_model(penguins, species ~ bill_length_mm + bill_depth_mm, rpart::rpart)

# Step 2: Compute the boundary grid
model <- boundary_compute(
  model,
  feature_range = list(bill_length_mm = c(30, 60), bill_depth_mm = c(10, 25)),
  resolution    = 80
)

# Step 3: Plot
plot_boundary(
  model,
  obs_data   = penguins,
  x_col      = "bill_length_mm",
  y_col      = "bill_depth_mm",
  true_label = "species"
)

## ----classifiers, eval=FALSE--------------------------------------------------
# # SVM (returns class labels natively; no extra work needed)
# classbound(penguins, species ~ bill_length_mm + bill_depth_mm, e1071::svm)
# 
# # Random forest (matrix interface: randomForest expects x and y separately)
# classbound(penguins, species ~ bill_length_mm + bill_depth_mm,
#   randomForest::randomForest,
#   interface = "matrix"
# )

## ----predfun, eval=FALSE------------------------------------------------------
# # MASS::qda returns a list, so extract $class manually
# classbound(
#   penguins,
#   species ~ bill_length_mm + bill_depth_mm,
#   MASS::qda,
#   predfun = function(model, newdata, ...) predict(model, newdata, ...)$class
# )

## ----gradient, message=FALSE, warning=FALSE-----------------------------------
model <- fit_model(penguins, species ~ bill_length_mm + bill_depth_mm, rpart::rpart)
model <- boundary_compute(model)

plot_boundary(
  model,
  obs_data      = penguins,
  x_col         = "bill_length_mm",
  y_col         = "bill_depth_mm",
  true_label    = "species",
  show_gradient = TRUE
)

## ----explorapp, eval=FALSE----------------------------------------------------
# # Launch with a dataset pre-loaded
# explorapp(data = penguins, target_col = "species")
# 
# # Or launch empty and simulate data interactively
# explorapp()

