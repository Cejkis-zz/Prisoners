
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

tit =  TwoInARow(); %TitForTat();
%tit = alwaysDefect;
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
    rounds_ = 25000;
    for r = 1: rounds_
        
        pr = lstm.Action(history);
        p1 = round(pr(1)); % get the move of each prisoner
        if r > 1
        p2 = tit.Action([history(:,2),history(:,1)]); % history columns need to be swapped
        else
        p2 = tit.Action(history);
        end
        history = [history; p1 p2]; % update history matrix
        history2 = [history2; pr p1 p2];
        utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
        score = score + utilities;
    end
    history2
end

plot(Score')






