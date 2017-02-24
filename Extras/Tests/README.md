# Decision_Tree Workflow Tests



These tests were run at 2017-02-24 14:23:15


| id|name                        |status  |time           |message   |
|--:|:---------------------------|:-------|:--------------|:---------|
|  1|BasicTest                   |&#9989; |10.875 seconds |1 warning |
|  2|BasicTest_ggplot_issue      |&#9989; |13.134 seconds |1 warning |
|  3|Test_c50_1                  |&#9989; |8.622 seconds  |1 warning |
|  4|Test_c50_1_Cross-validation |&#9989; |14.054 seconds |1 warning |
|  5|Test_c50_missing            |&#9989; |14.227 seconds |1 warning |
|  6|Test_rpart_CV               |&#9989; |21.551 seconds |          |
|  7|Test_rpart_splits1          |&#9989; |20.667 seconds |          |

### Usage Notes

1. Use the `Data/` folder to put data files required by the tests.
2. Add descriptions for the tests using the `MetaInfo` tab.

## UI Test Checklist.

1. Check that configuration persists. This includes widgets, tabs, pages, accordions, and pretty much any other ui element that the user interacts with. The configuration window should always.
2. Check navigation. This includes checking if pages show up correctly when the Customize/Back buttons are clicked. It is also important to check that persistence holds under these operations.
3. The `Customize` button should always appear.
4. Clicking on the `Customize` button should take the user to the second page.
5. Checking the box in the upper left corner of the "Select the Predictor Variables" should check all the variables when checked for the first time on a fresh tool. Checking it again should uncheck all the variables.
6. A variable should show up under in the list of potential target variables if and only if it is a numeric type (double, Int, etc.) or (V)(W)String.
7. All words should be spelled correctly. Additionally, no config text should end in punctuation, and all config options should be in sentence case.
8. The option to use cross-validation should not display if an XDF input is connected to the tool.
9. If rpart is selected, the accordions in the Model tab should be titled `Model Type and Sampling Weights`, `Splitting Criteria and Surrogates`, and `HyperParameters`. Only one accordion should be capable of expanding at any given time. If a new one is clicked on while a different one is expanded, the previously expanded one should minimize as the new one expands.
10. `Model Type and Sampling Weights` should contain two options. The first should be `Model Type`, which in turn should have the options `Auto`, `Classification`, and `Regression`. The default should be `Auto`. The second should be `Use sampling weights in model estimation`. This option should bring up a dropdown to let the user select a weighting variable. This dropdown should be clearable. If the user checks this option, but does not select a weighting variable, then the workflow should display a configuration time error.
11. The `Splitting Criteria and Surrogates` should contain two sets of radio buttons. The first should be titled `Use surrogates to`, and the second should be titled `Select best surrogate split using`. In both cases, the first radio button should be selected by default.
12. Under the `Hyperparameters` accordion, the options should be `The minimum number of records needed to allow for a split`, `The allowed minimum number of records in a terminal node`, `The number of folds to use in the cross-validation to prune the tree`, `The maximum allowed depth of any node in the final tree`, `The maximum number of bins to use for each numeric variable`, and `Set complexity parameter`, which should be unchecked by default.
13. The text box under `The maximum number of bins to use for each numeric variable` should say the word "Default" in gray by default. If a number is typed in the box and then cleared, the word "Default" should show again.
12. If C5.0 is selected, the accordions should have the titles `Structural Options`, `Detailed Options`, and `Numerical Hyperparameters`. 
12. The options under `Structural Options` should be `Decompose tree into rule-based model` and `Use sampling weights in model estimation`. Both should be unchecked by default. 
13. If `Decompose tree into rule-based model` is selected, nothing should show in the Plots tab. If it's not selected, the Tree plot accordion with the toggle `Display tree plot` should be unchecked by default. If it is checked, `Uniform branch distances`, `Leaf summary`, `Plot size`, `Width`, `Height`, `Graph resolution`, and `Base font size (points)` should show.
14. The options under `Detailed Options` should be the following checkboxes: `Model should evaluate groups of discrete predictors for splits`, `Use predictor winnowing (ie feature selection)`, `Prune tree`, `Evaluate advanced splits in the data`, `Use stopping method for boosting`, and `Display static report`. All should be unchecked by default.
15. The options under `Numerical Hyperparameters` should be `Select number of boosting iterations`, `Select confidence factor`, `Select number of samples that must be in at least 2 splits`, `Percent of data held from training for model evaluation`, `Select random seed for algorithm`, which should default to 1. 
15. `Use Cross-validation to determine estimates of model quality` should be unchecked by default. 
16. In the Cross-validation tab, `Number of folds`, `Number of trials`, and `Set seed` should appear if and only if cross-validation is selected. If CV is selected, `Set seed` should be checked by default, and the default value of the seed should be 1.
17. If CV is selected, the options `Enter the positive class...` and `Use stratified cross-validation` should appear if and only if one of the following three conditions is true. 1: C5.0 is selected as the algorithm. 2: rpart is selected as the algorithm with `Classification` as the model type. 3: rpart is selected with `Auto` as the classification type, and the target variable is a (V)(W)String.
18. Assuming `Display static reports` is selected, the `Prune plot` accordion should show up if and only if rpart is the model type. The `Display prune plot` toggle should be off by default. If it's turned on, the options should be `Plot size`, `Width`, `Height`, `Graph resolution`, and `Base font size (points)`. Both plots should be generated according to the user's selection, though there should be no prune plots ever generated with C5.0, and no tree plots with C5.0 when `Decompose tree into rule-based model` is selected.
19. The `Display static reports` option should be selected by default. The `Tree plot` and `Prune plot` accordions, if applicable as described above, should appear if and only if `Display static reports` is selected.
