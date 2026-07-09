# Machine Learning Pipeline

## Development Strategy

The cohort was randomly divided into

- Development cohort (50%)
- Internal training set (70%)
- Internal test set (30%)
- External validation cohort (50%)

---

## Missing Data

Missing predictors were imputed using MICE.

---

## Algorithms

- Penalised Logistic Regression
- Random Forest
- AdaBoost
- XGBoost
- LightGBM

---

## Hyperparameter Tuning

All models were tuned using 10-fold cross-validation.

The optimisation metric was AUC.

---

## Model Selection

The model with the highest AUC in the internal test cohort was selected.

---

## External Validation

Performance was evaluated in an independent validation cohort.

---

## Risk Prediction

Final probabilities were converted into

- 3-month risk
- 6-month risk
- 1-year risk
- 2-year risk
- 3-year risk
- 5-year risk
