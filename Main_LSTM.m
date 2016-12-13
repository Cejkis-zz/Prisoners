
clear;
ROUNDS = 100;

% creating handlers for all strategies
alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;



strategiesForNN = {alwaysCoop, alwaysDefect, titForTat, turnEvil};

NN = {};

%tit =  IllCountToThreeButMayForget(); %TwoInARow(); %TitForTat();
%tit = WhatWillYouDoHT(3,0.34);
tit = TitForTat();
lstm = RNNStrategy();

nets = length(NN);

learningRounds = 3;
rounds = 1;

Score = zeros(nets,rounds);

for i= 1:rounds
    
    i

    history =    [];
              
    history2= [];
    score = [0,0];
    rounds_ = 15000;
    for r = 1: rounds_
        
        pr = lstm.Action(history, 2);
        p1 = round(pr(1)); % get the move of each prisoner
        if r > 1
        p2 = tit.Action([history(:,2),history(:,1)],2); % history columns need to be swapped
        else
        p2 = tit.Action(history,1);
        end
        history = [history; p1 p2]; % update history matrix
        history2 = [history2; pr p1 p2];
        utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
        score = score + utilities;
    end
    history2
end

plot(Score')






