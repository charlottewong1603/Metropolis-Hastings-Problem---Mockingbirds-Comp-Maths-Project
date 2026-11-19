
% M-H Task 1
clear; clc; close all;

f = @(x) exp(-5*(x-0.5).^2).*cos(3*pi*x)+1;
x0 = 0.5;
% rng(1)
markov_chain = met_has(f,10000,x0);
burn_in = 500;

function markov_chain = met_has(f, N, x0)
% Create a matrix of size 2 x N to store the Markov chain
% Top row: index, bottom row: state value

markov_chain = zeros(2, N);

% Initial state
markov_chain(1,1) = 1;
markov_chain(2,1) = x0;

for k = 1:N-1 % Because we calculate the k+1 state
    markov_chain(1,k+1) = k+1; % Index is set regardless

    % Generate proposed state from Uniform(0,1)
    proposed_state = rand;

    % Calculate acceptance probability
    acceptance_ratio = f(proposed_state) / f(markov_chain(2,k));
    alpha = min(1, acceptance_ratio);

    % Determine whether to accept proposed state
    random_draw = rand;

    if random_draw < alpha
        markov_chain(2,k+1) = proposed_state;
    else
        markov_chain(2,k+1) = markov_chain(2,k);
    end

end
end

% Plot trace with running average
running_average = cumsum(markov_chain(2,:)) ./ (1:length(markov_chain(2,:)));

figure(1)

hold on
plot(markov_chain(1,:), markov_chain(2,:), "LineWidth", 0.25);
plot(running_average, 'Color','Black', "LineWidth",1)
xlabel("Index of State in Markov Chain")
ylabel("Value of State in Markov Chain")
legend("Trace of Values", "Cumulative Average", Location="northeast")
title("A Trace of the Markov Chain's State Values as M-H is Implemented")
hold off

% Plot histogram against target density

figure(2)

% Remove burn-in and extract sampled values
samples = markov_chain(2,burn_in+1:end);
sample_indices = markov_chain(1,burn_in+1:end);

% Plot histogram of samples
histogram(samples,50,'Normalization','pdf');
hold on

% Plot target density
x1 = linspace(0,1,10000);
normalisingconstant = integral(f,0,1);
plot(x1, f(x1)/normalisingconstant, "LineWidth",1)

% Format graph
xlim([0, 1])
ylim([0,2.5])
title("Sample Histogram Compared With Original Density Function")
legend('Sample histogram', 'Original Function with normalising constant = 1')
hold off

% Trace with burn-in removed
figure(3)

hold on;
plot(sample_indices, samples);
plot(sample_indices, running_average(burn_in+1:end),'Color','Black', "LineWidth",1)
xlim([0 10000])
xlabel("Index of State in Markov Chain")
ylabel("Value of State in Markov Chain")
legend("Trace of Values", "Cumulative Average", Location="northeast")
title("A Trace of the Markov Chain's State Values with Burn-in Removed")
hold off;
