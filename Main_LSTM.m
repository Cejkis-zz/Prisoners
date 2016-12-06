
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

tit = TwoInARow;
%tit = alwaysDefect;
lstm = LSTM_wrapper();

nets = length(NN);

learningRounds = 3;
rounds = 100;

Score = zeros(nets,rounds);

for i= 1:rounds
    
    i;

    history = ones(1,2);
    history2= ones(1,3);
    score = [0,0];
    rounds_ = 1000;
    for r = 1: rounds_

        pr = lstm.Action(history);
        p1 = round(pr); % get the move of each prisoner
        p2 = tit.Action([history(:,2),history(:,1)]); % history columns need to be swapped

        history = [history; p1 p2]; % update history matrix
        history2 = [history2; pr p1 p2]
        utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
        score = score + utilities;
    end
    
end

plot(Score')






