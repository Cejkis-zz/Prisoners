
clear;

% creating handlers for all strategies

alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;
iCTTBMF=IllCountToThreeButMayForget;
wWYDHT=WhatWillYouDoHT(15,0.25);
twoInARow=TwoInARow;

global Strategies;

actionRounds = 100; % 

Strategies = {  ...
TitForTat,...
AlwaysCooperate,...
AlwaysDefect,...
TurnEvil,...
iCTTBMF,...
twoInARow,...
random,...
NeuralNet(3,[5 3],3,actionRounds),...
NeuralNet(7,[5 3],3,actionRounds),...
NeuralNet(2,[3 2],3,actionRounds),...
};

nets = length(Strategies);

learningRounds = 3;
iterations = 1;

Score = zeros(nets,iterations);

for i= 1:iterations
    
    i
    
    for net = 1:nets
        Score(net,i) = StrategyScore(Strategies{net}, Strategies, actionRounds);
    end
    
end

plot(Score')

% legend('TFT','NN1', 'NN2', 'NN3', 'NN4', 'NN5','Turnevil')






