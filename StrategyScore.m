function [ results ] = StrategyScore( strategy, enemies, rounds )
%% evaluate strategy against other strategies (enemies) for ^ rounds.
% Todo: add mistake possibility

nrOfStrategies = length(enemies);
results = zeros(1,nrOfStrategies);

for j = 1:nrOfStrategies
    
    history = [];
    score = [0,0];
    
    for r = 1: rounds
        
        p1 = strategy.Action(history); % get the move of each prisoner
        
        if r > 1
            p2 = enemies{j}.Action([history(:,2),history(:,1)]); % history columns need to be swapped
        else
            p2 = enemies{j}.Action(history); % history columns need to be swapped
        end
        
        history = [history; p1 p2]; % update history matrix
        utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
        score = score + utilities;
    end
    
    results(j) = score(1)/rounds; % I dont know how to print nicely both
    
end

results = mean(results);

end

