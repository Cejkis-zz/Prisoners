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
        learning_rates = {0.5,0.1,0.01,0.001}; %{2.0, 1.0, 0.5, 0.1, 0.01, 0.0};
        learning_steps = {1000,30000,1000000}; %{100, 200, 500, 2000, 10000};
        nr_of_actions = 0;
        
        % Strategy
        copy = false;
        init_time = 80000;
        init_strategy = InitStrat4mem();
        
        % pre-training options
        pre_trained = false;
        pre_training = false;
        pre_training_time = 30000;
        %strategies = {AlwaysCooperate(), AlwaysDefect(), TitForTat(), ... 
        %              TurnEvil(), Random(), IllCountToThreeButMayForget(), ... 
        %              WhatWillYouDoHT(4,0.25), TwoInARow()};
        strategies = {TitForTat()};
            
        % Opponents
        opponents = [];
        current_opponent = 0;
        
        % My id
        id = 0;
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
        
        function out = get_id(obj)
            out = obj.id;
        end
        
        function set_id(obj, id)
            obj.id = id;
        end
        
        function out = Action(obj, history, id)
            T = size(history, 1);
            % Load opponent
            if obj.current_opponent ~= id
                
                if obj.current_opponent > 0
                    save(strcat(num2str(obj.current_opponent), '.mat'));
                end
                
                if ~any(obj.opponents == id)
                    if obj.pre_training
                        obj.load_net_from_file(0);
                        obj.nr_of_actions = obj.pre_training_time;
                        obj.learning_rate = 1;
                    else
                        obj.reset_state();
                    end
                    obj.opponents = [obj.opponents id];
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

            if T == 0
                out = 1; % initially Cooperate
            elseif obj.init_time > obj.nr_of_actions
                out = obj.init_strategy.Action(history);
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
                history = [1,1];
                for r = 1:obj.pre_training_time
                    me = round(obj.Action(history, obj.id));
                    opponent = strategy{1}.Action([history(:,2),history(:,1)]);
                    history = [history; me opponent];
                end
            end
            obj.update_training_settings();
            save(strcat(num2str(obj.id), '.mat'));
        end
        
        function update_training_settings(obj)
            %obj.nr_of_actions = 0;
            obj.learning_rate = 1;
            obj.learning_steps = {obj.pre_training_time+1000,obj.pre_training_time+30000, obj.pre_training_time+100000}; %{100, 200, 500, 2000, 10000};
            %obj.init_time = 0;
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
        
        function load_net_from_file(obj, id)
            file = load(strcat(num2str(id), '.mat'));
            obj.rnn = file.obj.rnn;
        end
    end 
end

