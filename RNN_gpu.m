classdef RNN
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        learning_rate = 0.01;
        n_in = 2;
        n_hidden = 4;
        n_y = 1;
        mean = 0.1;
        var = 0.01;
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
            % The total number of time steps
            T = size(x,1);
            % Save all hidden states in s.
            % We add one additional element for the initial hidden, which we set to 0
            h = zeros(T + 1, obj.n_hidden);
            h(1, :) = zeros(1, obj.n_hidden);
            hg = gpuArray(h);
            % The outputs at each time step.
            o = zeros(T, obj.n_y);
            og = gpuArray(o);
            % For each time step.
            for t = 1:T
                hg(t+1,:) = atanh( obj.Wx * x(t,:)' + obj.Wh * hg(t,:)' )';
                og(t,:) = obj.sigmoid(obj.Wy * hg(t+1,:)');
            end
            h = gather(hg);
            o = gather(og);
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
            dEdWyh =  dEdo .* o.*(1-o); %obj.d_sigmoid(h(end,:));
            % For each output backwards.
            for t = T:-1:1
                dEdWy = dEdWy + dEdWyh(t,:) .* h(t+1,:); % outer product
                % Initial delta calculation
                delta_t = (obj.Wy' * dEdWyh(t,:)) .* (1 - (h(t+1,:)' .^ 2));
                % Backpropagation through time (for at most obj.bptt_truncate steps)
                bptt_steps = t:-1:max(1, t-obj.bptt_truncate);
                for bptt_step = bptt_steps
                    dEdWh = dEdWh + delta_t * h(bptt_step+1,:); % outer product            
                    dEdWx = dEdWx + delta_t * x(bptt_step,:);   % outer product
                    % Update delta for next step
                    delta_t = obj.Wh' * delta_t .* (1 - h(bptt_step+1,:)' .^ 2);
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

