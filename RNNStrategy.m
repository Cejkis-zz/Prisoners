classdef RNNStrategy < Strategy
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % load net from file
        load_net = false;
        % net
        rnn;
        % memory capacity
        memory_size = 4;
        % nr. of future steps
        future_steps = 4;
        
        % learning time and actions played
        learning_rounds = 2000;
        learning_rate = 2.0;
        half_time = 50;
        nr_of_actions = 0;
        noise_ratio = 0;
        noise = Random();
        
        % pre-training options
        pre_training = false;
        strategies = {AlwaysCooperate(), AlwaysDefect(), TitForTat(), ... 
                      TurnEvil(), Random(), IllCountToThreeButMayForget(), ... 
                      WhatWillYouDoHT(15,0.25), TwoInARow()};
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
                end
            end
        end
        
        function out = Action(obj, history)
            obj.nr_of_actions = obj.nr_of_actions + 1;
            T = size(history, 1);
            if T > obj.memory_size
                ts1 = (T-obj.memory_size:T-1);
                ts2 = (T-obj.memory_size+1:T);
            else
                ts1 = 1:T; ts2 = 1:T;
            end
            
            if T > obj.memory_size
                if T == obj.learning_rounds
                    save('rnn.mat');
                elseif T < obj.learning_rounds
                    obj.rnn = obj.rnn.sgd_step(history(ts1,:), history(ts2,2), obj.learning_rate);
                    if mod(obj.nr_of_actions, obj.half_time) == 0
                        obj.learning_rate = obj.learning_rate ./ 2;
                    end
                end
            end

            %out = obj.rnn.predict(history(ts2,:));
            if T == 0
                out = 1; % initially Cooperate
            elseif (obj.learning_rounds > obj.nr_of_actions && mod(obj.nr_of_actions, obj.noise_ratio) == 0) %T < obj.init_time
                out = obj.noise.Action(history(ts2,:));
            else
                if true
                    out = obj.rnn.predict(history(ts2,:));
                else
                    out = obj.policy(history(ts2,:)); %obj.rnn.predict(history(ts2,:)); %
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
        
        function pre_train()
            
        end
    end 
end

