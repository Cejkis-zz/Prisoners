%% Simulation of population over sevreal iterations.
clf
clear
figure(1)
%% Parameters
%The number of iterations the complete simulation will run for.
epochs=500;

% The initial magnitude of each sub population.
popMag=1000;

%The lowest possible population before dying out.
critPop=1;

%Rounds to run the pd-game for.
gameRounds=200;

%How much of the pd rounds that will be cut of. Eg 0.80 would mean that 10%
%at each end of the rounds will be cut of and averaged.
exPer=0.90;

%Setting for having a risk of mistakes happening.
mistakeProb=0.03;

%% Set up the involved strategies.

alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;
iCTTBMF=IllCountToThreeButMayForget;
wWYD15=WhatWillYouDo15;
twoInARow=TwoInARow;

%Set parameter values in the objects.
wWYD15.horizon=15;
wWYD15.tresh=0.25;

%Store in cell array.
strategiesHandles = {alwaysCoop, alwaysDefect, titForTat, turnEvil, random,iCTTBMF,wWYD15,twoInARow};
nrOfStrategies = length(strategiesHandles);

%% Set up initial population.

population=ones(nrOfStrategies,1);
population=population/norm(population).*popMag;

% Set up the line animations.
container=cell(nrOfStrategies,1);

for n=1:nrOfStrategies
    aline=animatedline('Color',[rand rand rand]);
    set(aline,'DisplayName',class(strategiesHandles{n}));
    container{n}=aline;
end

legend('Location','eastoutside')
legend('show')

%% CORE ALGO
startSave=floor(gameRounds*(1-exPer)/2);
endsave=gameRounds-startSave;

%For all of the epochs.
for n=1:epochs
    
    %Reset the states.
    threeCounter=0;
    
    %Draw the pop dynamics.
    for s=1:nrOfStrategies
        addpoints(container{s},n,population(s));
    end
    drawnow;

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
                p1 = h1.Action(history(1:r-1,:));
                %Change columns of the history for the opponent.
                p2 = h2.Action([history(1:r-1,2),history(1:r-1,1)]);
                
                %A mistake might occur. This causes choice to "flip".
                if(rand<mistakeProb)
                    p1=~p1;
                end
                if(rand<mistakeProb)
                    p2=~p2;
                end
                
                %Update history matrix.
                history(r,:) = [p1 p2];
                
                %Compute utilities for both players.
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
    
    %Calculate current epoch average score for all strategies, taking the
    %size of the population of the opposing strategy into account.
    %popScale=repmat(population'./sum(population),[size(results,1) 1]);
    %scaledResults=results.*popScale;
    %avgScorePerStrat=sum(scaledResults,2)/size(results,2);
    
    %Total average for the epoch.
    avgScoreForEpoch=mean(avgScorePerStrat);
    
    %Get the percentage of the average each strategy reached.
    fitness=avgScorePerStrat./avgScoreForEpoch;
    
    %Set the change in population depending on the fitness.
    population=population.*fitness;
    
    %Renormalize to correct population size.
    population=population./norm(population).*popMag;
    
    %If strategies falls below the critical point, they die and are removed.
    Gr=(population<critPop); %Gr-->GrimReaper has arrived.
    idx=find(Gr);
    if (idx)
        for p=1:length(idx)
        %Remove the strategy
        strategiesHandles{idx(p)}=[];
        
        %Remove the line from the update list.
        container{idx(p)}=[];
        end
        
        %Reformat the cell arrays
        strategiesHandles=strategiesHandles(~cellfun('isempty',strategiesHandles));
        container=container(~cellfun('isempty',container));
        
        %Update the count.
        nrOfStrategies=length(strategiesHandles);
        
        %Update the population variable
        population(Gr)=0;
        population=population(population~=0);

    end
    if(numel(population)==1)
        %Last man standing. Terminate simulation.
        break;
    end
    
    
    %Round to an integer amount of agents.
    population=round(population);
end

%Print the strategies still alive. And their share of the population.
disp(strategiesHandles)
disp(population')










