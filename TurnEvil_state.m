function [ out ] = TurnEvil_state( history )
% cooperates, but from one random point defects all the time

%state the global variable. (state)
global isEvil;

%cooperate initially. 
if size(history,1) ==0
    out = 1;
    return;
end

%Risk of turning madly evil.
if (~isEvil && rand>0.99)
    isEvil=1;
end

%If Evil then always defect.
if (isEvil==1)
    out = 0;
else
    %Copy opponents move last round.
    out = history(end, 2);
end

