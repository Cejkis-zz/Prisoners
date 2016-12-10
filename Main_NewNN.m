
clear;

% creating handlers for all strategies
alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;

global Strategies;

actionRounds = 50; % 

Strategies = {  ...
TitForTat,...
TurnEvil,...
NeuralNet2(3,[5 3],3,actionRounds),...
NeuralNet2(7,[5 3],3,actionRounds),...
NeuralNet2(2,[3 2],3,actionRounds),...
};

nets = length(Strategies);

learningRounds = 3;
iterations = 20;

Score = zeros(nets,iterations);

for i= 1:iterations
    
    i
    
    for net = 1:nets
        Score(net,i) = StrategyScore(Strategies{net}, Strategies, actionRounds);
    end
    
end

plot(Score')

% legend('TFT','NN1', 'NN2', 'NN3', 'NN4', 'NN5','Turnevil')






