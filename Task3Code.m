%% PARAMETERS
%set values of temperature to look at
Temperatures = logspace(-1,2,31);
%set length of spin sequence
SpinSeqLength = 50;
%set burn-in number
BurnIn = 5000;
%set number of samples to take (after burn-in)
%seems to need very large sample sizes (10^6) to behave smoothly for small
%temperatures
Samples = 1000000;

%% M-H ALGORITHM
%function to perform a single pass of the algorithm
function OutputSpinSeq = MH_iteration(InputSpinSeq,Temperature)
%choose random position in sequence to flip
SpinToFlip = randi(length(InputSpinSeq));
%create new sequence and flip the spin in that position
OutputSpinSeq = InputSpinSeq;
OutputSpinSeq(SpinToFlip) = -OutputSpinSeq(SpinToFlip);
%calculate energy before and after spin flip
Energy = -sum(InputSpinSeq(1:end-1).*InputSpinSeq(2:end));
NewEnergy = -sum(OutputSpinSeq(1:end-1).*OutputSpinSeq(2:end));
%calculate acceptance probability
AcceptProb = min(1, exp((Energy-NewEnergy)/Temperature));
%generate random number on [0,1] and compare with acceptance probability
if rand <= AcceptProb
    %accept and output the new sequence
else
    %reject the new sequence, output the old sequence
    OutputSpinSeq = InputSpinSeq;
end
end

%% SAMPLING
%initialise vector to store average values of |mu|
AvgAbsMags = zeros(1,length(Temperatures));
%iterate over temperature values
for k = 1:length(Temperatures)
    %create (random) initial spin sequence
    SpinSeq = 2*floor(2*rand(1,SpinSeqLength))-1;
    %initialise vector to store magnetisations
    Magnetisations = zeros(1,Samples);
    %run the burn-in period
    for i = 1:BurnIn
        SpinSeq = MH_iteration(SpinSeq,Temperatures(k));
    end
    %take samples and their magnetisations
    for j=1:Samples
        SpinSeq = MH_iteration(SpinSeq,Temperatures(k));
        %calculate magnetisation (just equal to mean of spins), store in vector
        Magnetisations(j) = mean(SpinSeq);
    end
    %store estimate for |mu|
    AvgAbsMags(k) = mean(abs(Magnetisations));
end

%% PLOTTING
figure;
semilogx(Temperatures,AvgAbsMags,'LineWidth',2,'Color','r')
xlabel("Temperature")
ylabel("Mean Absolute Magnetisation")
title("Estimate for $|\mu|$ as temperature varies", 'Interpreter','Latex')
fontsize(15,"points"); grid on