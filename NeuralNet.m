classdef (Abstract) NeuralNet < Strategy & handle
    %NEURALNET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
                
        function averages = TrainNN(obj)
            % Optimises (searches for best weights) neural network from against strategies using PSO.
            % Returns best weights found
           
            for it = 1:obj.learningRounds
                
                % Evaluate all particles, update particle and swarm best.
                for i = 1:obj.popSize
                    
                    obj.SetWeights(obj.population(i,:));
                    obj.fitness(i) = obj.EvaluateNN();
                    
%                     fprintf('%d\n', obj.fitness(i));
%                     c = clock;
%                     disp(datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))));
                    
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
                    obj.velocity(i,:) = obj.velocityFactor * obj.velocity(i,:) + obj.c1*rand*(obj.particleBest(i,:) - obj.population(i,:)) + obj.c2*rand*(obj.swarmBest - obj.population(i,:));
                    
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
            
            obj.SetWeights(obj.swarmBest);
           
        end
        
        function [ results ] = EvaluateNN( obj)
            %% evaluate strategy against other strategies (enemies) for ^ rounds.
            % Todo: add mistake possibility
            
            global Strategies;
            
            rounds = obj.actionRounds;
            mistake = 0.0;
            
            nrOfEnemies = length(Strategies);
            score = 0;
            
            for j = 1:nrOfEnemies
                
                if Strategies{j} == obj
                    continue;
                end
                
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
            
            results = ((score + 3*rounds)/nrOfEnemies)/rounds; % 3*rounds is score with itself
            
        end
        
        function out = get_id(obj)
            out = obj.id;
        end
        
        function set_id(obj, id)
            obj.id = id;
        end
        
    end
    
end

