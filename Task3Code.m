%% PARAMETERS
%set values of temperature to look at
Temperatures = logspace(-1,3,50);
%set length of spin sequence
SpinSeqLength = 200;
%set burn-in number
BurnIn = 50000;
%set number of samples to take (after burn-in)
%seems to need very large sample sizes (10^6) to behave smoothly for small
%temperatures
Samples = 1000000;
%constant a chosen for new energy equation / adapt if it is necessary 
a_values = [ 1.5, 2, 2.5];

%% M-H ALGORITHM
%function to perform a single pass of the algorithm
function [OutputSpinSeq,OutputEnergy] = MH_iteration(InputSpinSeq,InputEnergy,Temperature,a)
%choose random position in sequence to flip
SpinToFlip = randi(length(InputSpinSeq));
%create new sequence and flip the spin in that position
OutputSpinSeq = InputSpinSeq;
OutputSpinSeq(SpinToFlip) = -OutputSpinSeq(SpinToFlip);

%find energy change in O(N) time
OtherSpins = [1:SpinToFlip-1,SpinToFlip+1:length(InputSpinSeq)];
EnergyChange = 2*InputSpinSeq(SpinToFlip) * sum(InputSpinSeq(OtherSpins) ./ (abs(OtherSpins-SpinToFlip).^a));

%calculate acceptance probability
AcceptProb = min(1, exp(-EnergyChange/Temperature));
%generate random number on [0,1] and compare with acceptance probability
if rand <= AcceptProb
    %accept and output the new sequence and energy
    OutputEnergy = InputEnergy + EnergyChange;
else
    %reject the new sequence, output the old sequence and energy
    OutputSpinSeq = InputSpinSeq;
    OutputEnergy = InputEnergy;
end
end

%% ENERGY FUNCTION
function Energy = E(SpinSeq,a)
Energy = 0;
for i=1:length(SpinSeq)-1
    for j=i+1:length(SpinSeq)
        Energy = Energy - ((SpinSeq(i)*SpinSeq(j))/abs(i-j)^a);
    end
end
end

%% SAMPLING
%initialise vector to store average values of |mu|
AvgAbsMags = zeros(length(a_values), length(Temperatures));

%iterate over temperature values and a values
for k = 1:length(Temperatures)
    for h =1:length(a_values)
        %create (random) initial spin sequence and find initial energy
        SpinSeq = 2*floor(2*rand(1,SpinSeqLength))-1;
        Energy = E(SpinSeq,a_values(h));
        %initialise vector to store magnetisations
        Magnetisations = zeros(1,Samples);
        %run the burn-in period
        for i = 1:BurnIn
            [SpinSeq,Energy] = MH_iteration(SpinSeq,Energy,Temperatures(k),a_values(h));        
        end
        %take samples and their magnetisations
        for j=1:Samples
            [SpinSeq,Energy] = MH_iteration(SpinSeq,Energy,Temperatures(k),a_values(h));
            %calculate magnetisation (just equal to mean of spins), store in vector
            Magnetisations(j) = mean(SpinSeq);
        end
        %store estimate for |mu|
        AvgAbsMags(h,k) = mean(abs(Magnetisations));
    end
end

%% PLOTTING
figure;
semilogx(Temperatures,AvgAbsMags(1,:),'LineWidth',2,'Color','r')
hold on
semilogx(Temperatures,AvgAbsMags(2,:),'LineWidth',2,'Color','g')
semilogx(Temperatures,AvgAbsMags(3,:),'LineWidth',2,'Color','b')
xlabel("Temperature")
ylabel("Mean Absolute Magnetisation")
title("Estimate for $|\mu|$ as temperature varies", 'Interpreter','Latex')
fontsize(15,"points"); grid on
legend('$a=1.5$','$a=2$','$a=2.5$','Interpreter','Latex')

figure;
semilogx(Temperatures,AvgAbsMags(1,:),'LineWidth',2,'Color','r')
hold on
semilogx(Temperatures,AvgAbsMags(2,:),'LineWidth',2,'Color','g')
semilogx(Temperatures,AvgAbsMags(3,:),'LineWidth',2,'Color','b')

xlim([1 300]);
xlabel("Temperature")
ylabel("Mean Absolute Magnetisation")
title("Estimate for $|\mu|$ as temperature varies", 'Interpreter','Latex')
fontsize(15,"points"); grid on
legend('$a=1.5$','$a=2$','$a=2.5$','Interpreter','Latex')
