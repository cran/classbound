## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")

## ----standard, eval=FALSE-----------------------------------------------------
# library(classbound)
# library(palmerpenguins)
# penguins <- na.omit(palmerpenguins::penguins[
#   ,
#   c("species", "bill_length_mm", "bill_depth_mm")
# ])
# 
# # e1071::svm returns a factor of class labels; works out of the box
# classbound(penguins, species ~ bill_length_mm + bill_depth_mm, e1071::svm)

## ----predfun, eval=FALSE------------------------------------------------------
# # MASS::qda returns list($class, $posterior, $x), so extract $class
# classbound(
#   penguins,
#   species ~ bill_length_mm + bill_depth_mm,
#   MASS::qda,
#   predfun = function(model, newdata, ...) predict(model, newdata, ...)$class
# )
# 
# # MASS::lda (same approach)
# classbound(
#   penguins,
#   species ~ bill_length_mm + bill_depth_mm,
#   MASS::lda,
#   predfun = function(model, newdata, ...) predict(model, newdata, ...)$class
# )
# 
# # Return probabilities as well (enables gradient visualization)
# classbound(
#   penguins,
#   species ~ bill_length_mm + bill_depth_mm,
#   MASS::lda,
#   predfun = function(model, newdata, ...) {
#     out <- predict(model, newdata, ...)
#     list(class = out$class, probs = out$posterior)
#   }
# )

## ----custom_adapter, eval=FALSE-----------------------------------------------
# # Example: custom adapter for a hypothetical classifier "myModel"
# predict_adapter.myModel <- function(model, newdata, ...) {
#   raw <- predict(model, newdata, type = "response")
#   list(
#     class = factor(raw$labels),
#     probs = as.matrix(raw$probabilities)
#   )
# }

