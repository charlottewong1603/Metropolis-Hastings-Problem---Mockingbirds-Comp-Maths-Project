%% PARAMETERS
%set some values of the temperature parameter to produce histograms from
Temperatures = [1,10,1000];
%set length of spin sequence
SpinSeqLength = 50;
%set burn-in number
BurnIn = 5000;
%set number of samples to take (after burn-in)
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
%create (random) initial spin sequence
SpinSeq = 2*floor(2*rand(1,SpinSeqLength))-1;
%initialise vector to store magnetisations
Magnetisations = zeros(3,Samples);

for k = 1:length(Temperatures)
    %run the burn-in period
    for i = 1:BurnIn
        SpinSeq = MH_iteration(SpinSeq,Temperatures(k));
    end
    %take samples and their magnetisations
    for j=1:Samples
        SpinSeq = MH_iteration(SpinSeq,Temperatures(k));
        %calculate magnetisation (just equal to mean of spins), store in vector
        Magnetisations(k,j) = mean(SpinSeq);
    end
end

%% PLOTTING
%bin edges (ensures 1 bin for 1 possible value of magnetisation)
edges = linspace(-1-1/SpinSeqLength,1+1/SpinSeqLength,SpinSeqLength+2);
%make histograms
figure;
for k = 1:length(Temperatures)
    subplot(1,length(Temperatures),k)
    histogram(Magnetisations(k,:),edges)
    xlabel("Magnetisation")
    ylabel("Frequency")
    ylim([0,120000])
    title("T = " + Temperatures(k))
    fontsize(20,"points")
end