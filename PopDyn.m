%% Simulation of population over sevreal iterations.
%% Parameters
%The number of iterations the complete simulation will run for.
epochs=1000;

% The size of each sub population.
subPop=100;

%Rounds to run the pd-game for.
gameRounds=1000;
%How much of the pd rounds that will be cut of. Eg 0.80 would mean that 10%
%at each end of the rounds will be cut of and averaged.
exPer=0.75;

%% State variables.
global isEvil;
isEvil=0;

%% Set up the involved strategies.

alwaysCoop = @AlwaysCooperate;
alwaysDefect = @AlwaysDefect;
titForTat = @TitForTat;
turnEvil = @TurnEvil;
random = @Random;
iCTTBMF=@IllCountToThreeButMayForget;
WWYD15=@WhatWillYouDo15;

%Store in cell.
strategiesHandles = {alwaysCoop, alwaysDefect, titForTat, turnEvil, random,WWYD15,iCTTBMF};
nrOfStrategies = length(strategiesHandles);


%% CORE ALGO

%For all of the epochs
for n=1:epochs
    
    %Play all strategies against eachother
    
    results = zeros(nrOfStrategies);
    
    for i = 1:nrOfStrategies
        for j = 1:nrOfStrategies
            
            history = zeros(gameRounds,2);
            utilities = zeros(gameRounds,2);
            startSave=floor(gameRounds*(1-exPer)/2);
            endsave=gameRounds-startSave;
            
            %Play the PD-game.
            for r = 1: gameRounds
                
                 % get the move of each prisoner
                p1 = strategiesHandles{i}(history);
                p2 = strategiesHandles{j}(history);
                
                % update history matrix
                history(r,:) = [p1 p2]; 
                
                % compute utilities for both prisoners
                utilities(r,:) = PrisonersRound(p1, p2);
            end
            
            %Extract only the relevant parts of the utility series.
            utilities=utilities(startSave:endsave,:);
            
            %The result is the average payoff for strat i against j
            results(i,j) = mean(utilities);
            
        end
    end
    
end

disp('Done!')










