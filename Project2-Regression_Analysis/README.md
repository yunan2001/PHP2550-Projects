# PHP2550-Project2-Regression Analysis

### Background

This project analyzes data from a clinical trial investigating smoking cessation strategies for individuals with major depressive disorder (MDD). The study compares Behavioral Activation for Smoking Cessation (BASC) with standard treatment (ST) and examines the effectiveness of varenicline versus placebo on long-term smoking abstinence. The aim is to explore baseline variables that may moderate or predict treatment effectiveness.

### Data and Analysis Methods

The dataset includes demographic, psychological, and smoking history variables for 300 participants, split equally across four treatment groups. Data preprocessing involved multiple imputations for missing values. An exploratory analysis was conducted to identify patterns, followed by regression analysis using regularized Lasso logistic regression to select significant predictors and interactions. Cross-validation was applied to tune the model and assess generalizability.

### Results

The exploratory analysis highlighted factors such as education, age, and nicotine dependence as influential in smoking cessation outcomes. Regression analysis found varenicline to be associated with higher abstinence rates, with BASC showing additional benefit when combined with varenicline. The analysis also revealed that baseline nicotine dependence and current depressive symptoms acted as moderators for BASC, with higher dependence and active depressive symptoms potentially reducing BASC’s effectiveness. Key predictors of abstinence included college education, lower nicotine dependence, and certain income levels. The model demonstrated reasonable classification accuracy (AUC = 0.76), though calibration issues indicated closer alignment on training data than test data. The full report can be found [here](Report/PHP2550_Project2.pdf).

![](Visuals/`Table_1-Baseline_Charac.png`)

## Files

### Report
`PHP2550_Project2.Rmd`: The Rmarkdown version of the Regression Analysis report, which includes both written text interpretations and raw code used in the analysis. 

`PHP2550_Project2.pdf`: The PDF version of the Regression Analysis report, which includes both written text interpretations and a Code Appendix with the raw code used in the analysis. 


## Dependencies

The following packages were used in this analysis: 

 - Data Manipulation: `dplyr`, `tidyr`, `mice`, `caret`
 - Table Formatting: `gt`, `gtsummary`
 - Data Visualization: `ggplot2`, `ggpubr`, `ggExtra`, `gridExtra`, `predtools`, `pROC`
 - Model: `glmnet`, `boot`, `ISLR`
 
