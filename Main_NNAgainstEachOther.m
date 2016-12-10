
clear;

% creating handlers for all strategies
alwaysCoop = AlwaysCooperate;
alwaysDefect = AlwaysDefect;
titForTat = TitForTat;
turnEvil = TurnEvil;
random = Random;


NN = {  ...
TitForTat,...
NeuralNet(5,4,1),...
NeuralNet(4,[3 3],1),...
NeuralNet(3,[5 3],1),...
NeuralNet(7,[5 3],1),...
NeuralNet(2,[3 2],1),...
NeuralNet(4,[5 3 2],1),...
TurnEvil,...
NeuralNet(5,4,5),...
NeuralNet(4,[3 3],5),...
NeuralNet(3,[5 3],5),...
NeuralNet(7,[5 3],5),...
NeuralNet(2,[3 2],5),...
NeuralNet(4,[5 3 2],5),...
};

nets = length(NN);

learningRounds = 3;
rounds = 100;

Score = zeros(nets,rounds);

for i= 1:rounds
    
    i
    
    for net = 1:nets

        NNOponents = NN;
        NNOponents(net) = []; % play against all except yourself   
        
        if isa(NN{net},'NeuralNet')
            Score(net,i) = NN{net}.TrainNN(NNOponents, learningRounds); %
        else
            Score(net,i) = StrategyScore(NN{net}, NNOponents, 50);
        end
        
    end
    
end

plot(Score')

% legend('TFT','NN1', 'NN2', 'NN3', 'NN4', 'NN5','Turnevil')






