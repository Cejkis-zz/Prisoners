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

            out = obj.rnn.predict(history);
        end
    end 
end

