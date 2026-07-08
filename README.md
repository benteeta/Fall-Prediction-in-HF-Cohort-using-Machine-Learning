# Fall Prediction in Heart Failure Cohort using Machine Learning

Machine learning pipeline for predicting falls among people with heart failure using routinely collected healthcare data.

## Overview

This repository contains a reproducible analytic pipeline for developing and validating machine learning models to predict falls among patients with heart failure. The workflow includes cohort construction, feature engineering, frailty derivation, medication processing, missing data imputation, model development, validation, time-specific risk prediction, and an interactive Shiny dashboard.

No patient-level data are included in this repository. Synthetic data and template scripts are provided for demonstration only.

## Background

Falls are common and clinically important among people living with heart failure. They are associated with injury, hospitalisation, loss of independence, and increased healthcare use. Routinely collected healthcare data provide an opportunity to identify patients at increased risk and support more targeted prevention strategies.

This project uses routinely collected health data to develop and evaluate machine learning models for fall prediction in a heart failure cohort.

## Objectives

The objectives of this repository are to:

1. Construct an analysis-ready heart failure cohort for fall prediction.
2. Derive clinically relevant predictors, including demographics, multimorbidity, frailty, fall history, and medication use.
3. Develop and compare machine learning models for predicting falls.
4. Evaluate model performance using discrimination, classification metrics, and prediction error.
5. Generate time-specific fall risk predictions.
6. Demonstrate an interactive Shiny dashboard for population-level risk exploration.

## Analytic Workflow

```text
Raw routinely collected health data
        |
        v
Cohort creation
        |
        v
Feature engineering
        |
        v
Frailty and medication derivation
        |
        v
Missing data imputation
        |
        v
Development, test, and validation split
        |
        v
Machine learning model training
        |
        v
Model evaluation
        |
        v
External validation
        |
        v
Time-specific risk prediction
        |
        v
Interactive Shiny dashboard
```

## Candidate Predictors

The prediction pipeline includes the following groups of variables:

* Age group
* Sex
* Ethnic group
* Index of multiple deprivation
* Smoking status
* Alcohol intake
* Body mass index category
* Number of long-term conditions
* Frailty category
* Previous fall history
* Years since heart failure diagnosis
* Heart failure-specific medication use

## Outcome

The primary outcome is fall occurrence after heart failure diagnosis, identified using routinely recorded primary care and hospital admission data.

## Machine Learning Models

The modelling pipeline includes:

* Penalised logistic regression
* Random forest
* AdaBoost
* XGBoost
* LightGBM

Model performance is evaluated using:

* Area under the receiver operating characteristic curve
* Accuracy
* Sensitivity
* Specificity
* Brier score
* External validation performance

## Repository Structure

```text
Fall-Prediction-in-HF-Cohort-using-Machine-Learning/
│
├── README.md
├── LICENSE
├── CITATION.cff
├── .gitignore
│
├── R/
│   ├── 01_load_libraries.R
│   ├── 02_data_import_template.R
│   ├── 03_cohort_creation.R
│   ├── 04_feature_engineering.R
│   ├── 05_frailty_derivation.R
│   ├── 06_medication_processing.R
│   ├── 07_train_test_split.R
│   ├── 08_imputation.R
│   ├── 09_model_training.R
│   ├── 10_model_evaluation.R
│   ├── 11_external_validation.R
│   ├── 12_time_specific_risk.R
│   └── helper_functions.R
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── synthetic/
│
├── docs/
│   ├── analytic_pipeline.md
│   ├── variable_dictionary.md
│   ├── model_development.md
│   └── governance_note.md
│
├── outputs/
│   ├── figures/
│   ├── tables/
│   └── models/
│
├── shiny/
│   ├── app.R
│   └── README.md
│
└── manuscript/
```

## Data Governance

This repository does not contain patient-level data or identifiable information. The original analysis was developed for routinely collected healthcare data, but those data cannot be shared publicly due to data governance restrictions.

The repository will therefore provide:

* Synthetic example data
* Template data import scripts
* Reproducible analysis code
* Documentation of the analytic workflow

Users should not place identifiable or restricted health data in this public repository.

## Software

The analysis is implemented in R. Key packages include:

* `data.table`, `dplyr`, `tidyr`, `lubridate`
* `mice`
* `caret`
* `glmnet`
* `ranger`
* `ada`
* `xgboost`
* `lightgbm`
* `pROC`
* `shiny`
* `plotly`

## Project Status

This repository is under active development.

Current status:

* Cohort creation pipeline: in progress
* Feature engineering scripts: in progress
* Machine learning scripts: in progress
* Synthetic dataset: planned
* Shiny dashboard: in progress
* Documentation: in progress

## Citation

A citation file will be added once the first stable version of this repository is released.

## Licence

A licence will be added before public release of the completed repository.

## Contact

Benjamin Owusu
Postdoctoral Research Fellow
University of Exeter Medical School

GitHub: [@benteeta](https://github.com/benteeta)
