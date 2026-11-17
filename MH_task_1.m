%M-H task 1 
%M-H task 1

f = @(x) exp(-5*(x-0.5).^2).*cos(3*pi*x)+1 ;
x0 = 0.5;
rng(1)
markov_chain = met_has(f,1000,x0);

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
    %we actualise the probability by "rolling a dice"
    y = rand;
    if y < alpha
        x(2,k+1) = proposedstep;
    else
        x(2,k+1) = x(2,k);
    end
    
end
end

% plot trace
figure
plot(markov_chain(1,:), markov_chain(2,:))



% Include the burn in x(1000:end)
%hist function with f*play around some constant