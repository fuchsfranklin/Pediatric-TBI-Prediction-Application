# Pediatric TBI Prediction Application

This repository contains the code for the Pediatric Traumatic Brain Injury (TBI) Prediction Application, a user-friendly web application that predicts the mortality of pediatric patients with TBI. The application is hosted [here](https://franklinfuchs.shinyapps.io/Pediatric-TBI-Prediction-Application/).

## Overview
Existing TBI mortality prediction models have not accounted for low pediatric patient mortality rates, thus underpredicting the non-survival of pediatric patients and undermining classifier prediction performance. This application aims to address this issue by providing a Machine Learning (ML)-based predictive model that accounts for both lower pediatric patient non-survival rates and non-linear variable interactions.

## Methodology
The model was trained comparing seven different Machine Learning (ML) techniques and Logistic Regression (LR) on subsampled United States National Trauma Databank (NTDB) Data, using double 5-fold cross-validation to independently tune model parameters and select variables. Synthetic Minority Over-sampling TEchnique (SMOTE) models were used to prevent performance deterioration, especially for neural network-based models. The SMOTE C5.0 model was found to be the best at simultaneously distinguishing between survivors and non-survivors, minimizing non-survivor underprediction, and maximizing the true non-survivor prediction probability. Thus, the SMOTE C5.0 model is the underlying model for the deployed app

## Application Features
The application allows users to input patient information, including:

* Gender
* Injury Type
* Race
* Supplemental Oxygen Use
* Drug Use
* Alcohol Use
* Abbreviated Injury Scale (AIS)
* Injury Severity Score (ISS)
* Glasgow Coma Scale (GCS)
* Age (Years)
* Systolic Blood Pressure (mmHg)
* Pulse Rate (mmHg)
* Respiratory Rate (bpm)
* Oxygen Saturation (%)
* Body Temperature (°C)

Based on these inputs, the application predicts the patient's mortality outcome.

## Usage
To use the application, navigate to the webpage, input the patient information in the provided fields, and click on the 'Predict' button. The application will then display the predicted outcome.

## Contributing
Contributions are welcome. Please open an issue to discuss your ideas or submit a pull request with your changes.
