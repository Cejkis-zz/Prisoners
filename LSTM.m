
function [] = lstm()
    load = false;
    file_name = 'S.mat';
    mu = 0.05;
    sigma = 0.01;
    n_hidden = 4; n_in = 2; n_y = 1;
    n = 0.5;
    
    if load 
        S = load_weights(file_name);
        W_y = load_weights('W_y.mat');
    else
        S = init_weights(mu, sigma, n_hidden, n_in);
        W_y = normrnd(mu,sigma,[n_y, n_hidden]);
    end

    T = 6;
    xs = [[1,1];
          [0,0];
          [1,1];
          [0,0];
          [1,1];
          [0,0]];
    t = 0;
    
    c_0 = zeros(n_hidden, 1);
    y_0 = zeros(n_hidden, 1);
    [S, W_y] = train_network(S, W_y, y_0, c_0, T, xs, t, n, n_hidden, n_in);
    predict(S, W_y, y_0, c_0, T, xs, n_hidden)
    store_weights(S, 'S.mat');
    store_weights(W_y, 'W_y.mat');
end

%% https://arxiv.org/pdf/1503.04069v1.pdf
function [output, y_t, c_t] = predict(S, W_y, y_tm1, c_tm1, T, xs, n_hidden)
    % Forward
    f_pass = lstm_forward_pass(n_hidden, xs, y_tm1, c_tm1, T, S);
    c_t = f_pass(:, 7, T);
    y_t = f_pass(:, 10, T);
    output = output_activation(W_y, y_t);
end

function [S, W_y] = train_network(S, W_y, y_tm1, c_tm1, T, xs, t, n, n_hidden, n_in)
    
    % Forward
    f_pass = lstm_forward_pass(n_hidden, xs, y_tm1, c_tm1, T, S);
    y_t = f_pass(:, 10, T);
    output = output_activation(W_y, y_t); % linear + sigmoid activation
    
    % Loss function
    Loss = (t - output);
    
    % Output layer
    d_out = - Loss*d_output_activation(output);
    dW_y = d_out*y_t';
    W_y = W_y - n * dW_y;
    
    % Backward
    b_pass = lstm_backward_pass(n_hidden, d_out, T, f_pass, S);
    dS = gradients(T, xs, f_pass, b_pass, n_hidden, n_in);
    S = update_weights(n, S, dS);
end

function dS = gradients(T, x, f_pass, b_pass, n_hidden, n_in)

    dS = init_gradients(n_hidden, n_in);
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

function dS = init_gradients(n_hidden, n_in)
    % W
    dW_z = zeros(n_hidden, n_in);
    dW_i = zeros(n_hidden, n_in);
    dW_f = zeros(n_hidden, n_in);
    dW_o = zeros(n_hidden, n_in);
    % R
    dR_z = zeros(n_hidden, n_hidden);
    dR_i = zeros(n_hidden, n_hidden);
    dR_f = zeros(n_hidden, n_hidden);
    dR_o = zeros(n_hidden, n_hidden);
    % P
    dp_i = zeros(n_hidden, 1);
    dp_f = zeros(n_hidden, 1);
    dp_o = zeros(n_hidden, 1);
    % B
    db_z = zeros(n_hidden, 1);
    db_i = zeros(n_hidden, 1);
    db_f = zeros(n_hidden, 1);
    db_o = zeros(n_hidden, 1);
    
    dW = struct('dW_z', {dW_z}, 'dW_i', {dW_i}, 'dW_f', {dW_f}, 'dW_o', {dW_o});
    dR = struct('dR_z', {dR_z}, 'dR_i', {dR_i}, 'dR_f', {dR_f}, 'dR_o', {dR_o});
    dp = struct('dp_i', {dp_i}, 'dp_f', {dp_f}, 'dp_o', {dp_o});
    db = struct('db_z', {db_z}, 'db_i', {db_i}, 'db_f', {db_f}, 'db_o', {db_o});
    
    dS = struct('dW', {dW}, 'dR', {dR}, 'dp', {dp}, 'db', {db});
end

function S = update_weights(n, S, dS)

    S.W.W_z = S.W.W_z - n * dS.dW.dW_z;
    S.W.W_i = S.W.W_i - n * dS.dW.dW_i;
    S.W.W_f = S.W.W_f - n * dS.dW.dW_f;
    S.W.W_o = S.W.W_o - n * dS.dW.dW_o;
    
    S.R.R_z = S.R.R_z - n * dS.dR.dR_z;
    S.R.R_i = S.R.R_i - n * dS.dR.dR_i;
    S.R.R_f = S.R.R_f - n * dS.dR.dR_f;
    S.R.R_o = S.R.R_o - n * dS.dR.dR_o;
    
    S.p.p_i = S.p.p_i - n * dS.dp.dp_i;
    S.p.p_f = S.p.p_f - n * dS.dp.dp_f;
    S.p.p_o = S.p.p_o - n * dS.dp.dp_o;
    
    S.b.b_z = S.b.b_z - n*dS.db.db_z;
    S.b.b_i = S.b.b_i - n*dS.db.db_i;
    S.b.b_f = S.b.b_f - n*dS.db.db_f;
    S.b.b_o = S.b.b_o - n*dS.db.db_o;
    
end

function b_pass = lstm_backward_pass(n_hidden, d_out, T, f_pass, S)
    b_pass = zeros(n_hidden, 6, T);
    dz_t = zeros(n_hidden, 1); di_t = zeros(n_hidden, 1); 
    df_t = zeros(n_hidden, 1); dc_t = zeros(n_hidden, 1); 
    do_t = zeros(n_hidden, 1); dy_t = zeros(n_hidden, 1);
    D = [dz_t, di_t, df_t, dc_t, do_t, dy_t];

    f_tp1 = zeros(n_hidden, 1);
    for t = T:-1:1
        F = f_pass(:,:,t);
        
        if t < T
            f_tp1 = f_pass(:,6,t+1);
            d_out = zeros(n_hidden, 1);
        end
        
        if t > 1 
            c_tm1 = f_pass(:,7,t-1);
        else
            c_tm1 = zeros(n_hidden, 1);
        end
        
        D = lstm_backward_step(d_out, f_tp1, c_tm1, F, D, S);
        b_pass(:,:,t) = D; 
    end
end

function D = lstm_backward_step(d_t, f_tp1, c_tm1, F, D, S)
    % Unpack
    [z_t_, z_t, i_t_, i_t, f_t_, f_t, c_t, o_t_, o_t, y_t] = unpackF(F);
    [dz_tp1, di_tp1, df_tp1, dc_tp1, do_tp1, dy_tp1] = unpackD(D);
    
    dy_t = d_t + S.R.R_z * dz_tp1 + S.R.R_i * di_tp1 + ... 
                 S.R.R_f * df_tp1 + S.R.R_o * do_tp1; 
    do_t = dy_t .* h(c_t) .* d_sigmoid(o_t_);
    dc_t = dy_t .* o_t .* h_(c_t) + S.p.p_o.*do_t + S.p.p_i.*di_tp1 + .... 
                                    S.p.p_f.*df_tp1 + dc_tp1.*f_tp1;
    df_t = dc_t .* c_tm1 .* d_sigmoid(f_t_);
    di_t = dc_t .* z_t .* d_sigmoid(i_t_);
    dz_t = dc_t .* i_t .* g_(z_t_);
    
    D = [dz_t, di_t, df_t, dc_t, do_t, dy_t];
end

function f_pass = lstm_forward_pass(n_hidden, xs, y_0, c_0, T, S)
    f_pass = zeros(n_hidden, 10, T);
    
    y_t = y_0; c_t = c_0;
    for t = 1:T
        x_t = xs(t,:)';
        F = lstm_forward_step(x_t, y_t, c_t, S);
        y_t = F(:,10); c_t = F(:,7);
        f_pass(:,:,t) = F;
    end
end

function F = lstm_forward_step(x_t, y_tm1, c_tm1, S)

    z_t_ = S.W.W_z * x_t + S.R.R_z * y_tm1 + S.b.b_z;
    z_t = g(z_t_); % block input
    i_t_ = S.W.W_i * x_t + S.R.R_i * y_tm1 + S.p.p_i .* c_tm1 + S.b.b_i;
    i_t = sigmoid(i_t_); % input gate
    f_t_ = S.W.W_f * x_t + S.R.R_f * y_tm1 + S.p.p_f .* c_tm1 + S.b.b_f;
    f_t = sigmoid(f_t_); % forget gate
    c_t = z_t .* i_t + c_tm1 .* f_t; % cell
    o_t_ = S.W.W_o * x_t + S.R.R_o * y_tm1 + S.p.p_o .* c_t + S.b.b_o;
    o_t = sigmoid(o_t_); % output gate
    y_t = h(c_t) .* o_t; % block output gate
    
    F = [z_t_, z_t, i_t_, i_t, f_t_, f_t, c_t, o_t_, o_t, y_t];
end

function [dz_t, di_t, df_t, dc_t, do_t, dy_t] = unpackD(D)
    dz_t = D(:,1);
    di_t = D(:,2);
    df_t = D(:,3);
    dc_t = D(:,4);
    do_t = D(:,5);
    dy_t = D(:,6);
end

function [z_t_, z_t, i_t_, i_t, f_t_, f_t, c_t, o_t_, o_t, y_t] = unpackF(F)
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

function S = init_weights(mu, sigma, n_hidden, n_in)
 
    % Input weights
    W_z = normrnd(mu,sigma,[n_hidden, n_in]);
    W_i = normrnd(mu,sigma,[n_hidden, n_in]);
    W_f = normrnd(mu,sigma,[n_hidden, n_in]);
    W_o = normrnd(mu,sigma,[n_hidden, n_in]);
    W = struct('W_z', {W_z}, 'W_i', {W_i}, 'W_f', {W_f}, 'W_o', {W_o});
    
    % Recurrent weights
    R_z = normrnd(mu,sigma,[n_hidden, n_hidden]);
    R_i = normrnd(mu,sigma,[n_hidden, n_hidden]);
    R_f = normrnd(mu,sigma,[n_hidden, n_hidden]);
    R_o = normrnd(mu,sigma,[n_hidden, n_hidden]);
    R = struct('R_z', {R_z}, 'R_i', {R_i}, 'R_f', {R_f}, 'R_o', {R_o});
    
    % Peephole weights
    p_i = normrnd(mu,sigma,[n_hidden, 1]);
    p_f = normrnd(mu,sigma,[n_hidden, 1]);
    p_o = normrnd(mu,sigma,[n_hidden, 1]);
    p = struct('p_i', {p_i}, 'p_f', {p_f}, 'p_o', {p_o});

    % Bias weights
    b_z = normrnd(mu,sigma,[n_hidden, 1]);
    b_i = normrnd(mu,sigma,[n_hidden, 1]);
    b_f = normrnd(mu,sigma,[n_hidden, 1]);
    b_o = normrnd(mu,sigma,[n_hidden, 1]);
    b = struct('b_z', {b_z}, 'b_i', {b_i}, 'b_f', {b_f}, 'b_o', {b_o});
    
    S = struct('W', {W}, 'R', {R}, 'p', {p}, 'b', {b});
end

function store_weights(S, file_name)
    save(file_name);
end

function S = load_weights(file_name)
    struct = load(file_name);
    S = struct.S;
end

%% Activation functions

function res = sigmoid(x)
  res = 1 ./ (1 + exp(-x));
end

function res = d_sigmoid(x)
  res = sigmoid(x).*(1-sigmoid(x));
end

function res = sigmoid_(x)
  res = sigmoid(x).*(1-sigmoid(x));
end

function res = g_(x)
    res = 1 - tanh(x).^2;
end

function res = g(x)
    res = tanh(x);
end

function res = h(x)
    res = sigmoid(x);
end

function res = h_(x)
    res = sigmoid_(x);
end

function y = output_activation(W, x)
    % linear + sigmoid
    y = sigmoid(W*x);
end

function dy = d_output_activation(y)
    dy = d_sigmoid(y);
end
