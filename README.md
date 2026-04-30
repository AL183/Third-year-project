# Third-year-project
Title: Physics-Based Machine Learning for Transformer Winding Parameter Identification from Frequency Response Analysis

Introduction: The software is split into 2 parts. The first part of the software is used to generate the Frequency Response Analysis (FRA) data and to store it. The second part creates the machine learning model which predicts the physical parameters from the FRA data. 

Contextual overview: 1) Model a n-stage lumped-element LC ladder network. 2) Generates 2000 FRA samples by randomising L, Cs, and Cg parameters for each sample. 3) Normalises the data between -1 and 1. 4) Trains a neural network to predict the physical parameters from the FRA input data.
<img width="409" height="436" alt="image" src="https://github.com/user-attachments/assets/7c6b54f3-5065-42b3-8827-d244dc470e29" />

Installation Instructions: Install MATLAB and MATLAB deep learning toolbox. Save the 'Generation' file and 'ML' file. Run the 'Generation' file first then the 'ML' file.

How to run software: Open the 'Generation' file then press run. Open the 'ML' file then press run and wait for it to finish training. 

Technical details: The circuit modelled is a 10-stage lumped element LC ladder network. 500 frequency points are generated between 10 Hz and 1 MHz. The neural network uses Levenberg Marquardt algorithm for training with 500 input neurons, 2 hidden layers with 10 neurons each, and 3 output neurons. The transfer function is calculated using impedance matrices and current divider rule. Further details are provided in the lab report.  

Known issues and future work: Currently the machine learning model only predicts the overall parameters for L, Cs, and Cg. Future work could include generating separate parameters for each stage in the network, predicting the parameters for each stage in the network, and classifying faults based on the predicted parameters. 
