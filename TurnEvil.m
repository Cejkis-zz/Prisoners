function [ out ] = TurnEvil( history )
% cooperates, but from one random point defects all the time

if size(history,1) ==0
    out = 1;
    return;
end

if rand > 0.95
    out = 0;
else
    out = history(end, 1);

end

