classdef LSTM_wrapper <  Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Size of network
        n_hidden = 2; 
        n_in = 2; 
        n_y = 1;
        
        % learning rate
        n = 0.1;
        
        % Initialize Weights
        mu = 0.0;
        sigma = 0.01;
        
        % Load/Store Weights
        load = false;
        
        % Weights
        lstm_net; % LSTM
        W_y;  % Output layer
        
        % Initial strategy
        initial_strategy = TwoInARow();
        
        % Memory size
        memory = 20;
    end
    
    methods
        % Constructor
        function obj = LSTM_wrapper()
            obj.W_y = normrnd(obj.mu, obj.sigma, [obj.n_y, obj.n_hidden]);
            obj.lstm_net = LSTM_class(obj.mu, obj.sigma, obj.n, obj.n_hidden, obj.n_in);
            
            if obj.load 
                obj.lstm_net.load_net('lstm.mat');
                wrapper = load('wrapper.mat');
                obj.W_y = wrapper.obj.W_y;
            end
        end
        
        function out = Action(obj, history)
            dim = size(history);
            T = dim(1);
            if T < 1 + obj.memory
                out = obj.initial_strategy.Action(history);
            else
                ts = T-obj.memory:T-1;
                xs = history(ts, :);
                target = history(T, :);

                obj.train_network(xs, target);
                [prediction, output] = obj.predict_next(xs);
                
                ready = T > 20 + obj.memory;
                if ready
                    out = output;
                else
                    out = obj.initial_strategy.Action(history);
                end
            end
        end
         
        function [prediction, output] = predict_next(obj, xs)
            f_pass = obj.lstm_net.lstm_forward_pass(xs);
            y_t = f_pass(:, 10, 1);
            output = obj.output_activation(y_t);
            prediction = round(output);
        end
        
        function train_network(obj, xs, target)

            % Forward
            dim = size(xs);
            T = dim(1);
            f_pass = obj.lstm_net.lstm_forward_pass(xs);
            y_t = f_pass(:, 10, T);
            output = obj.output_activation(y_t); % linear + sigmoid activation

            % Loss function
            Loss = (target(2) - output);

            % Output layer
            d_out = - Loss*obj.d_output_activation(output);
            dW_y = d_out*y_t';
            obj.W_y = obj.W_y - obj.n * dW_y;

            % Backward
            obj.lstm_net.bptt(d_out, xs, f_pass);
            
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

