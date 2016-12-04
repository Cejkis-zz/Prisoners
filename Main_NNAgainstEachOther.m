

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

NN{1} = NeuralNet(3,3);
NN{2} = NeuralNet(3,5);
NN{3} = NeuralNet(5,3);
NN{4} = NeuralNet(5,5);
NN{5} = NeuralNet(7,5);

nets = 5;
Score = zeros(nets,10);

learningRounds = 5;

for i=1:10
    
    for net = 1:nets
        
        if net == 1
            Score(net,i) = NN{net}.TrainNN({ NN{2:end}}, learningRounds); %
            continue;
        end
        
        if net == nets
            Score(net,i) = NN{net}.TrainNN({NN{1:end-1}}, learningRounds); %
            continue;
        end
        
        Score(net,i) = NN{net}.TrainNN({NN{1:net-1} NN{net+1:end}}, learningRounds); %
        
    end
end

plot(Score)






