library(jeeves)
library(htmltools)
pluginDir <- '.'
cfg <- renderPluginWidgets(pluginDir, wrapInDiv = TRUE)

# cfg <- setNames(
#   lapply(names(cfg), function(x){
#     div(id = paste0('div-', makeHtmlId(x)), HTML(sprintf("{{ `%s` }}", x)))
#   }), names(cfg2)
# )

setupPage <- jvSetupPage(title = 'Setup',
  cfg$`Model Name`, cfg$`Y Var`, cfg$`X Vars`              
)

rpartTabItems <- jvAccordion(id = 'show-on-rpart',
  jvAccordionItem('Model and Sampling Weights', id = 'toggle-main',
    cfg$model_type, cfg$use.weights, cfg$select.weights
  ),
  jvAccordionItem('Splitting Criteria and Surrogates', id = 'toggle-split',
    cfg$splitting_criteria, cfg$surrogate_use, cfg$surrogate_split_criteria        
  ),
  jvAccordionItem('Numerical Hyperparameters', id = 'toggle-hyperparameters',
    cfg$set_cp, cfg$cp, 
    cfg$min.split, cfg$min.bucket, 
    cfg$xval.folds, cfg$max.depth, cfg$max.bins 
  )
)



c50TabItems <- jvAccordion(id = 'show-on-c50',
  jvAccordionItem('Toggle 1',
    cfg$use.weights, cfg$select.weights, cfg$rules, cfg$bands_check, cfg$bands
  ),
  jvAccordionItem('Toggle 2',
    cfg$subset, cfg$winnow, cfg$GlobalPruning, cfg$fuzzyThreshold,
    cfg$earlyStopping, cfg$display.static
  ),
  jvAccordionItem('Toggle 3',
    cfg$CF, cfg$minCases, cfg$sample, cfg$seed 
  )
)

modelTab <- jvTabPage(title = 'Model',
  cfg$model.algorithm, rpartTabItems, c50TabItems
)

  
treePlotOptions <- jvAccordionItem('Tree Plot', cfg$tree.plot, 
  div(id = 'show-tree-plot-options', 
    cfg$`Branch Dist`, cfg$tree_summary, cfg$tree_plot_size,
    div(id = 'show-tree-plot-size-in-in', cfg$tree.in.w, cfg$tree.in.h),
    div(id = 'show-tree-plot-size-in-cm', cfg$tree.cm.w, cfg$tree.cm.h),
    cfg$tree.graph.resolution, cfg$tree.pointsize
  )                
)

prunePlotOptions <- jvAccordionItem('Prune Plot', cfg$prune.plot,
  div(id = 'show-prune-plot-options', cfg$pruning_plot_size,
    div(id = 'show-prune-plot-size-in-in', cfg$prune.in.w, cfg$prune.in.h),
    div(id = 'show-prune-plot-size-in-cm', cfg$prune.cm.w, cfg$prune.cm.h),
    cfg$prune.graph.resolution, cfg$prune.pointsize
  )
)

graphicsTab <- jvTabPage(title = 'Plots', id = 'graphics',
  jvAccordion(treePlotOptions, prunePlotOptions)
)

customizePageContent <- jvTabbedContent(
  modelTab, graphicsTab, selected = 'advanced'
)

customizePage <- jvCustomizePage(title = 'Customize', customizePageContent) 

ui <- tagList(setupPage, customizePage)
di <- jvMakeDataItemsToInitialize(
  curPage = 'Home', 
  curTab = 'model',
  curToggle = 'toggle-main'
)


displayRules = list(
  'div-select-weights'= 'use.weights',
  # 'div-use.weights2'= 'use.weights',
  'show-tree-plot-options' = 'tree.plot',
  'show-prune-plot-options' = 'prune.plot',
  'show-tree-plot-size-in-in'= c('tree_plot_size', 'tree.inches'),
  'show-tree-plot-size-in-cm'= c('tree_plot_size', 'tree.centimeters'),
  'show-prune-plot-size-in-in'= c('pruning_plot_size', 'prune.inches'),
  'show-prune-plot-size-in-cm'= c('pruning_plot_size', 'prune.centimeters'),
  'div-cp'= 'set_cp',
  'div-splitting-criteria'= c('model_type', 'classification'),
  'div-bands-check' = 'rules',
  'div-bands'= 'bands_check',
  'show-on-rpart'= c('model.algorithm', 'rpart'),
  'show-on-c50' = c('model.algorithm', 'C5.0')
)

jsonDisplayRules <- jsonlite::toJSON(
  displayRules, auto_unbox = TRUE, pretty = TRUE
)


myPage <- tagList(ui, tags$script(
  makeJsVariable(di, 'items'), 
  makeJsVariable(jsonDisplayRules, 'displayRules')
))

writeLines(as.character(myPage), file.path(pluginDir, 'Extras/Gui/layout.html'))
updatePlugin()