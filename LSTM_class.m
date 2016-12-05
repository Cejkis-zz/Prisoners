classdef LSTM_class
    properties
        n;
        n_in;
        n_hidden;
        S;
    end
    methods
        function obj = LSTM_class(mean, var, n, n_in, n_hidden)
            obj.n = n;
            obj.n_in = n_in;
            obj.n_hidden = n_hidden;
            obj.S = obj.init_weights(mean, var);
        end
        
        % Back Propagation Thrpugh Time
        function bptt(obj, d_out, xs, f_pass)
            dim = size(xs);
            T = dim(1);
            b_pass = obj.lstm_backward_pass(d_out, T, f_pass);
            dS = obj.gradients(T, xs, f_pass, b_pass);
            obj.update_weights(dS);
        end
        
        function b_pass = lstm_backward_pass(obj, d_out, T, f_pass)
            b_pass = zeros(obj.n_hidden, 6, T);
            dz_t = zeros(obj.n_hidden, 1); di_t = zeros(obj.n_hidden, 1); 
            df_t = zeros(obj.n_hidden, 1); dc_t = zeros(obj.n_hidden, 1); 
            do_t = zeros(obj.n_hidden, 1); dy_t = zeros(obj.n_hidden, 1);
            D = [dz_t, di_t, df_t, dc_t, do_t, dy_t];

            f_tp1 = zeros(obj.n_hidden, 1);
            for t = T:-1:1
                F = f_pass(:,:,t);

                if t < T
                    f_tp1 = f_pass(:,6,t+1);
                    d_out = zeros(obj.n_hidden, 1);
                end

                if t > 1 
                    c_tm1 = f_pass(:,7,t-1);
                else
                    c_tm1 = zeros(obj.n_hidden, 1);
                end

                D = obj.lstm_backward_step(d_out, f_tp1, c_tm1, F, D);
                b_pass(:,:,t) = D; 
            end
        end

        function D = lstm_backward_step(obj, d_t, f_tp1, c_tm1, F, D)
            % Unpack
            [z_t_, z_t, i_t_, i_t, f_t_, f_t, c_t, o_t_, o_t, y_t] = obj.unpackF(F);
            [dz_tp1, di_tp1, df_tp1, dc_tp1, do_tp1, dy_tp1] = obj.unpackD(D);

            dy_t = d_t + obj.S.R.R_z * dz_tp1 + obj.S.R.R_i * di_tp1 + ... 
                         obj.S.R.R_f * df_tp1 + obj.S.R.R_o * do_tp1; 
            do_t = dy_t .* obj.h(c_t) .* obj.d_sigmoid(o_t_);
            dc_t = dy_t .* o_t .* obj.h_(c_t) + obj.S.p.p_o.*do_t + obj.S.p.p_i.*di_tp1 + .... 
                                            obj.S.p.p_f.*df_tp1 + dc_tp1.*f_tp1;
            df_t = dc_t .* c_tm1 .* obj.d_sigmoid(f_t_);
            di_t = dc_t .* z_t .* obj.d_sigmoid(i_t_);
            dz_t = dc_t .* i_t .* obj.g_(z_t_);

            D = [dz_t, di_t, df_t, dc_t, do_t, dy_t];
        end

        function f_pass = lstm_forward_pass(obj, xs, y_0, c_0)
            dim = size(xs);
            T = dim(1);
            f_pass = zeros(obj.n_hidden, 10, T);

            y_t = y_0; c_t = c_0;
            for t = 1:T
                x_t = xs(t,:)';
                F = obj.lstm_forward_step(x_t, y_t, c_t);
                y_t = F(:,10); c_t = F(:,7);
                f_pass(:,:,t) = F;
            end
        end

        function F = lstm_forward_step(obj, x_t, y_tm1, c_tm1)

            z_t_ = obj.S.W.W_z * x_t + obj.S.R.R_z * y_tm1 + obj.S.b.b_z;
            z_t = obj.g(z_t_); % block input
            i_t_ = obj.S.W.W_i * x_t + obj.S.R.R_i * y_tm1 + obj.S.p.p_i .* c_tm1 + obj.S.b.b_i;
            i_t = obj.sigmoid(i_t_); % input gate
            f_t_ = obj.S.W.W_f * x_t + obj.S.R.R_f * y_tm1 + obj.S.p.p_f .* c_tm1 + obj.S.b.b_f;
            f_t = obj.sigmoid(f_t_); % forget gate
            c_t = z_t .* i_t + c_tm1 .* f_t; % cell
            o_t_ = obj.S.W.W_o * x_t + obj.S.R.R_o * y_tm1 + obj.S.p.p_o .* c_t + obj.S.b.b_o;
            o_t = obj.sigmoid(o_t_); % output gate
            y_t = obj.h(c_t) .* o_t; % block output gate

            F = [z_t_, z_t, i_t_, i_t, f_t_, f_t, c_t, o_t_, o_t, y_t];
        end

        function dS = gradients(obj, T, x, f_pass, b_pass)

            dS = obj.init_gradients();
            for t = 1:T
                % W
                x_t = x(t,:)';
                dS.dW.dW_z = dS.dW.dW_z + b_pass(:,1,t)*x_t';
                dS.dW.dW_i = dS.dW.dW_i + b_pass(:,2,t)*x_t';
                dS.dW.dW_f = dS.dW.dW_f + b_pass(:,3,t)*x_t';
                dS.dW.dW_o = dS.dW.dW_o + b_pass(:,5,t)*x_t';

                % R
                if t < T
                    y_t = f_pass(:,10,t);
                    dS.dR.dR_z = dS.dR.dR_z + b_pass(:,1,t+1)*y_t';
                    dS.dR.dR_i = dS.dR.dR_i + b_pass(:,2,t+1)*y_t';
                    dS.dR.dR_f = dS.dR.dR_f + b_pass(:,3,t+1)*y_t';
                    dS.dR.dR_o = dS.dR.dR_o + b_pass(:,5,t+1)*y_t';
                end

                % P
                c_t = b_pass(:,4,t);
                if t < T
                    dS.dp.dp_i = dS.dp.dp_i + c_t.*b_pass(:,2,t+1);
                    dS.dp.dp_f = dS.dp.dp_f + c_t.*b_pass(:,3,t+1);
                end
                dS.dp.dp_o = dS.dp.dp_o + c_t.*b_pass(:,5,t); 

                % B
                dS.db.db_z = dS.db.db_z + b_pass(:,1,t);
                dS.db.db_i = dS.db.db_i + b_pass(:,2,t);
                dS.db.db_f = dS.db.db_f + b_pass(:,3,t);
                dS.db.db_o = dS.db.db_o + b_pass(:,5,t);
            end
        end

        function dS = init_gradients(obj)
            % W
            dW_z = zeros(obj.n_hidden, obj.n_in);
            dW_i = zeros(obj.n_hidden, obj.n_in);
            dW_f = zeros(obj.n_hidden, obj.n_in);
            dW_o = zeros(obj.n_hidden, obj.n_in);
            % R
            dR_z = zeros(obj.n_hidden, obj.n_hidden);
            dR_i = zeros(obj.n_hidden, obj.n_hidden);
            dR_f = zeros(obj.n_hidden, obj.n_hidden);
            dR_o = zeros(obj.n_hidden, obj.n_hidden);
            % P
            dp_i = zeros(obj.n_hidden, 1);
            dp_f = zeros(obj.n_hidden, 1);
            dp_o = zeros(obj.n_hidden, 1);
            % B
            db_z = zeros(obj.n_hidden, 1);
            db_i = zeros(obj.n_hidden, 1);
            db_f = zeros(obj.n_hidden, 1);
            db_o = zeros(obj.n_hidden, 1);

            dW = struct('dW_z', {dW_z}, 'dW_i', {dW_i}, 'dW_f', {dW_f}, 'dW_o', {dW_o});
            dR = struct('dR_z', {dR_z}, 'dR_i', {dR_i}, 'dR_f', {dR_f}, 'dR_o', {dR_o});
            dp = struct('dp_i', {dp_i}, 'dp_f', {dp_f}, 'dp_o', {dp_o});
            db = struct('db_z', {db_z}, 'db_i', {db_i}, 'db_f', {db_f}, 'db_o', {db_o});

            dS = struct('dW', {dW}, 'dR', {dR}, 'dp', {dp}, 'db', {db});
        end

        function update_weights(obj, dS)

            obj.S.W.W_z = obj.S.W.W_z - obj.n * dS.dW.dW_z;
            obj.S.W.W_i = obj.S.W.W_i - obj.n * dS.dW.dW_i;
            obj.S.W.W_f = obj.S.W.W_f - obj.n * dS.dW.dW_f;
            obj.S.W.W_o = obj.S.W.W_o - obj.n * dS.dW.dW_o;

            obj.S.R.R_z = obj.S.R.R_z - obj.n * dS.dR.dR_z;
            obj.S.R.R_i = obj.S.R.R_i - obj.n * dS.dR.dR_i;
            obj.S.R.R_f = obj.S.R.R_f - obj.n * dS.dR.dR_f;
            obj.S.R.R_o = obj.S.R.R_o - obj.n * dS.dR.dR_o;

            obj.S.p.p_i = obj.S.p.p_i - obj.n * dS.dp.dp_i;
            obj.S.p.p_f = obj.S.p.p_f - obj.n * dS.dp.dp_f;
            obj.S.p.p_o = obj.S.p.p_o - obj.n * dS.dp.dp_o;

            obj.S.b.b_z = obj.S.b.b_z - obj.n*dS.db.db_z;
            obj.S.b.b_i = obj.S.b.b_i - obj.n*dS.db.db_i;
            obj.S.b.b_f = obj.S.b.b_f - obj.n*dS.db.db_f;
            obj.S.b.b_o = obj.S.b.b_o - obj.n*dS.db.db_o;
        end
        
        % Help function
        function [dz_t, di_t, df_t, dc_t, do_t, dy_t] = unpackD(obj, D)
            dz_t = D(:,1);
            di_t = D(:,2);
            df_t = D(:,3);
            dc_t = D(:,4);
            do_t = D(:,5);
            dy_t = D(:,6);
        end

        % Help function
        function [z_t_, z_t, i_t_, i_t, f_t_, f_t, c_t, o_t_, o_t, y_t] = unpackF(obj, F)
            z_t_ = F(:,1);
            z_t  = F(:,2);
            i_t_ = F(:,3);
            i_t  = F(:,4);
            f_t_ = F(:,5);
            f_t  = F(:,6);
            c_t  = F(:,7);
            o_t  = F(:,8);
            o_t_ = F(:,9);
            y_t  = F(:,10);
        end

        function S = init_weights(obj, mu, sigma)

            % Input weights
            W_z = normrnd(mu,sigma,[obj.n_hidden, obj.n_in]);
            W_i = normrnd(mu,sigma,[obj.n_hidden, obj.n_in]);
            W_f = normrnd(mu,sigma,[obj.n_hidden, obj.n_in]);
            W_o = normrnd(mu,sigma,[obj.n_hidden, obj.n_in]);
            W = struct('W_z', {W_z}, 'W_i', {W_i}, 'W_f', {W_f}, 'W_o', {W_o});

            % Recurrent weights
            R_z = normrnd(mu,sigma,[obj.n_hidden, obj.n_hidden]);
            R_i = normrnd(mu,sigma,[obj.n_hidden, obj.n_hidden]);
            R_f = normrnd(mu,sigma,[obj.n_hidden, obj.n_hidden]);
            R_o = normrnd(mu,sigma,[obj.n_hidden, obj.n_hidden]);
            R = struct('R_z', {R_z}, 'R_i', {R_i}, 'R_f', {R_f}, 'R_o', {R_o});

            % Peephole weights
            p_i = normrnd(mu,sigma,[obj.n_hidden, 1]);
            p_f = normrnd(mu,sigma,[obj.n_hidden, 1]);
            p_o = normrnd(mu,sigma,[obj.n_hidden, 1]);
            p = struct('p_i', {p_i}, 'p_f', {p_f}, 'p_o', {p_o});

            % Bias weights
            b_z = normrnd(mu,sigma,[obj.n_hidden, 1]);
            b_i = normrnd(mu,sigma,[obj.n_hidden, 1]);
            b_f = normrnd(mu,sigma,[obj.n_hidden, 1]);
            b_o = normrnd(mu,sigma,[obj.n_hidden, 1]);
            b = struct('b_z', {b_z}, 'b_i', {b_i}, 'b_f', {b_f}, 'b_o', {b_o});

            S = struct('W', {W}, 'R', {R}, 'p', {p}, 'b', {b});
        end

        function save_net(obj, file_name)
            save(file_name);
        end

        function net = load_net(obj, file_name)
            net = load(file_name);
            
            obj.S = net.obj.S;
            obj.n = net.obj.n;
            obj.n_in = net.obj.n_in;
            obj.n_hidden = net.obj.n_hidden;
        end

        %% Activation functions

        function res = sigmoid(obj, x)
          res = 1 ./ (1 + exp(-x));
        end

        function res = d_sigmoid(obj, x)
          res = obj.sigmoid(x).*(1-obj.sigmoid(x));
        end

        function res = g_(obj, x)
            res = 1 - tanh(x).^2;
        end

        function res = g(obj, x)
            res = tanh(x);
        end

        function res = h(obj, x)
            res = obj.sigmoid(x);
        end

        function res = h_(obj, x)
            res = obj.d_sigmoid(x);
        end
    end
end
