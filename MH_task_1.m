
% M-H Task 1
clear; clc; close all;

f = @(x) exp(-5*(x-0.5).^2).*cos(3*pi*x)+1;
x0 = 0.5;
% rng(1)
markov_chain = met_has(f,10000,x0);
burn_in = 500;

function x = met_has(f, N, x0)
    % Create a matrix to store the Markov chain
    % Top row: index, bottom row: state value
    
    x = zeros(2, N);
    
    % Initial state
    x(1,1) = 1;
    x(2,1) = x0;
    
    for k = 1:N-1
        % Set index of next state
        x(1,k+1) = k+1;
    
        % Generate proposed state from Uniform(0,1)
        proposed_state = rand;
    
        % Calculate acceptance probability
        acceptance_ratio = f(proposed_state) / f(x(2,k));
        alpha = min(1, acceptance_ratio);
    
        % Accept or reject the proposed state
        % Generated from a Uniform distribution
        random_draw = rand;
    
        if random_draw < alpha
            x(2,k+1) = proposed_state;
        else
            x(2,k+1) = x(2,k);
        end
    
    end
end

% Calculate cumulative running average of the Markov chain
running_average = cumsum(markov_chain(2,:)) ./ (1:length(markov_chain(2,:)));

% Remove burn-in and extract sampled values
samples = markov_chain(2,burn_in+1:end);
sample_indices = markov_chain(1,burn_in+1:end);

% Plot traces with and without burn-in
figure(1)

% Full Markov chain
subplot(2, 1, 1)

hold on
plot(markov_chain(1,:), markov_chain(2,:), "LineWidth", 0.25);
plot(running_average, 'Color','Black', "LineWidth",1.5)
xlabel("Index of State in Markov Chain")
ylabel("Value of State in Markov Chain")
legend("Trace of Values", "Cumulative Average", "FontSize", 16, Location="northeast")
title("A Trace of the Markov Chain's State Values as M-H is Implemented", "FontSize", 16)
hold off

% Trace with burn-in removed
subplot(2, 1, 2)

hold on
plot(sample_indices, samples);
plot(sample_indices, running_average(burn_in+1:end),'Color','Black', "LineWidth",1.5)
xlim([0 10000])
xlabel("Index of State in Markov Chain")
ylabel("Value of State in Markov Chain")
legend("Trace of Values", "Cumulative Average", "FontSize", 16,Location="northeast")
title("A Trace of the Markov Chain's State Values with Burn-in Removed","FontSize", 16)
hold off


% Figure 2: Compare sampled distribution with normalised target density
figure(2)

% Remove burn-in and extract sampled values
samples = markov_chain(2,burn_in+1:end);
sample_indices = markov_chain(1,burn_in+1:end);

% Plot histogram of samples after burn-in
histogram(samples,50,'Normalization','pdf');
hold on

% Generate evenly spaced values over [0,1] to plot a smooth target density
x_values = linspace(0,1,10000);

% Calculate normalising constant and normalised target density
normalising_constant = integral(f,0,1);
normalised_density = f(x_values) / normalising_constant;

% Plot normalised target density
plot(x_values, normalised_density, "LineWidth",1.5)

% Format graph
xlim([0, 1])
ylim([0, 2.5])
title("Sample Histogram Compared With Normalised Target Density","FontSize", 16)
legend('Sample Histogram', 'Normalised Target Density',"FontSize", 16)
hold off

