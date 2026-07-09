# Analytic Pipeline

## Overview

This document describes the complete analytic workflow used to develop and validate machine learning models for predicting falls among people with heart failure using routinely collected healthcare data.

---

## Pipeline Overview

```
Patient-level routinely collected healthcare data
                │
                ▼
      Cohort identification
                │
                ▼
     Feature engineering
                │
                ▼
    Frailty derivation (eFI)
                │
                ▼
 Medication exposure derivation
                │
                ▼
 Missing data handling
                │
                ▼
Development / Test / Validation split
                │
                ▼
Machine learning model development
                │
                ▼
Internal validation
                │
                ▼
External validation
                │
                ▼
Time-specific risk prediction
                │
                ▼
Interactive dashboard
```

---

## Step 1 – Cohort Construction

Patients with a diagnosis of heart failure were identified from routinely collected healthcare records.

The analysis cohort was assembled by integrating:

- Patient demographics
- Long-term conditions
- Body mass index
- Frailty
- Medication records
- Primary care falls
- Hospital admissions
- Mortality records

---

## Step 2 – Feature Engineering

Predictors were derived from demographic characteristics, multimorbidity, medication exposure, frailty, and previous falls.

Continuous variables were categorised where clinically appropriate.

---

## Step 3 – Missing Data

Missing predictor values were imputed using Multiple Imputation by Chained Equations (MICE).

Training data were imputed first, while test and validation datasets used imputation parameters derived from the development cohort.

---

## Step 4 – Model Development

Five prediction models were developed:

- Penalised Logistic Regression
- Random Forest
- AdaBoost
- XGBoost
- LightGBM

Hyperparameters were tuned using 10-fold cross-validation.

---

## Step 5 – Model Evaluation

Performance was evaluated using

- AUC
- Sensitivity
- Specificity
- Accuracy
- Brier score

The best-performing model was externally validated.

---

## Step 6 – Time-specific Risk Prediction

Individual risks were estimated for

- 3 months
- 6 months
- 12 months
- 24 months
- 36 months
- 60 months

---

## Step 7 – Interactive Dashboard

Predicted risks were visualised using a Shiny application allowing simulation by demographic and clinical characteristics.
