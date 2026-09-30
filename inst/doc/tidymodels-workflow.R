## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse   = TRUE,
  comment    = "#>",
  fig.width  = 7,
  fig.height = 5
)

## ----packages, eval=FALSE-----------------------------------------------------
# install.packages(c("tidymodels", "workflowsets", "parsnip", "rpart", "nnet"))

## ----load_pkgs, message=FALSE, warning=FALSE----------------------------------
library(classbound)
library(palmerpenguins)

## ----data---------------------------------------------------------------------
penguins <- na.omit(palmerpenguins::penguins[
  ,
  c("species", "bill_length_mm", "bill_depth_mm")
])

## ----specs, eval=requireNamespace("parsnip", quietly = TRUE) && requireNamespace("workflowsets", quietly = TRUE), message=FALSE----
library(parsnip)
library(workflowsets)

spec_tree <- decision_tree(mode = "classification") |>
  set_engine("rpart")

spec_rf <- rand_forest(mode = "classification") |>
  set_engine("randomForest")

## ----wf_set, eval=requireNamespace("parsnip", quietly = TRUE) && requireNamespace("workflowsets", quietly = TRUE)----
wf_set <- workflow_set(
  preproc = list(base = species ~ bill_length_mm + bill_depth_mm),
  models  = list(tree = spec_tree, forest = spec_rf)
)
wf_set

## ----compute, eval=requireNamespace("parsnip", quietly = TRUE) && requireNamespace("workflowsets", quietly = TRUE), message=FALSE, warning=FALSE----
bounds <- boundary_workflow_set(
  wf_set,
  data       = penguins,
  response   = "species",
  resolution = 60
)

# The result is a classbound object with multi-model boundary data
class(bounds)
head(bounds$boundary_data[, 1:4])

## ----plot, eval=requireNamespace("parsnip", quietly = TRUE) && requireNamespace("workflowsets", quietly = TRUE), message=FALSE, warning=FALSE, fig.width=12, fig.height=6, out.width="100%"----
plot_boundary(
  bounds,
  obs_data   = penguins,
  x_col      = "bill_length_mm",
  y_col      = "bill_depth_mm",
  true_label = "species"
)

## ----disagree, eval=requireNamespace("parsnip", quietly = TRUE) && requireNamespace("workflowsets", quietly = TRUE), message=FALSE, warning=FALSE----
plot_boundary(bounds,
  type = "disagreement",
  x_col = "bill_length_mm", y_col = "bill_depth_mm"
)

## ----pretrained, eval=FALSE---------------------------------------------------
# # Fit individually first
# wf1 <- workflows::workflow(species ~ ., spec_tree) |> parsnip::fit(penguins)
# wf2 <- workflows::workflow(species ~ ., spec_rf) |> parsnip::fit(penguins)
# 
# # Wrap in a workflow_set (already trained)
# wf_trained <- workflowsets::workflow_set(
#   preproc = list(base = species ~ .),
#   models  = list(tree = spec_tree, forest = spec_rf)
# )
# # boundary_workflow_set() will refit because wf_set workflows are not trained
# # Use as_classbound() directly for pre-fitted objects:
# m1 <- as_classbound(wf1, data = penguins, response = "species")
# m2 <- as_classbound(wf2, data = penguins, response = "species")
# bounds_manual <- boundary_compute(
#   list(tree = m1, forest = m2),
#   feature_range = list(bill_length_mm = c(30, 60), bill_depth_mm = c(10, 25)),
#   resolution = 60
# )
# plot_boundary(bounds_manual,
#   obs_data = penguins,
#   x_col = "bill_length_mm", y_col = "bill_depth_mm",
#   true_label = "species"
# )

