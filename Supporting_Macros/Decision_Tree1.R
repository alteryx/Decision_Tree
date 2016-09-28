library(AlteryxPredictive)

config <- list(
  used.weights ='%Question.use.weights%' == "True",
  # use.probs ='%Question.samp.probs%' == "True", !!!! NOT USED IN CODE ANYWHERE
  model.name ='%Question.Model Name%',
  cp ='%Question.cp%',
  select.type ='%Question.select.type%'=="True",
  classification ='%Question.classication%' == "True",
  gini ='%Question.gini%' == "True",
  usesurrogate.0 ='%Question.usesurrogate.0%' == "True",
  usesurrogate.1 ='%Question.usesurrogate.1%' == "True",
  maxNumBins ='%Question.max.bins%',#left off here
  minsplit = %Question.min.split%,
  minbucket = %Question.min.bucket%,
  valfolds = %Question.xval.folds%,
  maxdepth = %Question.max.depth%,
  tree.pointsize = %Question.tree.pointsize%,
  do.counts ='%Question.Counts%',
  b.dist ='%Question.Branch Dist%',
  tree.inches ='%Question.tree.inches%',
  tree.in.w ='%Question.tree.in.w%',
  tree.in.h ='%Question.tree.in.h%',
  tree.cm.w ='%Question.tree.cm.w%',
  tree.cm.h ='%Question.tree.cm.h%',
  tree.graph.resolution ='%Question.tree.graph.resolution%',
  prune.inches ='%Question.prune.inches%',
  prune.in.w ='%Question.prune.in.w%',
  prune.in.h ='%Question.prune.in.h%',
  prune.cm.w ='%Question.prune.cm.w%',
  prune.cm.h ='%Question.prune.cm.h%',
  prune.graph.resolution ='%Question.prune.graph.resolution%',
  prune.pointsize = %Question.prune.pointsize%
)

data <- list(
  data_stream1 = read.Alteryx("#1")
)

results <- processDT(config = config, data = data)

outputDTResultsAlteryx(results, config)