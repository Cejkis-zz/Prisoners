%% Simulation of population over sevreal iterations.
clf
clear
figure()
%% Parameters
%The number of iterations the complete simulation will run for.
epochs=100;

% The size of each sub population.
subPop=100;

%Rounds to run the pd-game for.
gameRounds=100;
%How much of the pd rounds that will be cut of. Eg 0.80 would mean that 10%
%at each end of the rounds will be cut of and averaged.
exPer=0.80;

%% State variables.
global isEvil threeCounter;
isEvil=0;
threeCounter=0;

%% Set up the involved strategies.

alwaysCoop = @AlwaysCooperate;
alwaysDefect = @AlwaysDefect;
titForTat = @TitForTat;
turnEvil = @TurnEvil_state;
random = @Random;
iCTTBMF=@IllCountToThreeButMayForget;
WWYD15=@WhatWillYouDo15;

%Store in cell array.
strategiesHandles = {alwaysCoop, alwaysDefect, titForTat, turnEvil, random,WWYD15,iCTTBMF};
nrOfStrategies = length(strategiesHandles);

%% Set up initial population.

population=ones(nrOfStrategies,1)*subPop;

% Set up the line animations.

container=cell(nrOfStrategies,1);
colorConst=1/nrOfStrategies*rand;

for n=1:nrOfStrategies
    container{n}=animatedline('Color',[colorConst*n colorConst*n colorConst*n]);
end

%% CORE ALGO
startSave=floor(gameRounds*(1-exPer)/2);
endsave=gameRounds-startSave;

%For all of the epochs.
for n=1:epochs
    
    %Reset the states.
    isEvil=0;
    threeCounter=0;
    
    %Draw the pop dynamics.
    for s=1:nrOfStrategies
        addpoints(container{s},n,population(s));
    end
    drawnow;
    %pause(0.1);
    %plot(repmat(n,size(population))',population')
    %scatter(repmat(n,size(population)),population);
    
    
    results = zeros(nrOfStrategies);
    
    %Play all strategies against eachother.
    for i = 1:nrOfStrategies
        for j = nrOfStrategies:-1:(i+1)
            
            %Reset history and util.
            history = zeros(gameRounds,2);
            utilities = zeros(gameRounds,2);
            h1=strategiesHandles{i};
            h2=strategiesHandles{j};
            
            %Play the PD-game.
            for r = 1: gameRounds
                
                % get the move of each player.
                p1 = h1(history(1:r-1,:));
                p2 = h2([history(1:r-1,2),history(1:r-1,1)]);
                
                % update history matrix.
                history(r,:) = [p1 p2];
                
                % compute utilities for both players.
                utilities(r,:) = PrisonersRound(p1, p2);
            end
            
            %Extract only the relevant parts of the utility series.
            utilities=utilities(startSave:endsave,:);
            avgUtil=mean(utilities);
            
            %The result is the average payoff for strat i against j. Making
            %use of symetry.
            results(i,j) = avgUtil(1);
            results(j,i)=avgUtil(2);
            
        end
    end
    
    %Calculate current epoch average score for all strategies.
    avgScorePerStrat=sum(results,2)/size(results,2);
    
    %Total average for the epoch.
    avgScoreForEpoch=mean(avgScorePerStrat);
    
    %Get the percentage of the average each strategy reached.
    fitness=avgScorePerStrat./avgScoreForEpoch;
    
    %Set the change in population depending on the fitness.
    population=population.*fitness;
    
    %Renormalize to correct population size.
    population=population./norm(population).*subPop;
    
end











