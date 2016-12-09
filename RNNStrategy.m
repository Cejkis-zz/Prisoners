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
        always_train = true;
        learning_rounds = 10000;
        learning_rate = 1;
        learning_rates = {1.0,0.1,0.01};
        learning_steps = {1000, 2000};
        nr_of_actions = 0;
        
        % Strategy
        copy = false;
        noise_ratio = 4;
        noise = Random();
        
        % pre-training options
        pre_training = false;
        strategies = {AlwaysCooperate(), AlwaysDefect(), TitForTat(), ... 
                      TurnEvil(), Random(), IllCountToThreeButMayForget(), ... 
                      WhatWillYouDoHT(15,0.25), TwoInARow()};
                  
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
                obj.reset_state();
                save(num2str(obj.current_opponent) + '.mat');
                file = load(num2str(id) + '.mat');
                obj.rnn = file.obj.rnn;
                obj.current_opponent = id;
                if ~any(obj.opponents == id)
                    obj.opponents = [obj.opponents id];
                end
            end
            
            obj.nr_of_actions = obj.nr_of_actions + 1;
            T = size(history, 1);
            if T > obj.memory_size
                ts1 = (T-obj.memory_size:T-1);
                ts2 = (T-obj.memory_size+1:T);
            else
                ts1 = 1:T; ts2 = 1:T;
            end
            
            % Training
            if T > obj.memory_size
                if obj.training
                    if T == obj.learning_rounds 
                        if obj.save_net
                            save('rnn.mat');
                        end
                    elseif T < obj.learning_rounds || obj.always_train
                        obj.rnn = obj.rnn.sgd_step(history(ts1,:), history(ts2,2), obj.learning_rates{obj.learning_rate});
                        if length(obj.learning_rates) > obj.learning_rate && mod(obj.nr_of_actions, obj.learning_rates{obj.learning_rate}) == 0
                            obj.learning_rate = obj.learning_rate + 1;
                        end
                    end
                end
            end

            if T == 0
                out = 1; % initially Cooperate
            elseif (obj.learning_rounds > obj.nr_of_actions && mod(obj.nr_of_actions, obj.noise_ratio) == 0) %T < obj.init_time
                out = obj.noise.Action(history(ts2,:));
            else
                if obj.copy
                    out = obj.rnn.predict(history(ts2,:));
                else
                    out = obj.policy(history(ts2,:));
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
            obj.learning_rounds = 10000;
            obj.learning_rate = 1;
            obj.nr_of_actions = 0;
        end
    end 
end

