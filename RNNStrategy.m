classdef RNNStrategy < Strategy
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % load and save net from/to file
        load_net = false;
        save_net = false;
        
        % net
        rnn;
        % memory capacity
        memory_size = 4;
        % nr. of future steps
        future_steps = 4;
        
        % learning time and actions played
        training = true;
        learning_rate = 1;
        learning_rates = {1.0,0.1,0.01,0.0}; %{2.0, 1.0, 0.5, 0.1, 0.01, 0.0};
        learning_steps = {2000,10000,100000}; %{100, 200, 500, 2000, 10000};
        nr_of_actions = 0;
        
        % Strategy
        copy = false;
        init_time = 5000;
        init_strategy = TitForTat();
        
        % pre-training options
        pre_training = false;
        strategies = {AlwaysCooperate(), AlwaysDefect(), TitForTat(), ... 
                      TurnEvil(), Random(), IllCountToThreeButMayForget(), ... 
                      WhatWillYouDoHT(4,0.25), TwoInARow()};
                  
        % Opponents
        opponents = [];
        current_opponent = 0;
    end
    
    methods
        function obj = RNNStrategy()
            if obj.load_net
                file = load('rnn.mat');
                obj.rnn = file.obj.rnn;
            else
                obj.rnn = RNN();
                if obj.pre_training
                   obj.pre_train();
                   %obj.pre_test();
                end
            end
        end
        
        function out = Action(obj, history, id)
            % Load opponent
            if obj.current_opponent ~= id
                save(strcat(num2str(obj.current_opponent), '.mat'));
                
                if ~any(obj.opponents == id)
                    obj.opponents = [obj.opponents id];
                    obj.reset_state();
                else % Has already played against the opponent
                    obj.load_state(id);
                end
                
                obj.current_opponent = id;
            end
            
            obj.nr_of_actions = obj.nr_of_actions + 1;
            
            % Training
            if obj.training
                obj.train_net(history);
            end

            T = size(history, 1);
            if T == 0
                out = 1; % initially Cooperate
            elseif obj.init_time > obj.nr_of_actions
                p = rand;
                if p > 0.5 %mod(obj.nr_of_actions, obj.noise_ratio) == 0 %T < obj.init_time
                    out = obj.init_strategy.Action(history);
                elseif p > 0.25
                    out = 1;
                else
                    out = 0;
                end
            else
                ts = max(1, T+1-obj.memory_size):T;
                if obj.copy                 
                    out = obj.rnn.predict(history(ts,:));
                else
                    out = obj.policy(history(ts,:));
                end
            end
        end
        
        function train_net(obj, history)
            T = size(history, 1);
            if T > obj.memory_size
                ts1 = (T-obj.memory_size:T-1);
                ts2 = (T-obj.memory_size+1:T);

                if obj.learning_rates{obj.learning_rate} > 0.001
                    obj.rnn = obj.rnn.sgd(history(ts1,:), history(ts2,2), obj.learning_rates{obj.learning_rate});
                    if length(obj.learning_rates) > obj.learning_rate && mod(obj.nr_of_actions, obj.learning_steps{obj.learning_rate}) == 0
                        obj.learning_rate = obj.learning_rate + 1;
                    end
                end
            end
        end
        
        function out = policy(obj, history)
            if obj.predictFuture(history, obj.future_steps, 0) > ...
               obj.predictFuture(history, obj.future_steps, 1)
                    out = 0;
            else
                    out = 1;
            end
        end
        
        function totalValue = predictFuture(obj, history, rounds, choice)
            predictsOut = obj.rnn.predict(history);
            predicted = round(predictsOut);
            
            if rounds == obj.future_steps
                totalValue = obj.payoff(choice, predicted) + ...
                  obj.predictFuture([history; choice predicted], rounds-1, choice);
            elseif (rounds > 0)
                totalValue = max([obj.payoff(0, predicted) + ...
                                   obj.predictFuture([ history; 0 predicted], rounds-1, choice) ...
                                  obj.payoff(1, predicted) + ...
                                   obj.predictFuture([ history; 1 predicted], rounds-1, choice)]);
            else
                totalValue = max([obj.payoff(0, predicted) ...
                                    obj.payoff(1, predicted)]);          
            end
        end
        
        function award = payoff(obj, me, opponent)
            p_matrix = [[1, 5];[0, 3]];
            award = p_matrix(me+1, opponent+1);
        end
                
        function pre_train(obj)
            for strategy = obj.strategies
                obj.reset_training_settings();
                rounds = 200;
                history = [];
                for r = 1:rounds
                    me = round(obj.Action(history));
                    opponent = strategy{1}.Action(history);
                    history = [history; me opponent];
                end
            end
        end
        
        function reset_training_settings(obj)
            obj.learning_rounds = 2000;
            obj.learning_rate = 2.0;
            obj.half_time = 50;
            obj.nr_of_actions = 0;
        end
        
        function stop_training(obj)
            obj.training = false;
        end
        
        function start_training(obj)
            obj.training = true;
        end
        
        function reset_state(obj)
            obj.nr_of_actions = 0;
            obj.learning_rate = 1;
        end
        
        function load_state(obj, id)
            file = load(strcat(num2str(id), '.mat'));
            obj.rnn = file.obj.rnn;
            obj.learning_rate = file.obj.learning_rate;
            obj.nr_of_actions = file.obj.nr_of_actions;
        end
    end 
end

