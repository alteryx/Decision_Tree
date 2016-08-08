#########
# Helper functions
xdfLevels <- function(form, xdf) {
	factors <- rxSummary(form, data = xdf)$categorical
	the.names <- sapply(factors, function(x) names(x)[1])
	if (length(the.names) == 1) {
		the.levels <- eval(parse(text = paste("list(", the.names, " = as.character(factors[[1]][[1]]))")))
	} else {
		the.levels <- sapply(factors, function(x) as.character(x[[1]]))
		names(the.levels) <- the.names
	}
	the.levels
}

#########
# The core portion of the macro

# To get run-over-run consistency, set the seed
set.seed(1)

# Load the rpart library (it is included with base R but still needs to be
# loaded in the the process's R environment
# Determine if the rpart.plot package is available.
loadPackages("rpart, rpart.plot")

# Determine if a compute context is being used, and whether it is XDF
# The mechanism for doing this depends on how the information is transfered
is.XDF <- FALSE
meta.data <- read.AlteryxMetaInfo("#1")
the.source <- as.character(meta.data$Source)
if (all(substr(the.source, 3, 9) == "Context")) {
	library(rjson)
	context.list <- fromJSON(the.source[1])
	if (context.list$Context == "XDF") {
		is.XDF <- TRUE
		xdf.path <- context.list$File.Loc
	} else {
		stop.Alteryx("At this time only XDF scaling is supported")
	}
}

# Read the data stream into R
the.data <- read.Alteryx("#1")

# Get the field names
name.y.var <- names(the.data)[1]
names.x.vars <- names(the.data)[-1]

# Address the use of a weights fields
weight.arg <- ""
# Boolean if weights are used
used.weights <- '%Question.use.weights%' == "True"
# Adjust the set of field names to remove the weight field if weights are used
if (used.weights) {
	use.probs <- '%Question.samp.probs%' == "True"
	the.weights <- names.x.vars[length(names.x.vars)]
	names.x.vars <- names.x.vars[1:(length(names.x.vars) - 1)]
	if (!is.XDF) {
		weight.arg <- paste(", weights =", the.weights)
	} else {
		weight.arg <- paste(', pweights = "', the.weights, '"', sep = "")
	}
}

# Make sure that the target variable is not included in the set of
# predictor variables. If it is, then remove it from the set.
if (name.y.var %in% names.x.vars)
	names.x.vars <- names.x.vars[names.x.vars != name.y.var]

# Create the base right-hand side of the formula
x.vars <- paste(names.x.vars, collapse = " + ")

# Obtain and prep other user inputs
model.name <- '%Question.Model Name%'
model.name <- validName(model.name)

# Make sure that the target variable is not included in the set of
# predictor variables. If it is, then remove it from the set.
if (name.y.var %in% names.x.vars)
	names.x.vars <- names.x.vars[names.x.vars != name.y.var]

the.formula <- paste(name.y.var, ' ~ ', x.vars)
the.cp <- '%Question.cp%'

# See if the provided target variable is numeric, and if it is, check to see the
# number of unique values, and if it is four or fewer issue a warning when the
# incoming data stream is a regular Alteryx stream (this can't really be done
# when the incoming data is an XDF file).
the.target <- eval(parse(text = paste('the.data', name.y.var, sep="$")))
if (is.numeric(the.target) && length(unique(the.target)) < 5 && !is.XDF)
	AlteryxMessage("The target variable is numeric, however, it has 4 or fewer unique values.", iType = 2, iPriority = 3)

# Get the possible user specified model estimation parameters
#
# The model method and the split measure (for classification models)
method.split <- ""
if ('%Question.select.type%' == "True") {
	if ('%Question.classification%' == "True") {
		if ('%Question.use.gini%' == "True") {
			method.split <- ', method = "class", parms = list(split = "gini")'
		} else {
			method.split <- ', method = "class", parms = list(split = "information")'
		}
	} else {
		method.split <- ', method = "anova"'
	}
}

# Control for the use of surrogate splits
use.surrogate <- 2
if ('%Question.usesurrogate.0%' == "True")
	use.surrogate <- 0
if ('%Question.usesurrogate.1%' == "True")
	use.surrogate <- 1
	
# The tree growth control parameters and the model call
if (is.XDF) {
	# Address the XDF specific control options
	max.bins1 <- '%Question.max.bins%'
	if (is.na(as.numeric(max.bins1))) {
		max.bins <- ""
	} else {
		if (as.numeric(max.bins1) < 2) {
			stop.Alteryx("An insufficient maximum number of bins per numeric predictor has been given")
		}
		max.bins <- paste(", maxNumBins =", max.bins1)
	}
	the.controls <- paste(', minSplit = ', %Question.min.split%, ', minBucket = ', %Question.min.bucket%, ', useSurrogate = ', use.surrogate, ', xVal = ', %Question.xval.folds%, ', maxDepth = ', %Question.max.depth%, max.bins, sep = "")
	model.call <- paste(model.name, ' <- rxDTree(', the.formula, weight.arg, ', data = "', xdf.path, '"', method.split, the.controls, sep = "")
} else {
	the.controls <- paste(', minsplit = ', %Question.min.split%, ', minbucket = ', %Question.min.bucket%, ', usesurrogate = ', use.surrogate, ', xval = ', %Question.xval.folds%, ', maxdepth = ', %Question.max.depth%, sep = "")
	model.call <- paste(model.name, ' <- rpart(', the.formula, weight.arg, ', data = the.data', method.split, the.controls, sep = "")
}

# Address the issues surrounding the cp value. Specifically, if it is missing
# or given the value "Auto" a very "bushy" tree is grown and then the value of
# cp that results in the lowest cross validation error is used for the tree
# that is returned.
if (is.na(as.numeric(the.cp))) {
	if (the.cp == "Auto" || the.cp == "") {
		get.cp.call <- paste(model.call, ", cp = 0.00001)", sep = "")
		eval(parse(text = get.cp.call))
		the.model <- eval(parse(text = model.name))
		cp.table <- as.data.frame(the.model$cptable)
		pos.cp <- cp.table$CP[(cp.table$xerror - 0.5*cp.table$xstd) <= min(cp.table$xerror)]
		new.cp <- pos.cp[1]
		print(cp.table)
		if (cp.table$xerror[1] == min(cp.table$xerror)) {
			stop("The minimum cross validation error occurs for a CP value where there are no splits. Specify a complexity parameter.")
		}
		the.model <- prune(the.model, cp = new.cp)
	} else {stop("The complexity parameter provided is not a number")}
} else {
	if (as.numeric(the.cp) > 1 | as.numeric(the.cp) < 0) {
		stop.Alteryx("The complexity parameter provided is not between 0 and 1")
	} else {
		model.call <- paste(model.call, ', cp = ', the.cp, ')', sep = "")
		eval(parse(text = model.call))
		the.model <- eval(parse(text = model.name))
	}
}

# The output: Start with the pruning table (have rxDTree objects add rpart
# inheritance for printing and plotting purposes).
if (is.XDF) {
	the.model.rpart <- rxAddInheritance(the.model)
	printcp(the.model.rpart)
	out <- capture.output(printcp(the.model.rpart))
	the.model$xlevels <- eval(parse(text = paste("xdfLevels(~ ", x.vars, ", xdf.path)")))
	if (is.factor(the.target)) {
		target.info <- eval(parse(text = paste("rxSummary(~ ", name.y.var, ", data = xdf.path)$categorical", sep = "")))
		if(length(target.info) == 1) {
			the.model$yinfo <- list(levels = as.character(target.info[[1]][,1]), counts = target.info[[1]][,2])
		}
	}
} else {
	printcp(the.model) # Pruning Table
	out <- capture.output(printcp(the.model))
}
out <- out[out != ""]
print(out)
out <- out[2:length(out)]
# Find the index of the end of the call
for (i in 1:length(out)) {
	if (grepl("Variables", out[i])) {
		end.call <- i - 1
		break
	}
}
call1 <- out[1:end.call]
the.call <- paste(call1, collapse="")
the.call = gsub("\\s\\s", "", the.call)
# Figure out where the summary information ends and the actual pruning table
# starts. The header for the pruning table is removed, and will instead show-up
# in the Alteryx reporting tool
for (i in 1:length(out)) {
	if (grepl("\\sCP\\s", out[i])) {
		strt.table <- i + 1
		break
	}
}
model.sum <- length((end.call + 1):(strt.table - 2))
prune.tbl1 <- out[strt.table:length(out)]
out <- c(the.call, out[(end.call + 1):(strt.table - 2)])
rpart.out <- data.frame(grp = c("Call", rep("Model_Sum", model.sum)), out = out)
rpart.out$grp <- as.character(rpart.out$grp)
rpart.out$out <- as.character(out)
# Pipe delimit the pruning table and then rbind it to the output
prune.tbl <- NULL
for (i in 1:length(prune.tbl1)) {
	a.row <- unlist(strsplit(prune.tbl1[i], "\\s"))
	a.row <- a.row[a.row != ""]
	prune.tbl <- c(prune.tbl, paste(a.row[1], a.row[2], a.row[3], a.row[4], a.row[5], a.row[6], sep="|"))
}
pt.df <- data.frame(grp = rep("Prune", length(prune.tbl)), out = prune.tbl)
pt.df$grp <- as.character(pt.df$grp)
pt.df$out <- as.character(pt.df$out)
rpart.out <- rbind(rpart.out, pt.df)

# The leaf summary
if (is.XDF) {
	print(the.model.rpart) # Tree Leaf Summary
	leaves <- capture.output(the.model.rpart)
} else {
	print(the.model) # Tree Leaf Summary
	leaves <- capture.output(the.model)
}
leaves.num <- 1:length(leaves)
start.leaves <- leaves.num[substr(leaves, 1, 5) == "node)"]
leaves <- leaves[start.leaves:length(leaves)]
leaves <- gsub(">", "&gt;", leaves)
leaves <- gsub("<", "&lt;", leaves)
leaves <- gsub("\\s", "<nbsp/>", leaves) # Order matters
leaves.df <- data.frame(grp = rep("Leaves", length(leaves)), out = leaves)
leaves.df$grp <- as.character(leaves.df$grp)
leaves.df$out <- as.character(leaves.df$out)

rpart.out <- rbind(rpart.out, leaves.df)

# Indicate that this is an object of class rpart or rxDTree
if (is.XDF) {
	rpart.out <- rbind(c("Model_Name", model.name), rpart.out, c("Model_Class", "rxDTree"))
} else {
	rpart.out <- rbind(c("Model_Name", model.name), rpart.out, c("Model_Class", "rpart"))
}

# Write out the grp-out table for reporting
write.Alteryx(rpart.out)

# Address the user plot parameters and create the plots

# The values in the leaf summary
leaf.sum <- 4
do.counts <- '%Question.Counts%'
if (do.counts == "True")
	leaf.sum <- 2
if (the.model$method != "class")
	leaf.sum <- 0
print(the.model$method)

# Uniform or proportional tree branch lengths
uniform <- "FALSE"
fallen <- "TRUE"
b.dist <- '%Question.Branch Dist%'
if (b.dist == "True") {
	uniform <- "TRUE"
	fallen <- "FALSE"
}

# The tree plot
whr <- graphWHR(inches = '%Question.tree.inches%', in.w = '%Question.tree.in.w%', in.h = '%Question.tree.in.h%', cm.w = '%Question.tree.cm.w%', cm.h = '%Question.tree.cm.h%', resolution = '%Question.tree.graph.resolution%', print.high = TRUE)
AlteryxGraph(2, width = whr[1], height = whr[2], res = whr[3], pointsize = %Question.tree.pointsize%)
par(mar = c(5, 4, 6, 2) + 0.1)
if (is.XDF) {
	eval(parse(text=paste("rpart.plot(the.model.rpart, type = 0, extra = ", leaf.sum, ", uniform = ", uniform, ", fallen.leaves = ", fallen, ", main = 'Tree Plot', cex = 1)")))
} else {
	eval(parse(text=paste("rpart.plot(the.model, type = 0, extra = ", leaf.sum, ", uniform = ", uniform, ", fallen.leaves = ", fallen, ", main = 'Tree Plot', cex = 1)")))
}
invisible(dev.off())

# The pruning plot
whr <- graphWHR(inches = '%Question.prune.inches%', in.w = '%Question.prune.in.w%', in.h = '%Question.prune.in.h%', cm.w = '%Question.prune.cm.w%', cm.h = '%Question.prune.cm.h%', resolution = '%Question.prune.graph.resolution%', print.high = FALSE)
AlteryxGraph(4, width = whr[1], height = whr[2], res = whr[3], pointsize = %Question.prune.pointsize%)
par(mar = c(5, 4, 6, 2) + 0.1)
if (is.XDF) {
	plotcp(the.model.rpart)
} else {
	plotcp(the.model)
}
title(main="Pruning Plot", line=5)
invisible(dev.off())

# Create a list with the model object and its name and write it out via
# the third output
#the.obj <- data.frame(Name = model.name, Object = serializeObject(the.model))
the.obj <- vector(mode="list", length=2)
the.obj[[1]] <- c(model.name)
the.obj[[2]] <- list(the.model)
names(the.obj) <- c("Name", "Object")
write.Alteryx(the.obj, nOutput = 3)


## Interactive Visualization
library(AlteryxRviz)
library(htmltools)
if (is.XDF){
  k1 = tags$div(tags$h4(
   "Interactive Visualizations are not supported for Revolution Enterprise"
  ))
  renderInComposer(k1, nOutput = 5)
} else {
	if (!(packageVersion('AlteryxRviz') >= "0.2.5")){
	  k1 = tags$div(
	    tags$h4("You need AlteryxRviz >= 0.2.5")
	  )
	} else {
	 #the.model = rpart(Species ~ ., data = iris)
	 tooltipParams = list(
	   width = '250px',
	   top = '130px',
	   left = '100px'
	 )
	 dt = renderTree(the.model, tooltipParams = tooltipParams)
	 vimp = varImpPlot(the.model, height = 300)
	
	 cmat = if (!is.null(the.model$frame$yval2)){
	   iConfusionMatrix(getConfMatrix(the.model), height = 300)
	 }  else {
	   tags$div(h1('Confusion Matrix Not Valid'), height = 300)
	 }
	
	 k1 = dtDashboard(dt, vimp, cmat)
	}
	renderInComposer(k1, nOutput = 5)
}