
clear;

popSize = 5;
c1 = 2;
c2 = 2;
weight = 1.4;
weightMin = 0.4;
weightFactor = 0.99;
nrOfVariables = 2;

xMax = 10;
xMin = -10;
xDiff = xMax - xMin;
vMax = 5;
alpha = 1;

population = rand(popSize,nrOfVariables)*xDiff + xMin; 
velocity = (rand(popSize,nrOfVariables)*xDiff - xDiff/2)*alpha; % time diff = 1
fitness = -Inf(popSize,1);

particleBest = population;
particleBestFitness = fitness;

swarmBest = [];
swarmBestFitness = -Inf;

for it = 1:10000
       
    for i = 1:popSize
        
        fitness(i) = CountFitness(population(i,:));
        
        if fitness(i) > particleBestFitness(i)
            
            particleBest(i,:) = population(i,:);
            particleBestFitness(i) = fitness(i);
            
            if fitness(i) > swarmBestFitness
                
                swarmBest = population(i,:);
                swarmBestFitness = fitness(i);
                fprintf('New swarm best: %f, x=%f y=%f\n',-swarmBestFitness, swarmBest(1),swarmBest(2));
            end
            
        end
        
    end
    
    for i = 1:popSize
        
        q = rand;
        r = rand;
        
        velocity(i,:) = weight*velocity(i,:) + c1*q*(particleBest(i,:) - population(i,:)) + c2*r*(swarmBest - population(i,:));
        
        % restriction
        if (norm(velocity(i,:))) > vMax
            velocity(i,:) = vMax * velocity(i,:)/norm(velocity(i,:));
        end
        
        population(i,:) = population(i,:) + velocity(i,:);
        
        for j = 1:nrOfVariables
           if population(i,j) > xMax
                population(i,j) = xMax;
           end
           if population(i,j) < xMin
                population(i,j) = xMin;
           end
        end
        
    end
    
    if weight > weightMin
        weight = weight*weightFactor;
    end
    
end



