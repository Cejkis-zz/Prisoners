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
    end
    
    methods
        function obj = RNNStrategy()
            if obj.load_net
                file = load('rnn.mat');
                obj.rnn = file.obj.rnn;
            else
                obj.rnn = RNN();
            end
        end
        
        function out = Action(obj, history)
            T = size(history, 1);
            if T > obj.memory_size
                ts1 = (T-obj.memory_size:T-1);
                ts2 = (T-obj.memory_size+1:T);
            else
                ts1 = 1:T; ts2 = 1:T;
            end
            obj.rnn = obj.rnn.sgd_step(history(ts1,:), history(ts2,2));
            save('rnn.mat');

            %out = obj.rnn.predictFuture(history);
            if obj.predictFuture( history(ts2,:), obj.future_steps, 0) > ...
               obj.predictFuture( history(ts2,:), obj.future_steps, 1)
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
    end 
end

