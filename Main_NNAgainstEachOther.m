
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

NN = {};

NN{1} = TitForTat;
NN{2} = NeuralNet(4,4);
NN{3} = NeuralNet(4,[3 3]);
NN{4} = NeuralNet(4,[5 3]);
NN{5} = NeuralNet(3,[4 2]);
NN{6} = NeuralNet(5,[4 2]);

nets = length(NN);

learningRounds = 3;
rounds = 20;

Score = zeros(nets,rounds);

for i= 1:rounds
    
    i
    
    for net = 1:nets

        NNOponents = NN;
        NNOponents(net) = []; % play against all except yourself   
        
        if class(NN{net}) == 'NeuralNet'
            Score(net,i) = NN{net}.TrainNN(NNOponents, learningRounds); %
        else
            Score(net,i) = StrategyScore(NN{net}, NNOponents, 50);
        end
        
    end
    
end

plot(Score')






