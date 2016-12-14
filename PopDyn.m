%% Simulation of population over sevreal iterations.
clf
clear
figure(1)
%% Parameters
%The number of iterations the complete simulation will run for.
epochs=500;

% The total population size.
popSize=1000;

%The lowest possible sub-population before dying out.
critPop=1;

%Rounds to run the pd-game for.
gameRounds=350;

%How much of the pd rounds that will be cut of. Eg 0.80 would mean that 10%
%at the beginning and end of the rounds will be discarded in the average.
exPer=0.90;

%Setting for having a risk of mistakes happening.
mistakeProb=0.035;

%Severity scale. Used to either suppress or increase the harshness of the
%dynamics. Default is 1;
sevScale=1;

%Flag for saving the histories for the neuralNetworks. Data saved in a matrix.
%USAGE: To check the history between strategy i vs j in epoch k,
%call hist(k,i,j).
saveData=0;

%% Set up the involved strategies.

alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;
iCTTBMF=IllCountToThreeButMayForget;
wWYDHT=WhatWillYouDoHT(3,0.34);
twoInARow=TwoInARow;

rNNNet=RNNStrategy();
%swarmNet=NeuralNet(4,[3 2],1);

%Store in cell array.
%  strategiesHandles = {alwaysCoop, alwaysDefect, titForTat, turnEvil, random,iCTTBMF,wWYDHT,twoInARow};
% strategiesHandles = {titForTat,alwaysCoop, alwaysDefect, titForTat, turnEvil, random,twoInARow,rNNNet};
 strategiesHandles = {alwaysCoop, alwaysDefect, titForTat, turnEvil, random,twoInARow,iCTTBMF,wWYDHT};
nrOfStrategies = length(strategiesHandles);

%% Set up initial population.

population=ones(nrOfStrategies,1).*popSize/nrOfStrategies;

%Round to closest integers in case population is not properly divisible.
population=round(population);
popSize=sum(population);

% Set id for all strategies
for n=1:nrOfStrategies
    strategy=strategiesHandles{n};
    strategy.set_id(n);
end

%Set up the line animations.
%Preallocation.
container=repmat(animatedline,nrOfStrategies,1);

%Remove the dum-dum line.
clf

%Add the real lines.
for n=1:nrOfStrategies
   aline=animatedline('Color',[rand rand rand]);
   set(aline,'DisplayName',class(strategiesHandles{n}));
   container(n)=aline;
end

%Color network red (for presentation)
% for n=1:nrOfStrategies
%     if n==8
%         aline=animatedline('Color',[1 0 0]);
%         set(aline,'DisplayName',class(strategiesHandles{n}));
%         aline.LineWidth = 2;
%         container(n)=aline;
%     else
%         aline=animatedline('Color',[0 0 0]);
%         set(aline,'DisplayName',class(strategiesHandles{n}));
%         container(n)=aline;
%     end
% end

%Set up the legend object.
legend('Location','eastoutside');
leg=legend('show');
set(leg,'FontSize',10);

%% CORE ALGO
startSave=floor(gameRounds*(1-exPer)/2);
endsave=gameRounds-startSave;

%Preallocate the data storage if save is desired.
if(saveData)
    %Find the index of neural network strategies.
    hists=cell(epochs,nrOfStrategies,nrOfStrategies);
end

%For all of the epochs.
for n=0:epochs
    
    %Reset the states.
    iCTTBMF.resetState();
    
    %Draw the pop dynamics.
    for s=1:nrOfStrategies
        addpoints(container(s),n,population(s));
    end
    drawnow;
    
    results = zeros(nrOfStrategies);
    
    %Play all strategies against eachother.
    for i = 1:nrOfStrategies
        for j = nrOfStrategies:-1:(i+1)% +1 if you dont want to play yourself.
            
            %Extract the agents.
            a1=strategiesHandles{i};
            a2=strategiesHandles{j};
            
            %Play the PD-game.
            [utilities,hist]=pdGame(a1,a2,gameRounds,mistakeProb);
            
            %Extract only the relevant parts of the utility series.
            utilities=utilities(startSave:endsave,:);
            avgUtil=mean(utilities);
            
            %The result is the average payoff for strat i against j. Making
            %use of symetry.
            results(i,j) = avgUtil(1);
            results(j,i)=avgUtil(2);
            
            %Save data if desired.
            if(saveData)
                hists{n+1,a1.get_id(),a2.get_id()}=hist;
            end
        end
    end
    
    %Calculate current epoch average score for all strategies.
    avgScorePerStrat=sum(results,2)/size(results,2);
    
    %Total average for the epoch.
    %avgScoreForEpoch=mean(avgScorePerStrat);
    
    %Weighted average for the epoch.
    popShare=population./sum(population);
    avgScoreForEpoch=sum(avgScorePerStrat.*popShare);
    
    %Get the percentage of the average each strategy reached.
    fitness=avgScorePerStrat./avgScoreForEpoch;
    
    %Apply the severity scale.
    fitness=ones(size(fitness))-(ones(size(fitness))-fitness)*sevScale;
    
    %Set the change in population depending on the fitness.
    population=population.*fitness;
    
    %Round to an integer amount of agents.
%     population=round(population);
    
    %Renormalize to correct population size.
    popShare=population./sum(population);
    population=popShare.*popSize;
    
    %If strategies falls below the critical point, they die and are removed.
    Gr=(population<critPop); %Gr-->GrimReaper has arrived.
    idx=find(Gr);
    if (idx)
        
        for p=1:length(idx)
            %Remove the strategy/strategies.
            strategiesHandles{idx(p)}=[];
        end
        
        %Remove the line(s) from the update list.
        container(idx)=[];
        
        %Reformat the cell arrays.
        strategiesHandles=strategiesHandles(~cellfun('isempty',strategiesHandles));
        
        %Recreate the legend.
        leg=legend(container);
        
        %Update the count.
        nrOfStrategies=length(strategiesHandles);
        
        %Update the population variable.
        population(Gr)=0;
        population=population(population~=0);
        
    end
    if(numel(population)==1)
        %Last species standing. Terminate simulation.
        %Final update to population. Speicies sole survivor.
        population=popSize;
        break;
    end
end

%Print the strategies still alive. And their share of the population.
disp(strategiesHandles)
disp(population')










