%% PARAMETERS
%set values of temperature to look at
Temperatures = logspace(-1,3,10);
%set length of spin sequence
SpinSeqLength = 100;
%set burn-in number
BurnIn = 5000;
%set number of samples to take (after burn-in)
%seems to need very large sample sizes (10^6) to behave smoothly for small
%temperatures
Samples = 1000;
%constant a chosen for new energy equation / adapt if it is necessary 
a_values = [0.5, 1, 1.5, 2, 2.5];

%% M-H ALGORITHM
%function to perform a single pass of the algorithm
function OutputSpinSeq = MH_iteration(InputSpinSeq,Temperature,a)
%choose random position in sequence to flip
SpinToFlip = randi(length(InputSpinSeq));
%create new sequence and flip the spin in that position
OutputSpinSeq = InputSpinSeq;
OutputSpinSeq(SpinToFlip) = -OutputSpinSeq(SpinToFlip);

%initialising the energies of the spins
Energy = 0;
NewEnergy = 0;
%spin sequence energy change for the input 
%reviewed the computational complexity using both the vectorisation and
%for loops still give a O(N^2) complexity
for i=1:length(InputSpinSeq)
    for j=1:length(InputSpinSeq)
        if i ~= j
            Energy = Energy + -(InputSpinSeq(j) * InputSpinSeq(i)) / (abs(i-j))^a;
            NewEnergy = NewEnergy + -(OutputSpinSeq(j) * OutputSpinSeq(i)) / (abs(i-j))^a;
        end
    end
end


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
AvgAbsMags = zeros(length(a_values), length(Temperatures));

%iterate over temperature values
for k = 1:length(Temperatures)
    for h =1:length(a_values)
        %create (random) initial spin sequence
        SpinSeq = 2*floor(2*rand(1,SpinSeqLength))-1;
        %initialise vector to store magnetisations
        Magnetisations = zeros(1,Samples);
        %run the burn-in period
        for i = 1:BurnIn
            SpinSeq = MH_iteration(SpinSeq,Temperatures(k),a_values(h));        
        end
        %take samples and their magnetisations
        for j=1:Samples
            SpinSeq = MH_iteration(SpinSeq,Temperatures(k),a_values(h));
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
semilogx(Temperatures,AvgAbsMags(4,:),'LineWidth',2,'Color','y')
semilogx(Temperatures,AvgAbsMags(5,:),'LineWidth',2,'Color','k')
xlabel("Temperature")
ylabel("Mean Absolute Magnetisation")
title("Estimate for $|\mu|$ as temperature varies", 'Interpreter','Latex')
fontsize(15,"points"); grid on
legend('a=0.5','a=1','a=1.5','a=2','a=2.5')