classdef LSTM_wrapper <  Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Size of network
        n_hidden = 8; 
        n_in = 2;
        n_y = 1;
        
        % learning rate
        n = 0.01;
        
        % Initialize Weights
        mu = 0.05;
        sigma = 0.05;
        
        % Load/Store Weights
        load = false;
        
        % Weights
        lstm_net; % LSTM
        W_y;  % Output layer
        
        % Initial strategy
        initial_strategy = TwoInARow();
        
        % Memory size
        memory = 4;
    end
    
    methods
        % Constructor
        function obj = LSTM_wrapper()
            obj.W_y = normrnd(obj.mu, obj.sigma, [obj.n_y, obj.n_hidden]);
            obj.lstm_net = LSTM_class(obj.mu, obj.sigma, obj.n, obj.n_in, obj.n_hidden);
            
            if obj.load 
                obj.lstm_net = load_net(obj.lstm_net, 'lstm.mat');
                wrapper = load('wrapper.mat');
                obj.W_y = wrapper.obj.W_y;
            end
        end
        
        function out = Action(obj, history)
            T = size(history, 1);
            if T < 1 + obj.memory
                out = obj.initial_strategy.Action(history);
            else
                ts1 = T-obj.memory:T-1;
                ts2 = T-obj.memory+1:T;
                xs = history(ts1, :);
                target = history(ts2, 2);

                for t = 1:2
                    obj.train_network([xs], target);
                end
                [prediction, output] = obj.predict_next(xs);
                
                ready = T > 0 + obj.memory;
                if ready
                    out = output;
                else
                    out = obj.initial_strategy.Action(history);
                end
            end
        end
        
        function out = Test(obj, history)
            T = size(history, 1);
            ts = T-obj.memory:T-1;
            xs = history(ts, :);
            [prediction, output] = obj.predict_next(xs);
            out = output;
        end
        
        function [prediction, output] = predict_next(obj, xs)
            T = size(xs, 1);
            f_pass = obj.lstm_net.lstm_forward_pass(xs);
            y_t = f_pass(:, 10, T);
            output = obj.output_activation(y_t);
            prediction = round(output);
        end
        
        function train_network(obj, xs, target)

            % Forward
            T = size(xs, 1);
            f_pass = obj.lstm_net.lstm_forward_pass(xs);
            ys = f_pass(:, 10, :);
            ys = reshape(ys,[obj.n_hidden T]);
            output = obj.output_activation(ys)'; % linear + sigmoid activation

            % Loss function
            Loss = (target - output);
            
            % Output layer
            d_out = obj.d_output_activation(output);
            d_out = - Loss.*d_out;
            dE_y_t = d_out*obj.W_y;
            dW_y = d_out(T,1)*ys(:,T)';
            obj.W_y = obj.W_y - obj.n * dW_y;

            % Backward
            mask = 1; %T; %obj.memory / 2;
            mask = [zeros(T-mask, obj.n_hidden);ones(mask, obj.n_hidden)];
            dE_y_t = dE_y_t .* mask;
            obj.lstm_net = obj.lstm_net.bptt(dE_y_t', xs, f_pass);
            
            % Save lstm and output layer
            obj.lstm_net.save_net('lstm.mat');
            save('wrapper.mat');
        end
        
        function y = output_activation(obj, x)
            % linear + sigmoid
            y = obj.sigmoid(obj.W_y*x);
        end

        function dy = d_output_activation(obj, y)
            dy = obj.sigmoid(y).*(1-obj.sigmoid(y));
        end
        
        function res = sigmoid(obj, x)
          res = 1 ./ (1 + exp(-x));
        end
    end
    
end

