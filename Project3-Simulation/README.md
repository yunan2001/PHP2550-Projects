# PHP2550-Project2-Regression Analysis

### Background

This project investigates the design of cluster randomized trials under budget constraints, focusing on optimizing the allocation of resources between the number of clusters and the number of measurements per cluster. Cluster randomized trials are commonly used in public health and clinical research to evaluate treatment effects when randomization occurs at the group level (e.g., hospitals or clinics) but outcomes are measured at the individual level. The goal of this project is to identify design strategies that minimize the variance of treatment effect estimates while balancing trade-offs between within-cluster and between-cluster variability.

### Simulation Framework

The simulation framework was guided by the ADEMP (Aims, Data-generating mechanisms, Estimands, Methods, and Performance measures) framework. Simulations were conducted using both Normal and Poisson data-generating mechanisms to reflect common outcome distributions in real-world trials. Key features of the framework include:
- **Aims**: To determine the optimal number of clusters ($G$) and measurements per cluster ($R$) under varying cost ratios ($c_1/c_2$) and variance structures.
- **Data-Generating Mechanisms**: Simulated datasets were generated under Normal and Poisson distributions, incorporating variance components ($\sigma^2$, $\gamma^2$) and treatment effects ($\beta$).
- **Optimization**: Resource allocation was optimized by varying $G$ and $R$ while satisfying a fixed budget constraint ($B = c_1 G + c_2 G R$).
- **Performance Measures**: Variance and power of the treatment effect estimate ($\hat{\beta}$) were evaluated across scenarios to identify optimal designs.

### Results

The results demonstrate that increasing the number of clusters ($G$) consistently reduces the variance of the treatment effect estimate ($\hat{\beta}$), though the benefits diminish beyond approximately $G = 40$. Lower cost ratios ($c_1/c_2 = 2, 5$) allocate more resources to within-cluster measurements ($R$), leading to steep reductions in variance at smaller cluster sizes, while higher cost ratios ($c_1/c_2 = 10, 20$) prioritize increasing the number of clusters, achieving low variance at larger $G$. Additionally, distributional assumptions significantly influence design performance. Under Normal outcomes, increasing residual variance ($\sigma^2$) weakens clustering effects and reduces precision, whereas Poisson outcomes are more sensitive to between-cluster variability ($\gamma^2$), which affects both variance and power. These findings emphasize the importance of tailoring design strategies to cost structures and the underlying data distribution to achieve optimal precision.

## Files

### Report
`PHP2550_Project3.Rmd`: The Rmarkdown version of the Regression Analysis report, which includes both written text interpretations and raw code used in the analysis. 

`PHP2550_Project3.pdf`: The PDF version of the Regression Analysis report, which includes both written text interpretations and a Code Appendix with the raw code used in the analysis. 

### Dataset

## Dependencies

The following packages were used in this analysis: 

 - Data Manipulation: `dplyr`, `tidyr`, `mice`, `caret`
 - Table Formatting: `gt`, `gtsummary`
 - Data Visualization: `ggplot2`, `ggpubr`, `ggExtra`, `gridExtra`, `predtools`, `pROC`
 - Model: `glmnet`, `boot`, `ISLR`
 
