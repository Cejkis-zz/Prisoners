
clear;
ROUNDS = 100;

% creating handlers for all strategies
alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;

%getwb(net) % 
%view(net) % to check parameters of network

strategiesForNN = {alwaysCoop, alwaysDefect, titForTat, turnEvil};

neural1 = NeuralNet(3,5);

Train(neural1, strategiesForNN, 100) % 


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



