%M-H task 1 
%M-H task 1
clear; clc; close all;

f = @(x) exp(-5*(x-0.5).^2).*cos(3*pi*x)+1 ;
x0 = 0.5;
%rng(1)
markov_chain = met_has(f,10000,x0);
burn_in = 500;

function x = met_has(f, N, x0)
%Create a vector of size N - Where we will generate our Markov chain

x = zeros(2, N); %top row: index, bottom row: value

%initial x
x(1,1) = 1;%index = first value
x(2,1) = x0;

for k=1:N-1 %because we reach for the k+1 value
    x(1,k+1) = k+1; %index is set regardless
    %we draw some value from uniform sample = proposedstep
    proposedstep = rand;

    % The acceptance probability generated
    ratio =  f(proposedstep)  /f(x(2,k));
    alpha = min(1, ratio);
    %we actualize the probability by "rolling a dice"
    y = rand;
    if y < alpha
        x(2,k+1) = proposedstep;
    else
        x(2,k+1) = x(2,k);
    end

end
end

% plot trace
%with a running average to see burn in
runningaverage = cumsum(markov_chain(2,:)) ./ (1:length(markov_chain(2,:)));

figure(1)

hold on
plot(markov_chain(1,:), markov_chain(2,:), "LineWidth", 0.25);
plot(runningaverage, 'Color','Black', "LineWidth",1)
xlabel("Index of State in Markov Chain")
ylabel("Value of State in Markov Chain")
legend("Trace of Values", "Cumulative Average", Location="northeast")
title("A Trace of the Markov Chain's State's Values as M-H is Implemented")
hold off

% Plot histogram against target density

figure(2)

% Remove burn-in and extract sampled values
samples = markov_chain(2,burn_in+1:end);
samplesindex = markov_chain(1,burn_in+1:end);

% Plot histogram of samples
histogram(samples,50,'Normalization','pdf');
hold on

% Plot target density
x1 = sort(samples);
normalisingconstant = integral(f,0,1);
normalised_data = f(x1) / normalisingconstant;
plot(x1, normalised_data, "LineWidth",1)

% Format graph
xlim([0, 1])
title("Sample Histogram Compared With Original Density Function")
legend('Sample histogram', 'Original Function with normalising constant = 1')
hold off

%trace with burnin removed
figure(3)
hold on;
plot(samplesindex, samples);
plot(samplesindex, runningaverage(burn_in+1:end),'Color','Black', "LineWidth",1)
xlim([0 10000])
xlabel("Index of State in Markov Chain")
ylabel("Value of State in Markov Chain")
legend("Trace of Values", "Cumulative Average", Location="northeast")
title("A Trace of the Markov Chain's State's Values with Burn-in Removed")
hold off;
