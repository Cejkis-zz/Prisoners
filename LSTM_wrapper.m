classdef LSTM_wrapper <  Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Size of network
        n_hidden = 4; 
        n_in = 2; 
        n_y = 1;
        
        % learning rate
        n = 0.5;
        
        % Initialize Weights
        mu = 0.05;
        sigma = 0.01;
        
        % Load/Store Weights
        load = false;
        file_name_S = 'S.mat';
        file_name_O = 'W_y.mat';
        
        % Weights
        S = LSTM.init_weights(mu, sigma, n_hidden, n_in);
        W_y = normrnd(mu,sigma,[n_y, n_hidden]);
    end
    
    methods
        
    end
    
end

