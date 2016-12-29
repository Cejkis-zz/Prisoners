
clear;
global Strategies;
% creating handlers for all strategies
alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;
iCTTBMF=IllCountToThreeButMayForget;
wWYDHT=WhatWillYouDoHT(15,0.25);
twoInARow=TwoInARow;

rounds = 200;
gamerounds = 100;

% Strategies = { NN};
Strategies = {  ...
    NeuralNetFFCustom([8 4 2], 10, gamerounds ),...
    NeuralNetFFCustom([5 6 4], 10, gamerounds ),...
    NeuralNetFFCustom([8 4], 10, gamerounds ),...
    AlwaysDefect,...
    };

nets = length(Strategies);

scoretime = nan(nets, rounds);

for i= 1:rounds
    
    score = zeros(nets,nets);
    
%     NN.TrainNN(enemies);
    
    for net = 1: nets
        for net2 = nets:-1:net
           v = pdGame(Strategies{net}, Strategies{net2}, gamerounds, 0.0);
           u = mean (v);
           score(net, net2) =  u(1);
           score(net2, net) =  u(2);
        end
    end
    
    scoretime(:,i) = mean(score');
    plot(scoretime')
    legend('NN1','NN2','NN3');
    pause(0.0001);
end

% legend('TFT','NN1', 'NN2', 'NN3', 'NN4', 'NN5','Turnevil')






