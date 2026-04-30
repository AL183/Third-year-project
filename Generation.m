% Code to simulate a lumped element LC ladder network and to generate 2000 
% frequency response analysis curves (with 500 frequency points each) based on 
% randomisation of physical parameters of (L,Cs, and Cg). 


clear; clc; 

num_samples = 2000; % Total number of samples generated
f_points = 500;     % Total number of frequency points for each sample
f = logspace(1, 6, f_points);% 10 Hz to 1 MHz 
omega = 2 * pi * f;  % Angular frequency formula

% Setting up the base parameters 
n  = 10;   % Number of stages in the ladder network
base.R = 50; % Base resistance
base.L = 1.58e-3; % Base inductance
base.Cs = 5.67e-12; % Base series capacitance
base.Cg = 5460e-12; % Base ground capacitance

x_fra = zeros(f_points, num_samples); % Array to store the FRA data
y_parameters= zeros(3, num_samples); % Array to store the physical parameters

fprintf('Generating Data...');

% Loop through each sample to generate FRA curve
for i = 1:num_samples
    % Randomise parameters 
    L  = base.L  * (0.2 + 4.8*rand()); % 3.16e-4 to 7.9e-3 H 
    Cs = base.Cs * (0.2 + 4.8*rand()); % 1.134e-12 to 2.835e-11 F
    Cg = base.Cg * (0.2 + 4.8*rand()); % 1.092e-9 to 2.73e-8 F
    
    % Store parameters
    y_parameters(:, i) = [L; Cs; Cg]; % Store the physical parameters (L, Cs, and Cg)
         
    % Calculating the values for each stage in the network
    Cs_stage = n * Cs; 
    Cg_stage = Cg / n; 
    L_stage = L/n;

    % Calculating the impedances for L, Cs, and Cg
    ZL  = 1i * omega * (L_stage);     
    ZCs = 1 ./ (1i * omega * Cs_stage);    
    ZCg = 1 ./ (1i * omega * Cg_stage);    

    % Combining impedances in parallel and series
    ZCsL = (ZL .* ZCs) ./ (ZL + ZCs); % Combine in parallel the impedance of ground capacitor and inductor. ZCsL is a repeating unit
    ZRCg = (base.R .* ZCg) ./ (base.R + ZCg); % Combine in parallel the impedance of ground capacitor and base resistor 
    ZN = ZRCg + ZCsL; % Combine in series the impedance of ZRCg and ZCsL
    
    % Calculating the accumulating impedance across at each stage
    Zstage = zeros(n, f_points);  % Create a matrix to store the accumulating impedance at each stage
    Zstage(1,:) = ZN; % Store ZN in the first row of Zstage      
    for k = 2:n % For loop to calculate the accumulating impedance at each stage 
        Zpar = (Zstage(k-1,:) .* ZCg) ./ (Zstage(k-1,:) + ZCg); % Combines the accumulating impedance from the previous stage in parallel with the impedance of the ground capacitor 
        Zstage(k,:) = Zpar + ZCsL; % Combines the impedance of Zpar with ZCsL in series and stores this in the kth row of the Zstage matrix
    end
    
    % Calculating the current at each stage 
    Istage = zeros(n, f_points); % Create a matrix to store the split current at each stage
    I = 1; % Inject a current of 1 A
    Istage(1,:) = (I .* ZCg) ./ (ZCg + Zstage(n,:)); % Split the current between the ground capacitor and rest of circuit by current divider rule and store the first split current into the first row
    for k = 2:n % For loop for calculating the split current at each stage 
        Istage(k,:) = (Istage(k-1,:) .* ZCg) ./ (ZCg + Zstage(n - k + 1,:)); % Split the previous current with the ground capacitor and rest of the circuit and store into the kth row in Istage
    end
    
    % Calculating the final outputs of the circuits 
    Final_current = (Istage(n,:) .* ZCg) ./ (ZCg + base.R);       
    Total_impedance = (Zstage(n,:) .* ZCg) ./ (Zstage(n,:) + ZCg);
    H_f = (Final_current * base.R) ./ (I .* Total_impedance);
    

    % Convert the magnitude to dB 
    x_fra(:, i) = 20 * log10(abs(H_f))'; 
end
fprintf(' Done.\n');


sample_idx = 1; % Choosing first sample for plot

figure;
% Plot frequency vs the magnitude of one sample
semilogx(f, x_fra(:, sample_idx), 'LineWidth', 2); 
grid on;
title(['FRA Curve for Sample #', num2str(sample_idx)]);
xlabel('Frequency (Hz)'); % Add label for x axis
ylabel('Magnitude (dB)'); % Add label for y axis
xlim([min(f) max(f)]);

fprintf('Plot generated for Sample #%d\n', sample_idx);

% Save the data into a file
save('my_circuit_data.mat', 'x_fra', 'y_parameters');


% Extract the data for L, Cs, and Cg
L = y_parameters(1, :);
Cs = y_parameters(2, :);
Cg = y_parameters(3, :);

% Create a 3D plot to show the distribution of L, Cs, and Cg
figure;
scatter3(L, Cs, Cg, 'filled');

% Add labels to the plot
xlabel('L');
ylabel('Cs');
zlabel('Cg');
grid on;