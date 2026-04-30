% Neural network to train and predict the physical parameters (L, Cs, and
% Cg) from frequency response analysis curves.


load('my_circuit_data.mat'); % Load the saved data created from generation code

num_samples = 2000; 
% Number of neurons for the neural network
x = 10; 
y = 10;

% Splitting the FRA into training, validation, and testing
trainIdx = 1:0.7*num_samples;
valIdx = 0.7*num_samples+1:0.85*num_samples;
testIdx  = 0.85*num_samples+1:num_samples;      

fprintf('Normalising...\n');

% Applying data normalisation based off the training data to prevent data
% leakage
[~, ps_in]  = mapminmax(x_fra(:, trainIdx)); 
[~, ps_out] = mapminmax(y_parameters(:, trainIdx));

% Apply the data
x_norm = mapminmax('apply', x_fra, ps_in);
y_norm = mapminmax('apply', y_parameters, ps_out);

net = fitnet([x,y]); % Create the neural network

% Setting up the training, validation, and testing sets
net.divideFcn = 'divideind';
net.divideParam.trainInd = trainIdx;
net.divideParam.valInd = valIdx;
net.divideParam.testInd  = testIdx;

fprintf('Training...\n'); 
[net, tr] = train(net, x_norm, y_norm); % Training the neural network


y_pred_norm = net(x_norm); % Predict the parameters after training the neural network
y_pred_real = mapminmax('reverse', y_pred_norm, ps_out); % Change the normalised data values back to actual values

% Get all actual and predicted values for the test set
actual_test = y_parameters(:, testIdx);
guess_test = y_pred_real(:, testIdx);

% Calculate the absolute percentage error for every single test sample
percent_errors = abs((actual_test - guess_test) ./ actual_test) * 100;

% Calculate the average (mean) error for each parameter across all test samples
avg_errors = mean(percent_errors, 2);

% Print the results
fprintf('\n--- AVERAGE TEST ERRORS (All %d Test Samples) ---\n', length(testIdx));

fprintf('L  : %.2f%%\n', avg_errors(1));
fprintf('Cs : %.2f%%\n', avg_errors(2));
fprintf('Cg : %.2f%%\n', avg_errors(3));

fprintf('Samples : %d\n', num_samples);
fprintf('Hidden layers : %d %d \n',x,y);
fprintf('Levenberg Marquardt \n');
