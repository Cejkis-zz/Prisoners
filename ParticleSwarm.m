function [ output_args ] = ParticleSwarm(net )

% parameters of PSO
popSize = 10; % has impact on speed (default: 20)
c1 = 2; % impact of particle best value on velocity (default: 2)
c2 = 3; % impact of swarm best value on velocity (default: 2)
velocityFactor = 1.4; % initial value (default: 1.4)
velocityFactorChange = 0.99; % (between two iterations) (velocity * weightFactor^it) velocity factor factor :D (default: 0.99)
velocityFactorMin = 0.4; %(default: 0.4) 
vMax = 5; % max velocity (default: 5)

xMax = 10; % boundaries for weight value
xMin = -10;
%%%%%%%%%%%%%

xDiff = xMax - xMin;
nrOfVariables = length(getwb(net))

population = rand(popSize,nrOfVariables)*xDiff + xMin; % each row = one particle = weights for 
velocity = (rand(popSize,nrOfVariables)*xDiff - xDiff/2);
fitness = zeros(popSize,1);

particleBest = population;
particleBestFitness = fitness;

swarmBest = [];
swarmBestFitness = 0;

for it = 1:100
    
    fprintf('iteration: %d, avg fitness: %f\n ', it, mean(fitness));
    
    for i = 1:popSize
        
        fitness(i) = EvaluateNetwork(population(i,:), net);
        
        if fitness(i) > particleBestFitness(i)
            
            particleBest(i,:) = population(i,:);
            particleBestFitness(i) = fitness(i);
            
            if fitness(i) > swarmBestFitness
                
                swarmBest = population(i,:);
                swarmBestFitness = fitness(i);
                fprintf('New swarm best: %f\n', swarmBestFitness);
            end
            
        end
        
    end
    
    for i = 1:popSize
        
        q = rand;
        r = rand;
        
        velocity(i,:) = velocityFactor*velocity(i,:) + c1*q*(particleBest(i,:) - population(i,:)) + c2*r*(swarmBest - population(i,:));
        
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
    
    if velocityFactor > velocityFactorMin
        velocityFactor = velocityFactor*velocityFactorChange;
    end
    
end

output_args = swarmBest;



end

