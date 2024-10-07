# data manipulation
library(dplyr)
library(tidyr)

# summary tables
library(kableExtra)
library(gtsummary)
library(gt)

# interaction plots
library(ggplot2)
library(ggpubr)
library(ggExtra)
library(ggcorrplot)
library(lubridate)
library(ggridges)

# model
# library(lme4)
library(lmerTest)
library(broom.mixed)

# Load datasets
AQI <- read.csv("~/Desktop/PHP 2550/Data/aqi_values.csv")
Course <- read.csv("~/Desktop/PHP 2550/Data/course_record.csv")
Marathon <- read.csv("~/Desktop/PHP 2550/Data/marathon_dates.csv")
Project1<- read.csv("~/Desktop/PHP 2550/Data/project1.csv")

# Modify categorical variables
Project1 <- Project1 %>%
  rename(Race = Race..0.Boston..1.Chicago..2.NYC..3.TC..4.D.,
         Sex = Sex..0.F..1.M.)
Project1$Race <- as.factor(Project1$Race)
Project1$Sex <- as.factor(Project1$Sex)
Project1$Flag[Project1$Flag ==""] <- NA
Project1$Flag <- as.factor(Project1$Flag)
# Create categorical variable age_grp for age and modify humidity varibale

# Distribution of humidity
ggplot(Project1, aes(x = X.rh)) + 
  geom_histogram(fill = "skyblue", color="black") + 
  labs(x = "Percent Relative Humidity", y = "Count", title = "Figure 1: Histogram of Percent Relative Humidity") + 
  theme_minimal()

Project1 <- Project1 %>%
  mutate(age_grp = cut(Age..yr., breaks = c(0, 24, 39, 54, 69, Inf),
                       include.lowest = TRUE, 
                       labels = c("< 25 yrs", "25-39 yrs", "40-54 yrs", "55-69 yrs", ">= 70 yrs")),
         age_grp = factor(age_grp, levels = c("< 25 yrs", "25-39 yrs", "40-54 yrs", "55-69 yrs", ">= 70 yrs")),
         X.rh = ifelse(X.rh <= 1, X.rh*100, X.rh)) 
