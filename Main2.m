
clear;
ROUNDS = 100;

% creating handlers for all strategies
alwaysCoop = @AlwaysCooperate;
alwaysDefect = @AlwaysDefect;
titForTat = @TitForTat;
turnEvil = @TurnEvil;
random = @Random;

% Init of neural network
hiddenLayerSize = 5;
net = fitnet(hiddenLayerSize); % creates network
net.inputs{1}.size = 10; % 5 turns*2 players
net.trainParam.showWindow=0; % so that the pop up window doesn't show
net = train(net,zeros(10),1:10); % doesn't have any sense, just to init the network

%getwb(net) % 
%view(net) % to check parameters of network

strategiesForNN = {alwaysCoop, alwaysDefect, titForTat, turnEvil};

ParticleSwarm(net, strategiesForNN) % returns best weights





%%% Bottom code doesn't do anything meaningful
%%%

strategiesHandles = {alwaysCoop, alwaysDefect, titForTat, turnEvil, random};

nrOfStrategies = length(strategiesHandles);

% running them against each other
results = zeros(nrOfStrategies);

for i = 1:nrOfStrategies
   for j = 1:nrOfStrategies
       
       history = [];
       score = [0,0];
       
       for r = 1: ROUNDS
            p1 = strategiesHandles{i}(history); % get the move of each prisoner
            p2 = strategiesHandles{j}([history(:,2),history(:,1)]); % history columns need to be swapped
            
            history = [history; p1 p2]; % update history matrix
            utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
            score = score + utilities; 
       end
       
       results(i,j) = score(1); % I dont know how to print nicely both
       
    end
end



