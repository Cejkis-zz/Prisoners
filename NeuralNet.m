classdef NeuralNet < Strategy & handle
    %NEURALNET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % Init of neural network
        
        net
        inputRounds
        hiddenLayerSize
        
        % parameters of PSO
        popSize % has impact on speed (default: 10)
        c1 = 2; % impact of particle best value on velocity (default: 2)
        c2 = 3; % impact of swarm best value on velocity (default: 2)
        velocityFactorChange = 0.995; % (between two iterations) (velocity * weightFactor^it) velocity factor factor :D (default: 0.99)
        velocityFactorMin = 0.4; %(default: 0.4)
        velocityFactor = 1.4; % initial value (default: 1.4)
        vMax = 5; % max velocity (default: 5)
        xMax = 5; % boundaries for weight value
        xMin = -5;
        xDiff
        
        population
        velocity
        particleBest
        particleBestFitness
        swarmBest
        swarmBestFitness
        nrOfVariables
        fitness
    end
    
    methods
        
        function obj = NeuralNet(rounds, layers, particles)
            
            obj = obj@Strategy();
            
            %obj.hiddenLayerSize = layers(1);
            
            if rounds == 'R' % recurrent
                obj.inputRounds = 1;
                obj.net = layrecnet(1, layers); % creates network
                obj.net.inputs{1}.size = 2;
                obj.net.trainParam.showWindow=0; % so that the pop up window doesn't show
                obj.net = train(obj.net,zeros(2,5),1:5); % doesn't have any sense, just to init the network
            else
                obj.inputRounds = rounds;
                obj.net = fitnet(layers); % creates network
                obj.net.inputs{1}.size = rounds*2;
                obj.net.trainParam.showWindow=0; % so that the pop up window doesn't show
                obj.net = train(obj.net,zeros(obj.inputRounds*2,5),1:5); % doesn't have any sense, just to init the network
            end
            
            obj.popSize = particles;
            
            obj.xDiff = obj.xMax - obj.xMin;
            
            obj.nrOfVariables = length(getwb(obj.net));
            
            obj.population = rand(obj.popSize,obj.nrOfVariables)*obj.xDiff + obj.xMin; % each row = one particle = weights for
            obj.velocity = (rand(obj.popSize,obj.nrOfVariables)*obj.xDiff - obj.xDiff/2);
            obj.fitness = zeros(obj.popSize,1);
            
            obj.particleBest = obj.population;
            obj.particleBestFitness = obj.fitness;
            
            obj.swarmBest = [];
            obj.swarmBestFitness = 0;
        end
        
        function out = Action(obj, history)
            
            if size(history, 1) < obj.inputRounds
                out = rand - 0.5; % the first choices are random
            else
                input = history([end - obj.inputRounds + 1 :end],:);
                networkInput = reshape(input,[1,obj.inputRounds*2])';
                out = sim(obj.net, networkInput );
            end
            
            if out < 0 % mapping from network output (R) to prisoner's dilemma
                out = 0;
            else
                out = 1;
            end
            
        end
        
        function averages  = TrainNN(obj, strategiesForNN, rounds )
            % Optimises (searches for best weights) neural network from against strategies using PSO.
            % Returns best weights found
            
            obj.swarmBestFitness = 0;
            
            for it = 1:rounds
                
                % Evaluate all particles, update particle and swarm best.
                for i = 1:obj.popSize
                    
                    setwb(obj.net, obj.population(i,:));
                    obj.fitness(i) = StrategyScore(obj, strategiesForNN, 50);
                    
                    %obj.fitness(i) = EvaluateWeights(obj, obj.population(i,:), strategiesForNN);
                    
                    if obj.fitness(i) > obj.particleBestFitness(i)
                        obj.particleBest(i,:) = obj.population(i,:);
                        obj.particleBestFitness(i) = obj.fitness(i);
                    end
                    
                    if obj.fitness(i) > obj.swarmBestFitness
                        obj.swarmBest = obj.population(i,:);
                        obj.swarmBestFitness = obj.fitness(i);
                        fprintf('New swarm best: %f\n', obj.swarmBestFitness);
                    end
                end
                
                % Update directions for all particles
                for i = 1:obj.popSize
                    
                    % The most important part - how does the velocity changes for each
                    % particle
                    obj.velocity(i,:) = obj.velocityFactor*obj.velocity(i,:) + obj.c1*rand*(obj.particleBest(i,:) - obj.population(i,:)) + obj.c2*rand*(obj.swarmBest - obj.population(i,:));
                    
                    % restriction
                    if (norm(obj.velocity(i,:))) > obj.vMax
                        obj.velocity(i,:) = obj.vMax * obj.velocity(i,:)/norm(obj.velocity(i,:));
                    end
                    
                    obj.population(i,:) = obj.population(i,:) + obj.velocity(i,:);
                    
                    for j = 1:obj.nrOfVariables
                        if obj.population(i,j) > obj.xMax
                            obj.population(i,j) = obj.xMax;
                        end
                        if obj.population(i,j) < obj.xMin
                            obj.population(i,j) = obj.xMin;
                        end
                    end
                    
                end
                
                % Lower the velocity factor
                if obj.velocityFactor > obj.velocityFactorMin
                    obj.velocityFactor = obj.velocityFactor*obj.velocityFactorChange;
                end
                
                fprintf('iteration: %d, avg fitness: %f, velocity factor %f\n ', it, mean(obj.fitness), obj.velocityFactor);
                averages = obj.swarmBestFitness;
            end
            
            obj.net = setwb(obj.net, obj.swarmBest); % set weights produced by particle swarm swarm
            
        end
        
    end  
    
end

