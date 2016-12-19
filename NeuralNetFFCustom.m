classdef NeuralNetFFCustom < NeuralNet
    %NEURALNETFFCUSTOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        actionsSinceLastLearning = 0;
        
        actionRounds % how many rounds will evaluation do
        learningRounds = 5; % how many times will swarm update
       
        training = 0; % during training set to 1, so training doesnt happen recursively
        
        % neural network
        
        inputRounds % NN input size - how far in past will NN look
        hiddenSize
        id
        
        % parameters of PSO
        popSize % has impact on speed (default: 10)
        c1 = 2; % impact of particle best value on velocity (default: 2)
        c2 = 2; % impact of swarm best value on velocity (default: 2)
        velocityFactorChange = 0.999; % (between two iterations) (velocity * weightFactor^it) velocity factor factor :D (default: 0.99)
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
        
        currentWeights
        weightmatrix1
        weightmatrix2
    end
    
    methods
        
        function obj = NeuralNetFFCustom(layers, nrOfParticles, actionRounds)
            
            obj = obj@NeuralNet();
            obj.set_id(rand);
            
            obj.inputRounds = layers(1);
            obj.hiddenSize = layers(2:end);
            obj.actionRounds = actionRounds;
            
            obj.popSize = nrOfParticles;
            
            obj.xDiff = obj.xMax - obj.xMin;
            
            if(length(layers) == 2)
                 obj.nrOfVariables = layers(1)*2*layers(2) + layers(2) + layers(2)  + 1;  
            else
                obj.nrOfVariables = layers(1)*2*layers(2) + layers(2) + layers(2)*layers(3) + layers(3) + layers(3) + 1;  
            end
            
            obj.population = rand(obj.popSize,obj.nrOfVariables)*obj.xDiff + obj.xMin; % each row = one particle = weights for
            obj.velocity = (rand(obj.popSize,obj.nrOfVariables)*obj.xDiff - obj.xDiff/2);
            obj.fitness = zeros(obj.popSize,1);
            
            obj.particleBest = obj.population;
            obj.particleBestFitness = obj.fitness;
            
            obj.swarmBest = zeros(1,obj.nrOfVariables);
            obj.swarmBestFitness = -Inf;
            
            obj.SetWeights(zeros(1,obj.nrOfVariables));
            
        end
        
        function SetWeights(obj, weights)
            obj.currentWeights = weights;
            
            weights1Size = obj.inputRounds * 2 * obj.hiddenSize;
            obj.weightmatrix1 = reshape(obj.currentWeights(1:weights1Size),[obj.inputRounds*2, obj.hiddenSize(1)]);
            
            if length(obj.hiddenSize) == 2
               
            weights2Size = obj.hiddenSize(1)* obj.hiddenSize(2);
            obj.weightmatrix2 = reshape(obj.currentWeights(weights1Size + 1:weights1Size + weights2Size),[obj.hiddenSize(1), obj.hiddenSize(2)]);
                          
            end
            
        end
        
        function out = Action(obj, history, enemy)
            
            if enemy == obj.get_id()
                out = 1;
                return;
            end
            
%             global Strategies;
%             obj.SetWeights(obj.swarmBest);
            
            if size(history, 1) < obj.inputRounds
                out = rand - 0.5; % the first choices are random
            else
                input = history(end - obj.inputRounds + 1 :end,:);
                networkInput = reshape(input,[1, obj.inputRounds*2]);
                
                weights1Size = numel(obj.weightmatrix1);
                
                if length(obj.hiddenSize) == 1 %% 1 hidden
                    out = tanh(networkInput * obj.weightmatrix1 + obj.currentWeights(weights1Size + 1: weights1Size + obj.hiddenSize ));
                    out = tanh(out' * obj.currentWeights(end - obj.hiddenSize: end-1) + obj.currentWeights(end));
                else %% 2 hidden
                    weights2Size = numel(obj.weightmatrix2);
                    offset = weights1Size + weights2Size;
                    out = tanh(networkInput * obj.weightmatrix1 + obj.currentWeights(offset + 1: offset + obj.hiddenSize(1)));
                    offset = offset + obj.hiddenSize(1);
                    out = tanh(out * obj.weightmatrix2 + obj.currentWeights(offset + 1: offset + obj.hiddenSize(2)));
                    offset = offset + obj.hiddenSize(2);
                    out = tanh(out' * obj.currentWeights(offset + 1: end-1) + obj.currentWeights(end));
                end
                
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
                if obj.actionsSinceLastLearning >= 1000
                    %                 fprintf('Training NN %d\n', obj.actionsSinceLastLearning)
                    obj.actionsSinceLastLearning  = 0;
                    obj.training = 1;
                    obj.TrainNN();
                    obj.training = 0;
                end
                
            end
            
        end
        
    end
    
end

