
clear;

% creating handlers for all strategies
alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;

rounds = 100;
gamerounds = 100;

NN = {  ...
    TitForTat,...
    TurnEvil,...
    };

nets = length(NN);

score = zeros(nets,rounds);

for i= 1:rounds
    
    for net = 1: nets
        for net2 = nets:-1:net
           utilities = pdGame(NN{net}, NN{net2}, gamerounds, 0.02, net, net2);
           score(net, i) = score(net, i) + u1;
           score(net2, i)= score(net2, i) + u2;
        end
    end
    
    score(:,i) =  score(:,i)/rounds;
    
end

plot(score')

% legend('TFT','NN1', 'NN2', 'NN3', 'NN4', 'NN5','Turnevil')






