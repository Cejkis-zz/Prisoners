function [ payoff ] = EvaluateNetwork( weights, net, strategiesForNN )
% for given weights and network runs the prisoners dilemma and returns
% average payoff for all given strategies.

net = setwb(net, weights); % set weights produced by particle swarm swarm

score = [0,0];
nrOfRounds = 50;

for strategy = strategiesForNN
    
    history1 = [];
   % history2 = []; % NN doesn't give a damn about history ordering, so we
   % can use 1 matrix for both.
    
    for i = 1:nrOfRounds
        
        p1 = strategy{1}(history1); % against which strategy will we play
        
        if i < 6
            p2 = rand-0.5; % the first 5 choices are random
        else
            input = history1([end-4:end],:);
            networkInput = reshape(input,[1,10])';
            p2 = sim(net, networkInput );
        end
        
        if p2 <0 % mapping from network output (R) to prisoner's dilemma
            p2 = 0;
        else
            p2 = 1;
        end
        
        history1 = [history1; p1 p2]; % update history matrix
        utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
        score = score + utilities;
        
    end
end

payoff = (score(2)/nrOfRounds)/length(strategiesForNN); % average score per round

fprintf('%f\n', payoff);

end

