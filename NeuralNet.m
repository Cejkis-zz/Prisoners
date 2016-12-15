classdef NeuralNet < Strategy & handle
    %NEURALNET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        actionsSinceLastLearning = 0;
        strategies
        actionRounds % how many rounds will evaluation do
        learningRounds = 10; % how many times will swarm update
        trainingRounds = 70; % action rounds during training
        training = 0; % during training set to 1, so training doesnt happen recursively
        % Init of neural network
        net
        inputRounds % NN input size - how far in past will NN look
        hiddenLayerSize
        
        % parameters of PSO
        popSize % has impact on speed (default: 10)
        c1 = 2; % impact of particle best value on velocity (default: 2)
        c2 = 2; % impact of swarm best value on velocity (default: 2)
        velocityFactorChange = 0.995; % (between two iterations) (velocity * weightFactor^it) velocity factor factor :D (default: 0.99)
        velocityFactorMin = 0.4; %(default: 0.4)
        velocityFactor = 1.4; % initial value (default: 1.4)
        vMax = 4; % max velocity (default: 5)
        xMax = 4; % boundaries for weight value
        xMin = -4;
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
        
        function obj = NeuralNet(inputRounds, layers, nrOfParticles, actionRounds)
            
            obj = obj@Strategy();
            
            obj.inputRounds = inputRounds;
            obj.net = fitnet(layers); % creates network
            obj.net.inputs{1}.size = inputRounds*2;
            obj.net.trainParam.showWindow=0; % so that the pop up window doesn't show
            obj.net = train(obj.net,zeros(obj.inputRounds*2,5),1:5); % doesn't have any sense, just to init the network
            
            obj.actionRounds = actionRounds;
            
            if nargin < 4
                obj.popSize = 3;
            else
                obj.popSize = nrOfParticles;
            end
            
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
        
        function out = Action(obj, history, enemy)
            global Strategies;
            
            if size(history, 1) < obj.inputRounds
                out = rand - 0.5; % the first choices are random
            else
                input = history(end - obj.inputRounds + 1 :end,:);
                networkInput = reshape(input,[1,obj.inputRounds*2])';
                out = sim(obj.net, networkInput );
            end
            
            if out < 0 % mapping from network output (R) to prisoner's dilemma
                out = 0;
            else
                out = 1;
            end
            
            %% if I am not in training and if my oponent is NN and is not in training,
            % update the action counter and do training.
            if obj.training == 0
                
                if isa(enemy,'NeuralNet')
                    if enemy.training == 1
                        return;
                    end
                end
                
                obj.actionsSinceLastLearning = obj.actionsSinceLastLearning + 1;
                
                % if was action performed against all strategies, train NN
                if obj.actionsSinceLastLearning >= obj.actionRounds * length(Strategies)
                    %                 fprintf('Training NN %d\n', obj.actionsSinceLastLearning)
                    obj.actionsSinceLastLearning  = 0;
                    obj.TrainNN();
                end
                
            end
            
        end
        
        function averages = TrainNN(obj)
            % Optimises (searches for best weights) neural network from against strategies using PSO.
            % Returns best weights found
            
            obj. training = 1;
%             obj.swarmBestFitness = 0;
%             fprintf('NN training\n');
            
            for it = 1:obj.learningRounds
                
                % Evaluate all particles, update particle and swarm best.
                for i = 1:obj.popSize
                    
                    setwb(obj.net, obj.population(i,:));
                    obj.fitness(i) = obj.EvaluateNN();
                    
                    if obj.fitness(i) > obj.particleBestFitness(i)
                        obj.particleBest(i,:) = obj.population(i,:);
                        obj.particleBestFitness(i) = obj.fitness(i);
                    end
                    
                    if obj.fitness(i) > obj.swarmBestFitness
                        obj.swarmBest = obj.population(i,:);
                        obj.swarmBestFitness = obj.fitness(i);
                        %                         fprintf('New swarm best: %f\n', obj.swarmBestFitness);
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
                
                %                 fprintf('iteration: %d, avg fitness: %f, velocity factor %f\n ', it, mean(obj.fitness), obj.velocityFactor);
                averages = obj.swarmBestFitness;
            end
            
            obj.net = setwb(obj.net, obj.swarmBest); % set weights produced by particle swarm swarm
            obj. training = 0;
        end
        
        function [ results ] = EvaluateNN( obj)
            %% evaluate strategy against other strategies (enemies) for ^ rounds.
            % Todo: add mistake possibility
            global Strategies;
            
            rounds = obj.trainingRounds;
            mistake = 0.02;
            
            nrOfEnemies = length(Strategies);
            score = 0;
            
            for j = 1:nrOfEnemies
                
                history = zeros(rounds,2);
                
                for r = 1: rounds
                    
                    p1 = obj.Action(history, Strategies{j}); % get the move of each prisoner
                    
                    if r > 1
                        p2 = Strategies{j}.Action([history(1:r-1,2),history(1:r-1,1)], obj); % history columns need to be swapped
                    else
                        p2 = Strategies{j}.Action([], obj); % history is empty in first round
                    end
                    
                    if rand < mistake
                        p1 = 1 - p1 ;
                    end
                    
                    if rand < mistake
                        p2 = 1 - p2 ;
                    end
                    
                    history(r,:) = [p1 p2]; % update history matrix
                    utilities = PrisonersRound(p1, p2); % compute utilities for both prisoners
                    score = score + utilities(1);
                end
                
            end
            
            results = (score/nrOfEnemies)/rounds;
            
        end
        
    end
    
end

