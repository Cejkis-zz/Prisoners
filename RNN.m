classdef RNN
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        learning_rate = 0.01;
        n_in = 2;
        n_hidden = 4;
        n_y = 1;
        mean = 0.0;
        var = 0.1;
        Wx;
        Wh;
        Wy;
        
        bptt_truncate = 2;
    end
    
    methods
        function obj = RNN()
            obj.Wx = normrnd(obj.mean, obj.var, [obj.n_hidden, obj.n_in]);
            obj.Wh = normrnd(obj.mean, obj.var, [obj.n_hidden, obj.n_hidden]);
            obj.Wy = normrnd(obj.mean, obj.var, [obj.n_y, obj.n_hidden]);
        end
        
        function [o, s] = forward_propagation(obj, x)
            % The total number of time steps
            T = size(x,1);
            % During forward propagation we save all hidden states in s because need them later.
            % We add one additional element for the initial hidden, which we set to 0
            s = zeros(T + 1, obj.n_hidden);
            % The outputs at each time step. Again, we save them for later.
            o = zeros(T, obj.n_y);
            % For each time step...
            for t = 1:T
                % Note that we are indxing U by x[t]. This is the same as multiplying U with a one-hot vector.
                s(t+1,:) = tanh( obj.Wx * x(t,:)' + obj.Wh * s(t,:)' );
                o(t,:) = obj.sigmoid(obj.Wy * s(t+1,:)');
            end
        end
        
        function p =  predict(obj, x)
            % Perform forward propagation and return index of the highest score
            [o, s] = obj.forward_propagation(x);
            p = o(end,:);
        end
        
        function [dEdWx, dEdWh, dEdWy] = bptt(obj, x, y)
            T = size(y, 1);
            % Perform forward propagation
            [o, s] = obj.forward_propagation(x);
            % We accumulate the gradients in these variables
            dEdWx = zeros(size(obj.Wx));
            dEdWh = zeros(size(obj.Wh));
            dEdWy = zeros(size(obj.Wy));
            loss = - (y - o);
            d_s = obj.d_sigmoid(o);
            % For each output backwards...
            for t = T:-1:1
                dEdWy = dEdWy + loss(t,:)' * d_s(t) * s(t+1,:); % outer product
                % Initial delta calculation
                delta_t = (obj.Wy' * loss(t,:)) .* (1 - (s(t+1,:)' .^ 2));
                % Backpropagation through time (for at most obj.bptt_truncate steps)
                bptt_steps = t:-1:max(1, t-obj.bptt_truncate);
                for bptt_step = bptt_steps
                    dEdWh = dEdWh + delta_t * s(bptt_step+1,:);     % outer            
                    dEdWx = dEdWx + delta_t * x(bptt_step,:);   % outer
                    % Update delta for next step
                    delta_t = obj.Wh' * delta_t .* (1 - s(bptt_step+1,:)' .^ 2);
                end
            end
        end
        
        function obj = sgd_step(obj, x, y)
            % Calculate the gradients
            [dEdWx, dEdWh, dEdWy] = obj.bptt(x, y);
            % Change parameters according to gradients and learning rate
            obj.Wx = obj.Wx - obj.learning_rate * dEdWx;
            obj.Wh = obj.Wh - obj.learning_rate * dEdWh;
            obj.Wy = obj.Wy - obj.learning_rate * dEdWy;
        end
        
        function res = d_sigmoid(obj, x)
            res = obj.sigmoid(x).*(1-obj.sigmoid(x));
        end
        
        function res = sigmoid(obj, x)
            res = 1 ./ (1 + exp(-x));
        end
    end
end

