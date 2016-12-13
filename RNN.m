classdef RNN
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %learning_rate = 0.1; % Default
        n_in = 2;
        n_hidden = 4;
        n_y = 1;
        mean = 0;
        var = 1;
        Wx;
        Wh;
        Wy;
        %by;
        
        bptt_truncate = 4;
    end
    
    methods
        function obj = RNN()
            obj.Wx = normrnd(obj.mean, obj.var, [obj.n_hidden, obj.n_in]);
            obj.Wh = normrnd(obj.mean, obj.var, [obj.n_hidden, obj.n_hidden]);
            obj.Wy = normrnd(obj.mean, obj.var, [obj.n_y, obj.n_hidden]);
            %obj.by = normrnd(0.0, 0.0, [obj.n_y, 1]); % Biased towards 1
        end
        
        function [o, h] = forward_propagation(obj, x)
            T = size(x,1);
            % Hidden states
            h = zeros(T + 1, obj.n_hidden);
            h(1, :) = zeros(1, obj.n_hidden);
            % Outputs
            o = zeros(T, obj.n_y);
            for t = 1:T % For each time step
                h(t+1,:) = tanh( obj.Wx * x(t,:)' + obj.Wh * h(t,:)' )';
                o(t,:) = obj.sigmoid(obj.Wy * h(t+1,:)');
            end
        end
        
        function p = predict(obj, x)
            [o, h] = obj.forward_propagation(x);
            p = o(end,:);
        end
        
        function [dEdWx, dEdWh, dEdWy] = bptt(obj, x, y)
            T = size(y, 1);
            [o, h] = obj.forward_propagation(x);
            dEdWx = zeros(size(obj.Wx));
            dEdWh = zeros(size(obj.Wh));
            dEdWy = zeros(size(obj.Wy));
            
            dEdo = - (y - o);
            dEdWyh =  dEdo .* o.*(1-o);
            % For each output backwards.
            for t = T:-1:1
                dEdWy = dEdWy + dEdWyh(t,:) .* h(t+1,:); % outer product
                delta_t = (obj.Wy' * dEdWyh(t,:)) .* (1 - (h(t+1,:)' .^ 2));
                % BackPropagation Through Time 
                bptt_steps = t:-1:max(1, t-obj.bptt_truncate); 
                for bptt_step = bptt_steps % for at most obj.bptt_truncate steps 
                    dEdWh = dEdWh + delta_t * h(bptt_step+1,:); % outer product            
                    dEdWx = dEdWx + delta_t * x(bptt_step,:);   % outer product
                    delta_t = obj.Wh' * delta_t .* (1 - h(bptt_step+1,:)' .^ 2);
                end
            end
        end
                 
        function obj = sgd(obj, x, y, n)
            [dEdWx, dEdWh, dEdWy] = obj.bptt(x, y);
            
            obj.Wx = obj.Wx - n * dEdWx;
            obj.Wh = obj.Wh - n * dEdWh;
            obj.Wy = obj.Wy - n * dEdWy;
        end
        
        function res = sigmoid(obj, x)
            res = 1 ./ (1 + exp(-x));
        end
        
        function res = d_sigmoid(obj, x)
            res = obj.sigmoid(x).*(1-obj.sigmoid(x));
        end

    end
end

