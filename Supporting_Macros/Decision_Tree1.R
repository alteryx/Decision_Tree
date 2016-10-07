## DO NOT MODIFY: Auto Inserted by AlteryxRhelper ----
library(AlteryxPredictive)
config <- list(
  `Branch Dist` = checkboxInput('%Question.Branch Dist%' , TRUE),
  `classification` = radioInput('%Question.classification%' , TRUE),
  `Counts` = radioInput('%Question.Counts%' , FALSE),
  `cp` = numericInput('%Question.cp%' , 'Auto'),
  `max.bins` = textInput('%Question.max.bins%' , 'Default'),
  `max.depth` = numericInput('%Question.max.depth%' , 20),
  `min.bucket` = numericInput('%Question.min.bucket%' , 7),
  `min.split` = numericInput('%Question.min.split%' , 20),
  `Model Name` = textInput('%Question.Model Name%'),
  `percent.correct` = radioInput('%Question.percent.correct%' , FALSE),
  `Proportions` = radioInput('%Question.Proportions%' , TRUE),
  `prune.centimeters` = radioInput('%Question.prune.centimeters%' , FALSE),
  `prune.cm.h` = numericInput('%Question.prune.cm.h%' , 14.95),
  `prune.cm.w` = numericInput('%Question.prune.cm.w%' , 13),
  `prune.graph.resolution` = dropdownInput('%Question.prune.graph.resolution%' , '1x'),
  `prune.in.h` = numericInput('%Question.prune.in.h%' , 5.5),
  `prune.in.w` = numericInput('%Question.prune.in.w%' , 5.5),
  `prune.inches` = radioInput('%Question.prune.inches%' , TRUE),
  `prune.plot` = checkboxInput('%Question.prune.plot%' , FALSE),
  `prune.pointsize` = numericInput('%Question.prune.pointsize%' , 10),
  `regression` = radioInput('%Question.regression%' , FALSE),
  `select.type` = checkboxInput('%Question.select.type%' , FALSE),
  `select.weights` = dropdownInput('%Question.select.weights%'),
  `set_cp` = checkboxInput('%Question.set_cp%' , FALSE),
  `total.correct` = radioInput('%Question.total.correct%' , TRUE),
  `tree.centimeters` = radioInput('%Question.tree.centimeters%' , FALSE),
  `tree.cm.h` = numericInput('%Question.tree.cm.h%' , 14.95),
  `tree.cm.w` = numericInput('%Question.tree.cm.w%' , 13),
  `tree.graph.resolution` = dropdownInput('%Question.tree.graph.resolution%' , '1x'),
  `tree.in.h` = numericInput('%Question.tree.in.h%' , 5.5),
  `tree.in.w` = numericInput('%Question.tree.in.w%' , 5.5),
  `tree.inches` = radioInput('%Question.tree.inches%' , TRUE),
  `tree.plot` = checkboxInput('%Question.tree.plot%' , TRUE),
  `tree.pointsize` = numericInput('%Question.tree.pointsize%' , 8),
  `use.gini` = radioInput('%Question.use.gini%' , TRUE),
  `use.information` = radioInput('%Question.use.information%' , FALSE),
  `use.weights` = checkboxInput('%Question.use.weights%' , FALSE),
  `usesurrogate.0` = radioInput('%Question.usesurrogate.0%' , FALSE),
  `usesurrogate.1` = radioInput('%Question.usesurrogate.1%' , FALSE),
  `usesurrogate.2` = radioInput('%Question.usesurrogate.2%' , TRUE),
  `X Vars` = listInput('%Question.X Vars%', names(iris)[1:4]),
  `xval.folds` = numericInput('%Question.xval.folds%' , 10),
  `Y Var` = dropdownInput('%Question.Y Var%', 'Species'),
   method = 'class'
)
options(alteryx.wd = '%Engine.WorkflowDirectory%')
options(alteryx.debug = config$debug)
##----

config <- plyr::rename(config, c(
  use.weights = 'used.weights', `Model Name` = 'model.name',
  max.bins = 'maxNumBins', min.split = "minsplit", min.bucket = 'minbucket',
  xval.folds = 'xval', max.depth = 'maxdepth', Counts = 'do.counts', 
  `Branch Dist` = 'b.dist'
))


inputs <- list(
  data_stream1 = read.Alteryx2("#1", default = rev(iris)),
  XDFinfo = getXdfProperties("#1", list(is_XDF = FALSE, xdf_path = NULL))
)

results <- processDT(config = config, data = inputs)

outputDTResultsAlteryx(results, config)
