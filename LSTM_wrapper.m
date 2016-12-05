classdef LSTM_wrapper <  Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Size of network
        n_hidden = 2; 
        n_in = 2; 
        n_y = 1;
        
        % learning rate
        n = 0.5;
        
        % Initialize Weights
        mu = 0.05;
        sigma = 0.01;
        
        % Load/Store Weights
        load = true;
        
        % Weights
        lstm_net; % = LSTM.init_weights(obj.mu, obj.sigma, n_hidden, n_in);
        W_y; % = normrnd(mu,sigma,[n_y, n_hidden]);
    end
    
    methods
        % Constructor
        function obj = LSTM_wrapper()
            obj.W_y = normrnd(obj.mu, obj.sigma, [obj.n_y, obj.n_hidden]);
            save('wrapper.mat');
            obj.lstm_net = LSTM_class(obj.mu, obj.sigma, obj.n, obj.n_hidden, obj.n_in);
            obj.lstm_net.save_net('lstm.mat');
            
            if obj.load 
                obj.lstm_net.load_net('lstm.mat');
                wrapper = load('wrapper.mat');
                obj.W_y = wrapper.obj.W_y;
            end
            
            T = 6;
            xs = [[1,1];
                  [0,0];
                  [1,1];
                  [0,0];
                  [1,1];
                  [0,0]];
            target = [1, 1];

            c_0 = zeros(obj.n_hidden, 1);
            y_0 = zeros(obj.n_hidden, 1);
            x_0 = zeros(1, 2);
            obj.predict_next(y_0, c_0, [x_0]);
            obj.train_network(y_0, c_0, xs, target);
        end
        
        function out = Action(obj, history)
            
        end
         
        function [prediction, y_t, c_t] = predict_next(obj, y_tm1, c_tm1, xs)
            f_pass = obj.lstm_net.lstm_forward_pass(xs, y_tm1, c_tm1);
            c_t = f_pass(:, 7, 1);
            y_t = f_pass(:, 10, 1);
            prediction = obj.output_activation(y_t);
        end
        
        function train_network(obj, y_tm1, c_tm1, xs, target)

            % Forward
            dim = size(xs);
            T = dim(1);
            f_pass = obj.lstm_net.lstm_forward_pass(xs, y_tm1, c_tm1);
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

