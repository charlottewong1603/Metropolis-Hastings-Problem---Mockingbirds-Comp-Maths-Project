%M-H task 1 
%M-H task 1
rng(1)
function [M-H] = met_has(f, N, x0)
%Create a vector of size N - Where we will generate our
%Markov chain
x = zeros(1, N);
%x
x[1] = x0;

for k=1:N+1
    Ho_Accepted = True
    %we draw some value from uniform sample = proposedstep
    % The acceptance probability generated
    ratio =  (f(proposedstep)  /f( x[k] );
    alpha = min(1, ratio);
    y = rand[0,1]
    if y < alpha
        x[k+1] = proposedstep
    else
        x[k+1] = x[k]
    end
    % plot trace
    % Include the burn in x(1000:end)
    %hist function with f*play around some constant

    x0 <



    for i=1:N
    end
