function [ fitness ] = EvaluateNetwork( weights, net )

net = setwb(net, weights); % set weights produced by swarm

history = [];
score = [0,0];

nrOfRounds = 50;

for i = 1:nrOfRounds
    
    p1 = TitForTat(history); % against which strategy will we play
    %p1 = AlwaysCooperate(history);
    
    if i < 6
        p2 = rand-0.5; % the first 5 choices are random
    else
        input = history([end-4:end],:);
        networkInput = reshape(input,[1,10])';
        p2 = sim(net, networkInput );
    end
    
    if p2 <0 % mapping from network output (R) to prisoner's dilemma
        p2 = 0;
    else
        p2 = 1;
    end
    
    history = [history; p1 p2]; % update history matrix
    utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
    score = score + utilities;
    
end

fitness = score(2)/nrOfRounds; % average score per round

fprintf('%f\n', fitness);

end

